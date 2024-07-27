#ifndef __MATH_H__
#define __MATH_H__

#include <stdint.h>
typedef unsigned long size_t;
// Function to return the minimum of two floating-point numbers
static inline float fmin(float x, float y) {
    if (x != x) return x; // x is NaN
    if (y != y) return y; // y is NaN
    return (x < y) ? x : y;
}

// Function to return the maximum of two floating-point numbers
static inline float fmax(float x, float y) {
    if (x != x) return x; // x is NaN
    if (y != y) return y; // y is NaN
    return (x > y) ? x : y;
}

// Function to compute the square root of a number using the Newton-Raphson method
static inline float sqrt(float x) {
    if (x < 0) return 0.0 / 0.0; // Return NaN for negative input
    if (x == 0 || x == 1) return x;

    float result = x;
    float delta;
    do {
        float prev_result = result;
        result = 0.5 * (prev_result + x / prev_result);
        delta = prev_result - result;
    } while (delta > 0.00001 || delta < -0.00001);

    return result;
}

// Function to return the largest integer value less than or equal to x
static inline float floor(float x) {
    int32_t xi = (int32_t)x;
    if (x < 0 && x != xi) {
        return (float)(xi - 1);
    }
    return (float)xi;
}

// Function to compute the power of a number with an integer exponent
static inline float pow(float base, int exp) {
    if (exp == 0) return 1;
    if (base == 0) return 0;

    float result = 1;
    int positive_exp = (exp > 0) ? exp : -exp;

    for (int i = 0; i < positive_exp; ++i) {
        result *= base;
    }

    if (exp < 0) result = 1 / result;

    return result;
}

// Function to return the absolute value of an integer
static inline int32_t abs(int32_t x) {
    return (x < 0) ? -x : x;
}

static inline size_t strlen(const char *str) {
    const char *s = str;
    while (*s) {
        s++;
    }
    return s - str;
}
#endif