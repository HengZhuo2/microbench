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
std::uniform_int_distribution<int> nDist{0,1};
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
            double t;
            struct timespec ts_sleep;
            int lockIdx;
            // while (++nReqsTotal <= maxReqs) {
            uint64_t nextNs = getCurNs();
            while (true) {
                ++nReqs;

                size_t len = tBenchRecvReq(reinterpret_cast<void**>(&request));
                // // cout<<"recv one req here"<<endl;
                if(tid==0){
                    int i;
                    i=4e+5;
                    while(--i){
                        asm("");
                    }
                    hybridLock(&microLock[0], spinLimit, tid);
                    // t = eDist(random_g);
                    i=4e+5;
                    while(--i){
                        asm("");
                    }
                    pthread_mutex_unlock(&microLock[0]);
                } else {
                    // lockIdx = nDist(random_g);
                    lockIdx = tid;
                    // nextNs += eDist(random_g);
                    int j;
                    j=1e+6;
                    while(--j){
                        asm("");
                    }
                    hybridLock(&microLock[0], spinLimit, tid);
                    j=1e+6;
                    while(--j){
                        asm("");
                    }
                    pthread_mutex_unlock(&microLock[0]);
                }

                tBenchSendResp(reinterpret_cast<const void*>(&nReqs), sizeof(nReqs));
            }
        }

    public:
        Worker(int tid)
            : tid(tid) 
            , nReqs(0)
            , spinLimit(1000000000)
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

    long start, end;
    start = clock();
    
    tBenchServerInit(nThreads);
    // Worker::updateMaxReqs(maxReqs);
    vector<Worker> workers;
    for (int t = 0; t < nThreads; ++t) {
        workers.push_back(Worker(t));
    }

    for (int t = 0; t < nThreads; ++t) {
        workers[t].run();
    }

    for (int t = 0; t < nThreads; ++t) {
        workers[t].join();
    }

    // cout<<"correct: "<<Worker::correctDecodes()<<", total: "\
        <<maxReqs<<", accuracy: "\
        <<double(Worker::correctDecodes()) / (double)(maxReqs)<<endl;

    end = clock();
    std::cout<<"End-to-end run time: "<<((double)(end - start)) / CLOCKS_PER_SEC<<" second"<<std::endl;

    return 0;
}
