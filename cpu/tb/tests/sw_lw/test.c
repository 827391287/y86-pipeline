#define PASS (*(volatile int*)0x2000)   // testbench reads 0x2000 for pass count
#define FAIL (*(volatile int*)0x2004)   // testbench reads 0x2004 for fail count

static inline void check(int got, int expected) {
    if (got == expected) PASS++;
    else                 FAIL++;
}

__attribute__((noinline)) int read_mem(volatile int* p) {
    return *p;
}

void main(void) {
    PASS = 0;
    FAIL = 0;

    volatile int arr[4];

    // store → load 同地址
    arr[0] = 42;
    check(arr[0], 42);

    // 连续写同地址，读最新值
    arr[1] = 10;
    arr[1] = 20;
    check(arr[1], 20);

    // 通过函数读（测 JALR + 访存）
    arr[2] = 99;
    check(read_mem(&arr[2]), 99);

    asm volatile("ebreak");
}
