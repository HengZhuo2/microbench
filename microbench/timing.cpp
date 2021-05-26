#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include <random>
#include <unistd.h>


static uint64_t DUMMY_CYCLE_CLOCK = 1;

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

int main(){
    printf("testing time\n");

    uint64_t rdt_freq = 4007999999;

    // for(int i = 0; i<20;i++){
    //     uint64_t a1 = GetCurrentClockCycle();
    //     uint64_t a2 = GetCurrentClockCycle();
    //     while(!((a2-a1)/rdt_freq)){
    //     // asm("");
    //     a2 = GetCurrentClockCycle();
    //     // printf("number: %i\n", distribution(rd));
    // }
    
    //   std::random_device rd;
    //   std::default_random_engine random_g(rd());
    //   std::uniform_int_distribution<int> distribution(1,10);

    //   while(!((a2-a1)/virt_freq)){
    //     asm("");
    //     a2 = GetCurrentClockCycle();
    //     printf("number: %i\n", distribution(rd));
    //   }
    //int a2 = GetCurrentClockCycle();

    //   printf("time is:%i\n", a2-a1);
        // printf("time is:%lu, %lu, diff:%lu\n", a2,a1,a2-a1);
    // }
    uint64_t value = 32268;
    uint64_t* cnt = &value;
    value++;
    void* data = reinterpret_cast<void*>(cnt);

    printf("return spin time: %lu[%p]\n", *cnt, &cnt);
    printf("return data: %p[%p]\n", data, &data);

    uint64_t* recnt = reinterpret_cast<uint64_t*>(data);
    printf("return data: %lu[%p]\n", *recnt, &recnt);


  return 0;
}