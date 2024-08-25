#ifndef DEBUG_PRINT_H
#define DEBUG_PRINT_H
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

void long_to_str(int64_t num, char* str) {
    int64_t i = 0;
    int64_t is_negative = 0;

    if (num < 0) {
        is_negative = 1;
        num = -num;
    }

    do {
        str[i++] = (num % 10) + '0';
        num /= 10;
    } while (num > 0);

    if (is_negative) {
        str[i++] = '-';
    }

    str[i] = '\0';

    // Reverse the string
    for (int j = 0; j < i / 2; j++) {
        char temp = str[j];
        str[j] = str[i - j - 1];
        str[i - j - 1] = temp;
    }
}

void int_to_str(int16_t num, char* str) {
    long_to_str(num, str);  // Reuse long_to_str as int is a subset of long
}

void float_to_str(float num, char* str, int precision) {
    // Handling negative numbers
    int i = 0;
    if (num < 0) {
        str[i++] = '-';
        num = -num;
    }

    // Extract the integer part
    int int_part = (int)num;
    float fraction = num - (float)int_part;

    // Convert integer part to string
    int_to_str(int_part, str + i);
    while (str[i] != '\0') i++;  // Move index to end of integer part

    // Add decimal point
    str[i++] = '.';

    // Handle fractional part up to given precision
    for (int j = 0; j < precision; j++) {
        fraction *= 10;
        int frac_digit = (int)fraction;
        str[i++] = frac_digit + '0';
        fraction -= frac_digit;
    }

    str[i] = '\0';
}

void hex_to_str(unsigned long num, char* str) {
    const char* hex_digits = "0123456789abcdef";
    int i = 0;

    do {
        str[i++] = hex_digits[num % 16];
        num /= 16;
    } while (num > 0);

    str[i] = '\0';

    // Reverse the string
    for (int j = 0; j < i / 2; j++) {
        char temp = str[j];
        str[j] = str[i - j - 1];
        str[i - j - 1] = temp;
    }
}

int debug_print(const char* format, void* param) {
    char buffer[1024];
    char* str = buffer;
    const char* p;

    for (p = format; *p != '\0'; p++) {
        if (*p == '%' && (*(p + 1) == 's' || *(p + 1) == 'd' || *(p + 1) == 'l' ||
                          *(p + 1) == 'f' || *(p + 1) == 'x' || *(p + 1) == 'p' ||
                          *(p + 1) == 'z')) {
            p++;
            if (*p == 's') {
                const char* s = (const char*) param;
                while (*s) {
                    *str++ = *s++;
                }
            } else if (*p == 'd') {
                int16_t d = *((int16_t *)param);
                char num_str[32];
                int_to_str(d, num_str);
                char* ns = num_str;
                while (*ns) {
                    *str++ = *ns++;
                }
            } else if (*p == 'l' && *(p + 1) == 'd') {
                p++;
                long ld = *((long *)param);
                char num_str[32];
                long_to_str(ld, num_str);
                char* ns = num_str;
                while (*ns) {
                    *str++ = *ns++;
                }
            } else if (*p == 'f') {
                float f = *((float *)param);
                char num_str[64];
                float_to_str((float)f, num_str, 6);  // Default to 6 decimal places
                char* ns = num_str;
                while (*ns) {
                    *str++ = *ns++;
                }
            } else if (*p == 'x') {
                unsigned int x = *((unsigned int *)param);
                char num_str[32];
                hex_to_str(x, num_str);
                char* ns = num_str;
                while (*ns) {
                    *str++ = *ns++;
                }
            } else if (*p == 'p') {
                void* ptr = param;
                char num_str[32];
                hex_to_str((unsigned long)ptr, num_str);
                *str++ = '0';
                *str++ = 'x';
                char* ns = num_str;
                while (*ns) {
                    *str++ = *ns++;
                }
            } else if (*p == 'z') {
                size_t z = *((size_t *)param);
                char num_str[32];
                long_to_str((long)z, num_str);
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

    b_output(buffer, str - buffer);
    return str - buffer;
}

void testdebug_print(void)
{
    int integer = -12345;
    long long_integer = 1234567890L;
    float floating = 3.141592;
    unsigned int hex_num = 0xABCD1234;
    const char* string = "Hello, world!";
    void* pointer = (void*)string;
    size_t size = sizeof(pointer);

    debug_print("Integer: %d\n", &integer);
    debug_print("Long integer: %ld\n", &long_integer);
    debug_print("Float: %f\n", &floating);
    debug_print("Hexadecimal: %x\n", &hex_num);
    debug_print("Pointer: %p\n", &pointer);
    debug_print("String: %s\n", &string);
    debug_print("Size_t: %z\n", &size);
}

#endif // UEFI_PRINTF_H
