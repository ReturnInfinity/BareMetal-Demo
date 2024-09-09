/*

Customized Ray Tracer for BareMetal OS

Based on Andrew Kensler's business card sized ray tracer
Breakdown by Fabien Sanglard here: https://fabiensanglard.net/rayTracing_back_of_business_card/

- Converted from C++ to C
- Uses built-in functions for pow, sqrt, ceil, and rand

Upon execution it will render the image directly to the screen
The first run will use only one CPU core
The second run will use all available CPU cores

*/

#include "libBareMetal.h"

#define R1 1103515245
#define R2 12345
#define R3 2147483648 // 2^31
#define RAND_MAX 32767

typedef int i;
typedef float f;
u8 *frame_buffer;
u16 X, Y;
u32 progress = 0;
u64 next = 1; // For rand()
u64 lock = 0, TOTALCORES = 0, BSP;

// Custom pow
double bpow(double x, double y) {
	double result = 1.0;
	i neg_exp_flag = 0;

	if (y < 0) {
		neg_exp_flag = 1;
		y = -y;
	}

	for (i c=0; c < y; c++)
		result *= x;

	if (neg_exp_flag)
		result = 1.0 / result;

	return result;
}

// Custom sqrt
double bsqrt(double num) {
	if (num < 0)
		return -1;

	double e = 0.00001;
	double guess = num / 2.0;

	while (1) {
		double new_guess = 0.5 * (guess + num / guess);

		if (guess - new_guess < e && guess - new_guess > -e)
			break;

		guess = new_guess;
	}

	return guess;
}

// Custom ceil
double bceil(double num) {
	double part = (i)num;
	if (num > part)
		return part + 1;
	else
		return part;
}

// Custom rand
uint64_t rand() {
	next = (R1 * next + R2) % R3;
	return next % (RAND_MAX + 1);
}

// Vector Structure
typedef struct {
	f x, y, z;
} vector;

// Vector Add
vector v_add(vector a, vector b) {
	vector result = {a.x + b.x, a.y + b.y, a.z + b.z};
	return result;
}

// Vector Multiply/Scale
vector v_mul(vector a, f b) {
	vector result = { a.x * b, a.y * b, a.z * b };
	return result;
}

// Vector Dot Product
f v_dot(vector a, vector b) {
	return a.x * b.x + a.y * b.y + a.z * b.z;
}

// Vector Cross-Product
vector v_cross(vector a, vector b) {
	vector result = {a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x};
	return result;
}

// Vector Normalize
vector v_norm(vector a) {
	f mag = bsqrt(v_dot(a, a));
	return v_mul(a, 1 / mag);
}

// Vector Initialization
vector v_init(f a, f b, f c) {
	vector result = {a, b, c};
	return result;
}

// Array of spheres (displaying 'Hi!')
i G[] = {280336, 279040, 279040, 279056, 509456, 278544, 278544, 279056, 278544};

// Random generator, return a float within range [0-1]
f R() {
	return (f)rand() / RAND_MAX;
}

// Tracer
// Return 0 if no hit was found but ray goes up
// Return 1 if no hit was found but ray goes down
// Return 2 if a hit was found (and also return distance t and bouncing ray n)
i T(vector o, vector d, f *t, vector *n) {
	*t = 1e9;
	i m = 0;
	f p = -o.z / d.z;
	if (.01 < p) {
		*t = p;
		*n = v_init(0, 0, 1);
		m = 1;
	}

	for (i k = 19; k--;)
		for (i j = 9; j--;)
			if (G[j] & 1 << k) {
				vector p = v_add(o, v_init(-k, 0, -j - 4));
				f b = v_dot(p, d), c = v_dot(p, p) - 1, q = b * b - c;
				if (q > 0) {
					f s = -b - bsqrt(q);
					if (s < *t && s > .01) {
						*t = s;
						*n = v_norm(v_add(p, v_mul(d, *t)));
						m = 2;
					}
				}
			}

	return m;
}

// Sampler
// Return the pixel color for a ray passing by point o (origin) and d (direction)
vector S(vector o, vector d) {
	f t;
	vector n;
	i m = T(o, d, &t, &n);

	// Generate a sky color if no sphere is hit and the ray goes up
	if (!m)
		return v_mul(v_init(.7, .6, 1), bpow(1 - d.z, 4));

	vector h = v_add(o, v_mul(d, t));
	vector l = v_norm(v_add(v_init(9 + R(), 9 + R(), 16), v_mul(h, -1)));
	vector r = v_add(d, v_mul(n, v_dot(n, d) * -2));
	f b = v_dot(l, n);
	if (b < 0 || T(h, l, &t, &n))
		b = 0;

	f p = bpow(v_dot(l, r) * (b > 0), 99);

	// Generate a floor color if no sphere is hit and the ray goes down
	if (m & 1) {
		h = v_mul(h, .2);
		return v_mul(((i)(bceil(h.x) + bceil(h.y)) & 1) ? v_init(3, 1, 1) : v_init(3, 3, 3), b * .2 + .1);
	}

	// A sphere was hit.
	return v_add(v_init(p, p, p), v_mul(S(h, r), .5));
}

int render()
{
	b_system(SMP_LOCK, lock, 0);
	int y = progress++; // Starting line number
	b_system(SMP_UNLOCK, lock, 0);
	vector g = v_norm(v_init(5, -28, 7)); // Camera direction (-/+ = Right/Left, ?/? , Down/Up)
	vector a = v_mul(v_norm(v_cross(v_init(0, 0, -1), g)), .002); // Camera up vector
	vector b = v_mul(v_norm(v_cross(g, a)), .002);
	vector c = v_add(v_add(v_mul(a, -256), v_mul(b, -256)), g);

	for (; y<Y; y+=TOTALCORES) // Increment by the number of CPUs
		for (i x = 0; x<X; x++) {
			int offset = (y * X + x) * 4; // Calculate the offset into video memory for this line

			vector p = v_init(13, 13, 13); // Reuse the vector class to store the RGB values of a pixel
			for (i r = 64; r--;) {
				vector t = v_add(v_mul(a, (R() - .5) * 99), v_mul(b, (R() - .5) * 99));
				p = v_add(v_mul(S(v_add(v_init(17, 16, 8), t), v_norm(v_add(v_mul(t, -1), v_mul(v_add(v_add(v_mul(a, R() + x), v_mul(b, y + R())), c), 16)))), 3.5), p);
			}

			frame_buffer[offset++] = (i)p.z; // Output RGB values directly to video memory
			frame_buffer[offset++] = (i)p.y;
			frame_buffer[offset++] = (i)p.x;
			frame_buffer[offset++] = 0;
		}
}

void cls()
{
	u8 pixel = 0x40;
	for (int bytes = 0; bytes < (X * Y * 4); bytes++)
		frame_buffer[bytes] = pixel;
}

int main() {
	frame_buffer = (u8 *)b_system(SCREEN_LFB_GET, 0, 0); // Frame buffer address from kernel
	X = b_system(SCREEN_X_GET, 0, 0); // Screen X
	Y = b_system(SCREEN_Y_GET, 0, 0); // Screen Y
	int tcore;
	u8 c;
	int busy;

	b_output("\nraytrace - First run will be using 1 CPU core\nPress any key to continue", 72);

	c = 0;
	do {
		c = b_input();
	} while (c == 0);

	cls();

	TOTALCORES = 1;
	render();

	TOTALCORES = b_system(SMP_NUMCORES, 0, 0); // Total cores in the system
	BSP = b_system(SMP_ID, 0, 0); // ID of the BSP

	b_output("\nRender complete. Second run will use all CPU cores\nPress any key to continue", 77);

	c = 0;
	do {
		c = b_input();
	} while (c == 0);

	cls();

	for (int t=0; t<TOTALCORES; t++)
	{
		tcore = *(u8 *)(0x5100+t); // Location of the Active CPU IDs
		if (tcore != BSP)
			b_system(SMP_SET, (u64)render, tcore); // Have each AP render
	}
	render(); // Have the BSP render as well

	// Wait for all other cores to be finished
	do {
		busy = b_system(SMP_BUSY, 0, 0);
	} while (busy == 1);

	b_output("\nRender complete. Press any key to exit", 39);

	c = 0;
	do {
		c = b_input();
	} while (c == 0);

	cls();

	return 0;
}

// EOF
