#ifndef UEFI_PRINTF_H
#define UEFI_PRINTF_H

#include <stdint.h>
#include <stdarg.h>
#include <stdbool.h>

// Helper function to reverse a string
static void reverse(char *str, int length) {
    int start = 0;
    int end = length - 1;
    while (start < end) {
        char temp = str[start];
        str[start] = str[end];
        str[end] = temp;
        start++;
        end--;
    }
}

// Helper function to convert integer to string
static int intToStr(int num, char *str, int base, bool isUnsigned) {
    int i = 0;
    bool isNegative = false;

    if (num == 0) {
        str[i++] = '0';
        str[i] = '\0';
        return i;
    }

    if (base == 10 && !isUnsigned && num < 0) {
        isNegative = true;
        num = -num;
    }

    while (num != 0) {
        int rem = num % base;
        str[i++] = (rem > 9) ? (rem - 10) + 'a' : rem + '0';
        num = num / base;
    }

    if (isNegative) {
        str[i++] = '-';
    }

    str[i] = '\0';
    reverse(str, i);
    return i;
}

// Helper function to convert float to string
static int floatToStr(double num, char *str, int precision) {
    int i = 0;

    if (num < 0) {
        str[i++] = '-';
        num = -num;
    }

    int intPart = (int)num;
    double fractionPart = num - (double)intPart;

    i += intToStr(intPart, str + i, 10, true);

    if (precision > 0) {
        str[i++] = '.';

        fractionPart *= 10 * precision;
        i += intToStr((int)fractionPart, str + i, 10, true);
    }

    str[i] = '\0';
    return i;
}

// snprintf function implementation
static int snprintf(char *buffer, unsigned long n, const char *format, ...) {
    va_list args;
    va_start(args, format);

    unsigned long written = 0;
    const char *ptr = format;
    while (*ptr != '\0' && written < n) {
        if (*ptr == '%') {
            ptr++;
            char numStr[32];
            int len = 0;

            switch (*ptr) {
                case 'd': {
                    int num = va_arg(args, int);
                    len = intToStr(num, numStr, 10, false);
                    break;
                }
                case 'x': {
                    int num = va_arg(args, int);
                    len = intToStr(num, numStr, 16, true);
                    break;
                }
                case 'p': {
                    uintptr_t ptrVal = (uintptr_t)va_arg(args, void *);
                    len = intToStr(ptrVal, numStr, 16, true);
                    break;
                }
                case 's': {
                    const char *str = va_arg(args, const char *);
                    while (*str != '\0' && written < n) {
                        buffer[written++] = *str++;
                    }
                    ptr++;
                    continue;
                }
                case 'f': {
                    double num = va_arg(args, double);
                    len = floatToStr(num, numStr, 6); // Default precision of 6
                    break;
                }
                case 'z': { // size_t
                    if (*(ptr + 1) == 'u') {
                        ptr++;
                        unsigned long num = va_arg(args, unsigned long);
                        len = intToStr(num, numStr, 10, true);
                    }
                    break;
                }
                case 'l': {
                    if (*(ptr + 1) == 'd') {
                        ptr++;
                        long num = va_arg(args, long);
                        len = intToStr(num, numStr, 10, false);
                    }
                    break;
                }
                default:
                    buffer[written++] = '%';
                    buffer[written++] = *ptr;
                    ptr++;
                    continue;
            }

            if (len + written < n) {
                for (int i = 0; i < len; i++) {
                    buffer[written++] = numStr[i];
                }
            }

            ptr++;
        } else {
            buffer[written++] = *ptr++;
        }
    }

    va_end(args);

    if (written < n) {
        buffer[written] = '\0';
    } else if (n > 0) {
        buffer[n - 1] = '\0';
    }

    return (int)written;
}

// printf function implementation using snprintf
static int printf(const char *format, ...) {
    char buffer[1024]; // Buffer to store the formatted string
    va_list args;
    va_start(args, format);

    int ret = snprintf(buffer, sizeof(buffer), format, args);

    va_end(args);

    // Output the string using the b_output function
    b_output(buffer, (unsigned long)ret);

    return ret;
}

#endif // UEFI_PRINTF_H
