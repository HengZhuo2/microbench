#include "tbench_server.h"
#include <unistd.h>
#include <math.h>

#include <atomic>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <random>
#include <string>
#include <pthread.h>
#include <random>

#include <sstream>

using namespace std;

void printHelp(char* argv[]) {
    cerr << endl;
    cerr << "Usage: " << argv[0] << " [-f model_file] [-n max_reqs]" \
        << " [-r threads] [-h]" << endl << endl;
    cerr << "-f : Name of model file to load " << "(default: model.xml)" \
        << endl; 
    cerr << "-n : Maximum number of requests "\
        << "(default: 6000; size of the full MNIST test dataset)" << endl;
    cerr << "-r : Number of worker threads" << endl;
    cerr << "-h : Print this help and exit" << endl;
}

template<typename T>
static T getOpt(const char* name, T defVal) {
    const char* opt = getenv(name);

    if (!opt){
        std::cout << name << " = " << defVal << std::endl;
        return defVal;
    }
    else{
        std::cout << name << " = " << opt << std::endl;
    }
    std::stringstream ss(opt);
    if (ss.str().length() == 0) return defVal;
    T res;
    ss >> res;
    if (ss.fail()) {
        std::cerr << "WARNING: Option " << name << "(" << opt << ") could not"\
            << " be parsed, using default" << std::endl;
        return defVal;
    }   
    return res;
}

static inline uint64_t GetCurrentClockCycle() {
#if defined(__x86_64__) || defined(__amd64__)
  uint64_t high, low;
  __asm__ volatile("rdtsc" : "=a"(low), "=d"(high));
  return (high << 32) | low;
  // ----------------------------------------------------------------
#elif defined(__aarch64__)
  // System timer of ARMv8 runs at a different frequency than the CPU's.
  // The frequency is fixed, typically in the range 1-50MHz.  It can because
  // read at CNTFRQ special register.  We assume the OS has set up
  // the virtual timer properly.
  uint64_t virtual_timer_value;
  asm volatile("mrs %0, cntvct_el0" : "=r"(virtual_timer_value));
  return virtual_timer_value;
#else
  return DUMMY_CYCLE_CLOCK;
#endif
}

static inline uint64_t GetFrequency() {
#if defined(__x86_64__) || defined(__amd64__)
    // this number is based on the system running now.
    // maybe a better to get this number from compile environment
    uint64_t rdt_freq = 4007999999;
    return rdt_freq;
#elif defined(__aarch64__)
  // System timer of ARMv8 runs at a different frequency than the CPU's.
  // The frequency is fixed, typically in the range 1-50MHz.  It can because
  // read at CNTFRQ special register.  We assume the OS has set up
  // the virtual timer properly.
  uint64_t virtual_timer_freq;
  asm volatile("mrs %0, cntfrq_el0" : "=r"(virtual_timer_freq));
  return virtual_timer_freq;
#else
  return DUMMY_FREQ;
#endif
}

pthread_mutex_t microLock[9];
bool underNoise[9] = {false};
// std::exponential_distribution<double> eDist(1 * 1e-9);
//std::uniform_int_distribution<int> nDist{0,1}; 
std::random_device rd;
std::default_random_engine random_g(rd());

uint64_t hybridLock(pthread_mutex_t *theLock, uint64_t spinLimit, int lockId) {
  uint64_t i;
  // printf("start: lockId[%i],spin[%lu]\n", lockId, i);
  for ( i=0;i < spinLimit; ){
    if(pthread_mutex_trylock(theLock)==0){
        // printf("thread[%i],spin[%lu]\n", lockId, i);
        return i;
    }
    if(!underNoise[lockId]){
      i++;
    }else{
      // printf("time freezing: lock[%i],spin[%lu]\n", lockId, i);
    }
  }
  // printf("end: lockId[%i],spin[%lu]\n", lockId, i);
  pthread_mutex_lock(theLock);
  return i;
}

class Worker {
private:
  int tid;
  pthread_t thread;
  
  long nReqs;
  static atomic_llong nReqsTotal;
  static long maxReqs;
  static atomic_llong correct;
  uint64_t spinLimit;
  int nBlockT, blockT;
  int blockVar, nBlockVar, noiseVar;
  // disturbance time, noiseAmp controls how much higher chance
  int noiseT, noiseAmp; 
  int noiseP;
  int sleepTime, sleepP;
  bool timeFreeze;
  std::uniform_int_distribution<int> uDist;
  // std::uniform_int_distribution<int> sleepDist;
  // std::exponential_distribution<double> nBlockDist;
   
  static void* run(void* ptr) {
    Worker* worker = reinterpret_cast<Worker*>(ptr);
    worker->doRun();
    
    return nullptr;
  }
  
  void doRun() {
    tBenchServerThreadStart();
    printf("tid is: %i\n",tid);
    char* request;
    
    //get system clock frequency, should be 54MHz on rasp pi
    uint64_t virt_freq = GetFrequency();

    int lockIdx;
    double nBlockAve = virt_freq*nBlockT/1e+6;
    double blockAve = virt_freq*blockT/1e+6;
    double noiseAve = virt_freq*noiseT/1e+6;
    // int sleepAve = virt_freq/(1e+6/sleepTime);

    std::normal_distribution<double> nBlockDist(nBlockAve,nBlockAve/nBlockVar);
    std::normal_distribution<double> blockDist(blockAve,blockAve/blockVar);
    std::normal_distribution<double> noiseLengthDist(noiseAve,noiseAve/noiseVar);
    std::normal_distribution<double> sleepLengthDist(sleepTime,sleepTime/100);
    std::uniform_int_distribution<int> noiseDist(0, 999);
    std::uniform_int_distribution<int> sleepDist(0, 999);


    printf("nonblock time: %i us, var: %i, blocktime: %i us, var: %i, noise time: %i us, var: %i.\n", nBlockT, nBlockT/nBlockVar, blockT, blockT/blockVar, noiseT, noiseT/noiseVar);
    printf("base freq: %lu, nonblockcing cycle is: %f, blocking cycle is: %f, noise cycles is: %f, noise p: %i.\n", virt_freq, nBlockAve, blockAve, noiseAve, noiseP);
    printf("spinLimit: %li \n", spinLimit);
    printf("uniform dist bound [%i, %i]\n", uDist.min(),uDist.max());
    
    long long  nBlockCycle, blockCycle, noiseCycle;
    long long t_start, t_end;
    
    while (true) {
      ++nReqs;
      size_t len = tBenchRecvReq(reinterpret_cast<void**>(&request));
      uint64_t cnt; 
      
      //some non critical work before the lock
      t_start=GetCurrentClockCycle();
      t_end=GetCurrentClockCycle();
      nBlockCycle = std::llround(nBlockDist(random_g));
      // printf("nBlockCycle: %lld.\n",nBlockCycle);

      while(!((t_end-t_start)/nBlockCycle)){
          t_end=GetCurrentClockCycle();
      }

      //randomized change to add noise disturbance
      if(sleepDist(rd) < sleepP){
          int sleepNs = sleepLengthDist(random_g);
          struct timespec ts = {(time_t)(0), (time_t)(sleepNs)};
          // printf("push myself to sleep.");
          nanosleep(&ts, NULL); //not guaranteed, hence the loop
      }

      //Then, for critical section, grabing different locks
      lockIdx = uDist(rd);
      //lockIdx = tid;
      cnt = hybridLock(&microLock[lockIdx], spinLimit, lockIdx);

      blockCycle = std::llround(blockDist(random_g));

      // printf("BlockCycle: %lld.\n",blockCycle);

      t_start=GetCurrentClockCycle();
      t_end=GetCurrentClockCycle();
      while(!((t_end-t_start)/blockCycle)){
          t_end=GetCurrentClockCycle();
      }

      //blockCycle = blockDist(random_g);
      
      // when cnt hit the limit, double the chance 
      if (cnt == spinLimit && (noiseDist(rd) < noiseP*noiseAmp)){
        noiseCycle = noiseLengthDist(random_g)+1;
      } else if (cnt != spinLimit && (noiseDist(rd) < noiseP)) {
        noiseCycle = noiseLengthDist(random_g)+1;
      } else{
        noiseCycle = 1;
      }

      // printf("noise: %u.\n",noiseCycle);
      
      t_start=GetCurrentClockCycle();
      t_end=GetCurrentClockCycle();
      asm volatile("nop");
      underNoise[lockIdx] = timeFreeze;
      while(!((t_end-t_start)/noiseCycle)){
        t_end=GetCurrentClockCycle();
        //printf("%u, %u \n",t_start,t_end);
      }
      asm volatile("nop");
      underNoise[lockIdx] = false;
      pthread_mutex_unlock(&microLock[lockIdx]);
            
      tBenchSendResp(reinterpret_cast<const void*>(&cnt), sizeof(cnt));
    }
  }
  
public:
  Worker(int tid, int blockT, int blockVar, int nBlockT, int nBlockVar, int idxLow, int idxHigh, int spinMax, int sleepT, int sleepP, int noiseT, double noiseP, int noiseVar, int noiseA, bool timeFreeze)
    : tid(tid) 
    , nReqs(0)
    , spinLimit(spinMax)
    , blockT(blockT)
    , blockVar(blockVar)
    , nBlockT(nBlockT)
    , nBlockVar(nBlockVar)
    , uDist(idxLow,idxHigh)
    , noiseT(noiseT)
    , noiseP(noiseP)
    , noiseVar(noiseVar)
    , sleepTime(sleepT)
    , sleepP(sleepP)
    , noiseAmp(noiseA)
    , timeFreeze(timeFreeze)
  { }
  
  void run() {
    pthread_create(&thread, nullptr, Worker::run, reinterpret_cast<void*>(this));
  }
  
  void join() {
    pthread_join(thread, nullptr);
  }
  
  static long correctDecodes() { return correct; }
  
  // static void updateMaxReqs(long _maxReqs) { maxReqs = _maxReqs; }
  
};

atomic_llong Worker::nReqsTotal(0);
long Worker::maxReqs(0);
atomic_llong Worker::correct(0);

int 
main(int argc, char** argv)
{
  int nThreads = 1;
  pthread_mutex_init(microLock, nullptr);
  int c;
  int low,high = 0;
  while ((c = getopt(argc, argv, "r:h")) != -1) {
    switch(c) {
    case 'r':
      nThreads = atoi(optarg);
      break;
    case 'h':
      printHelp(argv);
      return 0;
      break;
    case '?':
      printHelp(argv);
      return -1;
      break;
    }
  }

  int sleepT = getOpt<double>("SLEEP_TIME", 1000.0) * 1e+3;
  int sleepP = getOpt<int>("SLEEP_PROB", 0);

  printf("Sleeping time: %i us, Prob:%i.\n", sleepT/1000, sleepP);

  int noiseT = getOpt<int>("NOISE_TIME", 1000);
  int noiseP = getOpt<int>("NOISE_PROB", 0);
  int noiseV = getOpt<int>("NOISE_VAR", 0);
  int noiseA = getOpt<int>("NOISE_AMP", 0);
  double noiseMod = getOpt<double>("TBENCH_QPS_ROI", 0) / 160 ;
  printf("noise time: %i us, Prob:%i.\n", noiseT, noiseP);

  int blockT = getOpt<int>("BLOCK_TIME", 1000);
  int blockV = getOpt<int>("BLOCK_VAR", 100);
  int nBlockT = getOpt<int>("NONBLOCK_TIME", 1000);
  int nBlockV = getOpt<int>("NONBLOCK_VAR", 100);

  printf("lock time: %i us, non block time:%i.\n", blockT, nBlockT);

  int spinL  = getOpt<int>("SPIN_LIMIT", 0);

  int lockIdx0 = getOpt<int>("LOCKID_LOW", 0);
  int lockIdx1 = getOpt<int>("LOCKID_HIGH", 0);

  bool timeFreeze = getOpt<bool>("TIME_FREEZE", 0);

  long start, end;
  start = clock();
  
  tBenchServerInit(nThreads);
  // Worker::updateMaxReqs(maxReqs);
  vector<Worker> workers;
  for (int t = 0; t < nThreads; ++t) {
    workers.push_back(Worker(t, blockT, blockV, nBlockT, nBlockV, lockIdx0, lockIdx1, spinL, sleepT, sleepP, noiseT, noiseP, noiseV, noiseA, timeFreeze));
  }
  
  for (int t = 0; t < nThreads; ++t) {
    workers[t].run();
  }
  
  for (int t = 0; t < nThreads; ++t) {
    workers[t].join();
  }
  
  // cout<<"correct: "<<Worker::correctDecodes()<<", total: "	\
  <<maxReqs<<", accuracy: "						\
        <<double(Worker::correctDecodes()) / (double)(maxReqs)<<endl;
  
  end = clock();
  std::cout<<"End-to-end run time: "<<((double)(end - start)) / CLOCKS_PER_SEC<<" second"<<std::endl;
  
  return 0;
}
