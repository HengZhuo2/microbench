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

static uint64_t getCurNs() {
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    uint64_t t = ts.tv_sec*1000*1000*1000 + ts.tv_nsec;

    return t;
}

static void sleepUntil(uint64_t targetNs) {
    uint64_t curNs = getCurNs();
    while (curNs < targetNs) {
        uint64_t diffNs = targetNs - curNs;
        struct timespec ts = {(time_t)(diffNs/(1000*1000*1000)), 
            (time_t)(diffNs % (1000*1000*1000))};
        nanosleep(&ts, NULL); //not guaranteed, hence the loop
        curNs = getCurNs();
    }
}

pthread_mutex_t microLock[10];
std::exponential_distribution<double> eDist( 1 * 1e-9);
//std::uniform_int_distribution<int> nDist{0,1};
std::random_device rd;
std::default_random_engine random_g(rd());

void hybridLock(pthread_mutex_t *theLock, int spinLimit, int tid) {
    for (unsigned i = 0; i < spinLimit; ++i){
        if(pthread_mutex_trylock(theLock)==0){
            // printf("thread[%i],spin[%i]\n", tid, i);
            return;
        }
    }
    // printf("thread[%i] sleep here.\n", tid);
    pthread_mutex_lock(theLock);
}

class Worker {
private:
  int tid;
  pthread_t thread;
  
  long nReqs;
  static atomic_llong nReqsTotal;
  static long maxReqs;
  static atomic_llong correct;
  int spinLimit;
  int nonblock_length, block_length;
  std::uniform_int_distribution<int> uDist;
  
  long startReq() {
    ++nReqs;
    return ++nReqsTotal;
  }
  
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
    uint64_t virt_freq;
    asm volatile("mrs %0, cntfrq_el0" : "=r"(virt_freq));
    
    int lockIdx;
    // while (++nReqsTotal <= maxReqs) {
    uint64_t nextNs = getCurNs();
    int nonBlockT = virt_freq/nonblock_length;
    int blockT = virt_freq/block_length;
    printf("base freq: %lu, blockcing cycle is: %i, nonblocking cycle is: %i\n", virt_freq, blockT, nonBlockT);
    printf("uniform dist bound [%i, %i]\n", uDist.min(),uDist.max());
    int t_start, t_end;
    while (true) {
      ++nReqs;
      
      size_t len = tBenchRecvReq(reinterpret_cast<void**>(&request));
      // cout<<"recv one req here"<<endl;
      
      if(tid==0){
	t_start=GetCurrentClockCycle();
	t_end=GetCurrentClockCycle();
	while(!((t_end-t_start)/nonBlockT)){
	  t_end=GetCurrentClockCycle();
	}
	hybridLock(&microLock[0], spinLimit, tid);
	// t = eDist(random_g);
	t_start=GetCurrentClockCycle();
	//t_end=GetCurrentClockCycle();
	while(!((t_end-t_start)/blockT)){
	  t_end=GetCurrentClockCycle();
	}
	pthread_mutex_unlock(&microLock[0]);
      } else {
	t_start=GetCurrentClockCycle();
	t_end=GetCurrentClockCycle();
	while(!((t_end-t_start)/nonBlockT)){
	  t_end=GetCurrentClockCycle();
	}
	lockIdx = uDist(rd);
	//printf("locking id[%i]\n",lockIdx);
	hybridLock(&microLock[lockIdx], spinLimit, tid);
	// t = eDist(random_g);
	t_start=GetCurrentClockCycle();
	//t_end=GetCurrentClockCycle();
	while(!((t_end-t_start)/blockT)){
	  t_end=GetCurrentClockCycle();
	}
	pthread_mutex_unlock(&microLock[lockIdx]);
      }
      
      tBenchSendResp(reinterpret_cast<const void*>(&nReqs), sizeof(nReqs));
    }
  }
  
public:
  Worker(int tid, int blockT, int nBlockT, int idxLow, int idxHigh)
    : tid(tid) 
    , nReqs(0)
    , spinLimit(1000000000)
    , block_length(blockT)
    , nonblock_length(nBlockT)
    , uDist(idxLow,idxHigh)
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
  int blockT = 1;
  int nBlockT = 1;
  int low,high = 0;
  while ((c = getopt(argc, argv, "r:n:t:l:p:h")) != -1) {
    switch(c) {
    case 'r':
      nThreads = atoi(optarg);
      break;
    case 'n':
      blockT = atoi(optarg);
      break;
    case 't':
      nBlockT = atoi(optarg);
      break;
    case 'l':
      low = atoi(optarg);
      break;
    case 'p':
      high = atoi(optarg);
      break;
    case 'h':
      printHelp(argv);
      return 0;
      break;
      //case 'b':
      //  blockT = atoi(optarg) * 1e+6;
      //  break;
      //case 'n':
      //nBlockT = atoi(optarg);
      //break;
    case '?':
      printHelp(argv);
      return -1;
      break;
    }
  }
  
  long start, end;
  start = clock();
  
  tBenchServerInit(nThreads);
  // Worker::updateMaxReqs(maxReqs);
  vector<Worker> workers;
  for (int t = 0; t < nThreads; ++t) {
    workers.push_back(Worker(t, blockT, nBlockT, low, high));
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
