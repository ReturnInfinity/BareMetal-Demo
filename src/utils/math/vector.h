/*
 * vector.h - 2D and 3D Vector Library in C99
 * Author: Pablo Weremczuk
 *
 * This file is offered freely and can be used by anyone for any purpose,
 * without any restrictions. It is provided "as is", without warranty of any kind.
 */

#ifndef VECTOR_H
#define VECTOR_H

#include <stdint.h>  // For integer types
#include <stdbool.h> // For bool type

// Internal helper function to calculate square root using the Newton-Raphson method
static float sqrt_approx(float x) {
    if(x == 0.0) return 0;
    float guess = x / 2.0f;
    float epsilon = 0.00001f;
    while ((guess * guess) - x > epsilon || (guess * guess) - x < -epsilon) {
        guess = (guess + x / guess) / 2.0f;
    }
    return guess;
}

// Internal helper function to calculate absolute value for floating point numbers
static float fabs_approx(float x) {
    return (x < 0) ? -x : x;
}

// 2D Integer Vector Structure
typedef struct {
    int32_t x, y;
} Vec2i;

// 2D Floating Point Vector Structure
typedef struct {
    float x, y;
} Vec2f;

// 3D Integer Vector Structure
typedef struct {
    int32_t x, y, z;
} Vec3i;

// 3D Floating Point Vector Structure
typedef struct {
    float x, y, z;
} Vec3f;

/* ========== 2D Integer Vector Functions ========== */

// Add two 2D integer vectors
Vec2i vec2i_add(Vec2i v1, Vec2i v2) {
    return (Vec2i){v1.x + v2.x, v1.y + v2.y};
}

// Subtract one 2D integer vector from another
Vec2i vec2i_sub(Vec2i v1, Vec2i v2) {
    return (Vec2i){v1.x - v2.x, v1.y - v2.y};
}

// Scale a 2D integer vector by a scalar
Vec2i vec2i_scale(Vec2i v, int32_t scalar) {
    return (Vec2i){v.x * scalar, v.y * scalar};
}

// Calculate the length (magnitude) of a 2D integer vector
float vec2i_length(Vec2i v) {
    return sqrt((float)(v.x * v.x + v.y * v.y));
}

// Calculate the distance between two 2D integer vectors
float vec2i_distance(Vec2i v1, Vec2i v2) {
    return vec2i_length((Vec2i){v1.x - v2.x, v1.y - v2.y});
}

/* ========== 2D Floating Point Vector Functions ========== */

// Add two 2D floating point vectors
Vec2f vec2f_add(Vec2f v1, Vec2f v2) {
    return (Vec2f){v1.x + v2.x, v1.y + v2.y};
}

// Subtract one 2D floating point vector from another
Vec2f vec2f_sub(Vec2f v1, Vec2f v2) {
    return (Vec2f){v1.x - v2.x, v1.y - v2.y};
}

// Scale a 2D floating point vector by a scalar
Vec2f vec2f_scale(Vec2f v, float scalar) {
    return (Vec2f){v.x * scalar, v.y * scalar};
}

// Calculate the length (magnitude) of a 2D floating point vector
float vec2f_length(Vec2f v) {
    return sqrt_approx(v.x * v.x + v.y * v.y);
}

// Normalize a 2D floating point vector (if possible)
Vec2f vec2f_normalize(Vec2f v) {
    float length = vec2f_length(v);
    if (length == 0.0f) {
        return (Vec2f){0.0f, 0.0f}; // Cannot normalize a zero-length vector
    }
    return (Vec2f){v.x / length, v.y / length};
}

// Calculate the distance between two 2D floating point vectors
float vec2f_distance(Vec2f v1, Vec2f v2) {
    return vec2f_length((Vec2f){v1.x - v2.x, v1.y - v2.y});
}

/* ========== 3D Integer Vector Functions ========== */

// Add two 3D integer vectors
Vec3i vec3i_add(Vec3i v1, Vec3i v2) {
    return (Vec3i){v1.x + v2.x, v1.y + v2.y, v1.z + v2.z};
}

// Subtract one 3D integer vector from another
Vec3i vec3i_sub(Vec3i v1, Vec3i v2) {
    return (Vec3i){v1.x - v2.x, v1.y - v2.y, v1.z - v2.z};
}

// Scale a 3D integer vector by a scalar
Vec3i vec3i_scale(Vec3i v, int32_t scalar) {
    return (Vec3i){v.x * scalar, v.y * scalar, v.z * scalar};
}

// Calculate the length (magnitude) of a 3D integer vector
float vec3i_length(Vec3i v) {
    return sqrt_approx((float)(v.x * v.x + v.y * v.y + v.z * v.z));
}

// Calculate the distance between two 3D integer vectors
float vec3i_distance(Vec3i v1, Vec3i v2) {
    return vec3i_length((Vec3i){v1.x - v2.x, v1.y - v2.y, v1.z - v2.z});
}

/* ========== 3D Floating Point Vector Functions ========== */

// Add two 3D floating point vectors
Vec3f vec3f_add(Vec3f v1, Vec3f v2) {
    return (Vec3f){v1.x + v2.x, v1.y + v2.y, v1.z + v2.z};
}

// Subtract one 3D floating point vector from another
Vec3f vec3f_sub(Vec3f v1, Vec3f v2) {
    return (Vec3f){v1.x - v2.x, v1.y - v2.y, v1.z - v2.z};
}

// Scale a 3D floating point vector by a scalar
Vec3f vec3f_scale(Vec3f v, float scalar) {
    return (Vec3f){v.x * scalar, v.y * scalar, v.z * scalar};
}

// Calculate the length (magnitude) of a 3D floating point vector
float vec3f_length(Vec3f v) {
    return sqrt_approx(v.x * v.x + v.y * v.y + v.z * v.z);
}

// Normalize a 3D floating point vector (if possible)
Vec3f vec3f_normalize(Vec3f v) {
    float length = vec3f_length(v);
    if (length == 0.0f) {
        return (Vec3f){0.0f, 0.0f, 0.0f}; // Cannot normalize a zero-length vector
    }
    return (Vec3f){v.x / length, v.y / length, v.z / length};
}

// Calculate the distance between two 3D floating point vectors
float vec3f_distance(Vec3f v1, Vec3f v2) {
    return vec3f_length((Vec3f){v1.x - v2.x, v1.y - v2.y, v1.z - v2.z});
}

#endif // VECTOR_H
