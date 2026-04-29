#define PASS (*(volatile int*)0x2000)   // testbench reads 0x2000 for pass count
#define FAIL (*(volatile int*)0x2004)   // testbench reads 0x2004 for fail count

static inline void check(int got, int expected) {
    if (got == expected) PASS++;
    else                 FAIL++;
}


void main(void)
{
    PASS = 0;
    FAIL = 0;

    int a , b , c , d , e ,f;
    a = 1;
    b = 2;

    c = a + b;
    d = c + b;
    f = c + d;

    check(c , 3);
    check(d , 5);
    check(f , 8);

    asm volatile("ebreak");
}