#define PASS (*(volatile int*)0x2000)   // testbench reads 0x2000 for pass count
#define FAIL (*(volatile int*)0x2004)   // testbench reads 0x2004 for fail count

static inline void check(int got, int expected) {
    if (got == expected) PASS++;
    else                 FAIL++;
}

void main(void) {
    PASS = 0;
    FAIL = 0;

    volatile int* p = (volatile int*)0x1000;

    p[0] = 10;
    p[1] = 20;

    int a = p[0];
    int b = a + 5;

    check(b , 15);

    int c = p[1];       // LW c, 4(p)
    int d = c * 2;      // 也是 load-use（如果编译器没有重排）
    check(d, 40); 

    asm volatile("ebreak");
}