#define PASS (*(volatile int*)0x2000)   // testbench reads 0x2000 for pass count
#define FAIL (*(volatile int*)0x2004)   // testbench reads 0x2004 for fail count

static inline void check(int got, int expected) {
    if (got == expected) PASS++;
    else                 FAIL++;
}

void main(void) {
    PASS = 0;
    FAIL = 0;

    int a = 10, b = 7;

    check(a + b,  17);
    check(a - b,   3);
    check(a & b,   2);
    check(a | b,  15);
    check(a ^ b,  13);
    check(a << 1, 20);
    check(a >> 1,  5);
    check(-a + b, -3);

    int sum = 0;
    for (int i = 1; i <= 10; i++) sum += i;
    check(sum, 55);

    asm volatile("ebreak");
}
