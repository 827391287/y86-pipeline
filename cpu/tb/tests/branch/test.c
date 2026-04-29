#define PASS (*(volatile int*)0x2000)   // testbench reads 0x2000 for pass count
#define FAIL (*(volatile int*)0x2004)   // testbench reads 0x2004 for fail count

static inline void check(int got, int expected) {
    if (got == expected) PASS++;
    else                 FAIL++;
}

void main(void) {
    PASS = 0;
    FAIL = 0;

    volatile int n = 10;   // 从内存读，编译器不知道值是多少

    int a = 0;

    for(int i = 0 ; i < n; i ++)
    {
        a += i;
    }

    int b = a + 1;
    int c = b + 1;

    check(a , 45);
    check(b , 46);
    check(c , 47);

    asm volatile("ebreak");
}