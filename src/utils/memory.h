#ifndef __MEMORY_H__
#define __MEMORY_H__

void *memcpy(void *dest, const void *src, size_t n) {
	unsigned char *d = (unsigned char *)dest;
	const unsigned char *s = (const unsigned char *)src;

	while (n--) {
		*d++ = *s++;
	}

	return dest;
}

// Function to set a block of memory to a specified value
static inline void *memset(void *s, int c, unsigned long n) {
	unsigned char *p = (unsigned char *)s;
	while (n--) {
		*p++ = (unsigned char)c;
	}
	return s;
}
#endif
