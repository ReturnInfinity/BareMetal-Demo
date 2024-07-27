#ifndef __PRINTF_H__
#define __PRINTF_H__

#include "../../libBareMetal.h"
#include <stdarg.h>
#include <stddef.h>
#include <stdint.h>
#include <inttypes.h>

void long_to_hex_str(unsigned long num, char* str);
void long_to_str(long num, char* str);
int printf(const char* format, ...);

#ifdef __PRINTF_H_IMPLEMENTATION__
#undef __PRINTF_H_IMPLEMENTATION__

// Helper function to convert a long integer to a string in base 10
void long_to_str(long num, char* str) {
    int i = 0;
    int is_negative = 0;

    // Handle negative numbers
    if (num < 0) {
        is_negative = 1;
        num = -num;
    }

    // Generate digits in reverse order
    do {
        str[i++] = (num % 10) + '0';
        num /= 10;
    } while (num > 0);

    // Add the negative sign if necessary
    if (is_negative) {
        str[i++] = '-';
    }

    // Null-terminate the string
    str[i] = '\0';

    // Reverse the string
    for (int j = 0; j < i / 2; j++) {
        char temp = str[j];
        str[j] = str[i - j - 1];
        str[i - j - 1] = temp;
    }
}

// Helper function to convert a long integer to a string in base 16 (hexadecimal)
void long_to_hex_str(unsigned long num, char* str) {
    int i = 0;
    const char* hex_digits = "0123456789abcdef";

    // Generate hexadecimal digits in reverse order
    do {
        str[i++] = hex_digits[num % 16];
        num /= 16;
    } while (num > 0);

    // Null-terminate the string
    str[i] = '\0';

    // Reverse the string
    for (int j = 0; j < i / 2; j++) {
        char temp = str[j];
        str[j] = str[i - j - 1];
        str[i - j - 1] = temp;
    }
}

// Implementation of printf
int printf(const char* format, ...) {
    char buffer[1024];
    char* str = buffer;
    const char* p;
    va_list args;

    va_start(args, format);

    for (p = format; *p != '\0'; p++) {
        if (*p == '%' && (*(p + 1) == 's' || *(p + 1) == 'd' || *(p + 1) == 'l' || *(p + 1) == 'x' || *(p + 1) == 'p' || *(p + 1) == 'z')) {
            p++;
            if (*p == 's') {
                const char* s = va_arg(args, const char*);
                while (*s) {
                    *str++ = *s++;
                }
            } else if (*p == 'd') {
                int d = va_arg(args, int);
                char num_str[32];
                long_to_str(d, num_str);
                char* ns = num_str;
                while (*ns) {
                    *str++ = *ns++;
                }
            } else if (*p == 'l' && *(p + 1) == 'd') {
                p++;
                long ld = va_arg(args, long);
                char num_str[32];
                long_to_str(ld, num_str);
                char* ns = num_str;
                while (*ns) {
                    *str++ = *ns++;
                }
            } else if (*p == 'x') {
                unsigned int x = va_arg(args, unsigned int);
                char hex_str[32];
                long_to_hex_str(x, hex_str);
                char* hs = hex_str;
                while (*hs) {
                    *str++ = *hs++;
                }
            } else if (*p == 'p') {
                void* ptr = va_arg(args, void*);
                unsigned long ptr_val = (unsigned long)ptr;
                char hex_str[32];
                long_to_hex_str(ptr_val, hex_str);
                char* hs = hex_str;
                while (*hs) {
                    *str++ = *hs++;
                }
            } else if (*p == 'z') {
                size_t sz = va_arg(args, size_t);
                char num_str[32];
                long_to_str((long)sz, num_str); // Cast to long to handle size_t
                char* ns = num_str;
                while (*ns) {
                    *str++ = *ns++;
                }
            }
        } else {
            *str++ = *p;
        }
    }

    *str = '\0';
    va_end(args);

    b_output(buffer, str - buffer);
    return str - buffer;
}

// Implementation of snprintf
int snprintf(char* buffer, size_t n, const char* format, ...) {
    char* str = buffer;
    const char* p;
    va_list args;
    size_t written = 0;

    va_start(args, format);

    for (p = format; *p != '\0'; p++) {
        if (*p == '%' && (*(p + 1) == 's' || *(p + 1) == 'd' || *(p + 1) == 'l' || *(p + 1) == 'x' || *(p + 1) == 'p' || *(p + 1) == 'z')) {
            p++;
            if (*p == 's') {
                const char* s = va_arg(args, const char*);
                while (*s && written < n - 1) {
                    *str++ = *s++;
                    written++;
                }
            } else if (*p == 'd') {
                int d = va_arg(args, int);
                char num_str[32];
                long_to_str(d, num_str);
                char* ns = num_str;
                while (*ns && written < n - 1) {
                    *str++ = *ns++;
                    written++;
                }
            } else if (*p == 'l' && *(p + 1) == 'd') {
                p++;
                long ld = va_arg(args, long);
                char num_str[32];
                long_to_str(ld, num_str);
                char* ns = num_str;
                while (*ns && written < n - 1) {
                    *str++ = *ns++;
                    written++;
                }
            } else if (*p == 'x') {
                unsigned int x = va_arg(args, unsigned int);
                char hex_str[32];
                long_to_hex_str(x, hex_str);
                char* hs = hex_str;
                while (*hs && written < n - 1) {
                    *str++ = *hs++;
                    written++;
                }
            } else if (*p == 'p') {
                void* ptr = va_arg(args, void*);
                unsigned long ptr_val = (unsigned long)ptr;
                char hex_str[32];
                long_to_hex_str(ptr_val, hex_str);
                char* hs = hex_str;
                while (*hs && written < n - 1) {
                    *str++ = *hs++;
                    written++;
                }
            } else if (*p == 'z') {
                size_t sz = va_arg(args, size_t);
                char num_str[32];
                long_to_str((long)sz, num_str); // Cast to long to handle size_t
                char* ns = num_str;
                while (*ns && written < n - 1) {
                    *str++ = *ns++;
                    written++;
                }
            }
        } else {
            if (written < n - 1) {
                *str++ = *p;
                written++;
            }
        }
    }

    // Null-terminate the buffer if there is space
    if (n > 0) {
        *str = '\0';
    }

    va_end(args);

    return written;
}
#endif
#endif