
typedef unsigned int size_t;

// This is a basic wasm memory allocator, always leaking memory.

unsigned char heap[1073741824] = { 0 };
size_t offset = 0;

int posix_memalign(void **memptr, size_t alignment, size_t size) {
    *memptr = &heap[offset];
    offset += size;
    return 0;
}

void free(void *_Nullable ptr) {
    // :)
}

unsigned long __stack_chk_guard = 0x1;
void __stack_chk_guard_setup(void) {}
void __stack_chk_fail(void) {}
