#ifndef  __RAND_H__
#define __RAND_H__

#include <stdint.h>
// State for the PRNG
static uint32_t seed = 1; // Initial seed value

// Function to seed the PRNG
static inline void srand(uint32_t s) {
    seed = s;
}

// Function to generate a pseudo-random number using the LCG algorithm
static inline int rand() {
    seed = (1103515245 * seed + 12345) % 0x80000000;
    return (int)(seed & 0x7FFFFFFF);
}

#endif
