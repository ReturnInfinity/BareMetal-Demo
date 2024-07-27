#ifndef __STACK_ALLOCATOR_H__
#define __STACK_ALLOCATOR_H__

/**
 * StackAllocator is a custom allocator that returns pointers to a memory arena and grows itself 
 * when is asked to reserve more memory than capacity.
 * 
 * Using _this type of custom allocator has the following advantages over using malloc and free
 * in a clasical way:
 * 
 * 1. Allocate memory and free memory takes time because the operative system need to do bookkeeping
 * of the memory that was allocated. Using a StackAllocator with a reasonable gessed initial size
 * will avoid the cycle of alloc/free removing the performance penalty.
 * 
 * 2. Memory fragmentation is reduced, specially when working with a lot of small objects.
 * 
 * 3. You can handle process that requires allocate and free memory in a more maintainable way
 * you create the StackAllocator in at the start of the process(let's say, in the begining of the
 * asset loading routine) allocate how many objects you need, and they you free only the allocator.
 * Reducing the stress to the operative system and the memory fragmentation for your program.
 * 
 */

#include <stdint.h>
#define size_t uint64_t

typedef struct
{
    size_t capacity;
    size_t length;
    int allocationCount;
} StackAllocatorHeader;

typedef struct
{
    StackAllocatorHeader header;
    char data[1];
} StackAllocator;

StackAllocator *stackAllocatorCreateP(void* stackBase);
StackAllocator *stackAllocatorCreate();
void *stackAllocatorAlloc(StackAllocator *_this, size_t size);
void stackAllocatorReset(StackAllocator *_this);
void stackAllocatorFree(StackAllocator *_this);
void *stackAllocatorRealloc(StackAllocator *_this, void *pointer, size_t size);
void *memcpy(void *dest, const void *src, size_t n);

#ifdef __STACK_ALLOC_IMPLEMENTATION__
#undef __STACK_ALLOC_IMPLEMENTATION__

void *memcpy(void *dest, const void *src, size_t n) {
    unsigned char *d = (unsigned char *)dest;
    const unsigned char *s = (const unsigned char *)src;

    while (n--) {
        *d++ = *s++;
    }

    return dest;
}

StackAllocator *stackAllocatorCreateP(void* stackBase)
{
	printf("WHAT?\n");
	char test[500];
	printf("address %p\n", test);
    StackAllocator *_this = (StackAllocator *)((stackBase));
	printf("address %p\n", _this);
	printf("WHAT2?\n");

    if (!_this)
    {
        printf("Error creating stack allocator %s::%d\n", __FILE__, __LINE__);
        return NULL;
    }
	printf("WHAT3?\n");
    _this->header.capacity = UINT32_MAX;
	printf("WHAT4?\n");
	printf("Stack allocator created with capacity of %z\n", _this->header.capacity);
	printf("WHAT5?\n");

    return _this;
}

StackAllocator *stackAllocatorCreate()
{
	printf("WHAT?\n");
	char test[500];
	printf("address %p\n", test);
														  //0xFFFF800000000000
    StackAllocator *_this = (StackAllocator *)((uint64_t *)(0xFFFFFFFFFF000000));
	printf("address %p\n", _this);
	printf("WHAT2?\n");

    if (!_this)
    {
        printf("Error creating stack allocator %s::%d\n", __FILE__, __LINE__);
        return NULL;
    }
	printf("WHAT3?\n");
    _this->header.capacity = 0xff;
	printf("WHAT4?\n");
	printf("Stack allocator created with capacity of %d", _this->header.capacity);
	printf("WHAT5?\n");

    return _this;
}

void *stackAllocatorAlloc(StackAllocator *_this, size_t size)
{
    if (_this->header.length + size > _this->header.capacity)
    {
        // TODO: realloc will invalidate all the pointers provided before.
        // For now, we just abort the program, in the future we should create
        // A handle table
        printf("Allocator ran out of space.\nActual capacity %ld\nRequired capacity %ld\n", _this->header.capacity, _this->header.capacity + size);
        return NULL;
    }
    void *returnValue = &_this->data[_this->header.length];
    _this->header.length += size;
    _this->header.allocationCount++;
    return returnValue;
}

void stackAllocatorReset(StackAllocator *_this)
{
    _this->header.length = 0;
}

void stackAllocatorFree(StackAllocator *_this)
{
    _this->header.allocationCount--;
    if (_this->header.allocationCount <= 0)
    {
        stackAllocatorReset(_this);
    }
}

void *stackAllocatorRealloc(StackAllocator *_this, void *pointer, size_t size)
{
    void *returnValue = stackAllocatorAlloc(_this, size);

    if (pointer != NULL)
        memcpy(returnValue, pointer, size);

    return returnValue;
}

static StackAllocator *stackAllocator;

// unsigned char buffer[1920255] = {0};

void staticAllocatorInit()
{
    stackAllocator = stackAllocatorCreateP(((uint64_t *)(0xFFFF800000F00000)));
}

void *allocStatic(size_t size)
{
    void *returnValue = stackAllocatorAlloc(stackAllocator, size);
    return returnValue;
}
void *reallocStatic(void *this, size_t size)
{
    void *returnValue = stackAllocatorRealloc(stackAllocator, this, size);
    return returnValue;
}

void freeStatic(void *this)
{
    if (this == NULL)
        return;
    stackAllocatorFree(stackAllocator);
}

void staticAllocatorDestroy()
{

}

#endif


#endif