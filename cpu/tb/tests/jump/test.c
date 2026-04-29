#define PASS (*(volatile int*)0x2000)   // testbench reads 0x2000 for pass count
#define FAIL (*(volatile int*)0x2004)   // testbench reads 0x2004 for fail count

static inline void check(int got, int expected) {
    if (got == expected) PASS++;
    else                 FAIL++;
}

__attribute__((noinline)) int sum(int a , int b )
    {
        return a + b;
    }

void main(void) {
    PASS = 0;
    FAIL = 0;
    int a = 10;
    int b = 20;
    int res = 0;

    res = sum(a , b);

    check(res , 30);

    asm volatile("ebreak");
}

