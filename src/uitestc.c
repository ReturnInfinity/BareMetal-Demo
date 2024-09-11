#include "libBareMetal.h"

#define GET_FOREGROUND_COLOR	0x01
#define GET_BACKGROUND_COLOR	0x02
#define GET_CURSOR_ROW		0x03
#define GET_CURSOR_COL		0x04
#define GET_CURSOR_ROW_MAX	0x05
#define GET_CURSOR_COL_MAX	0x06
#define SET_FOREGROUND_COLOR	0x11
#define SET_BACKGROUND_COLOR	0x12
#define SET_CURSOR_ROW		0x13
#define SET_CURSOR_COL		0x14
#define SET_CURSOR_ROW_MAX	0x15
#define SET_CURSOR_COL_MAX	0x16

u64 b_ui(u64 function, u64 var1) {
	u64 tlong;
	asm volatile ("call *0x00100048" : "=a"(tlong) : "c"(function), "a"(var1));
	return tlong;
}

int main(void)
{
	u32 orig_foreground, orig_backgroud;
	orig_foreground = b_ui(GET_FOREGROUND_COLOR, 0);
	orig_backgroud = b_ui(GET_BACKGROUND_COLOR, 0);
	b_ui(SET_FOREGROUND_COLOR, 0x00FF7700);
	b_output("\nHello, world!", 14);
	b_ui(SET_FOREGROUND_COLOR, orig_foreground);
	b_ui(SET_BACKGROUND_COLOR, orig_backgroud);
	return 0;
}
