/* Simple graphics test */

// gcc -c -m64 -nostdlib -nostartfiles -nodefaultlibs -o graphics.o graphics.c
// ld -T c.ld -o graphics.app graphics.o

#include <stdint.h>

void putpixel(int x, int y, char red, char green, char blue);
void drawline(int x0, int y0, int x1, int y1, char red, char green, char blue);

unsigned char *frame_buffer;
uint16_t x_res, y_res;
uint8_t depth;

int main(void)
{
	// Gather video memory address, x & y resoultion, and BPP 
	frame_buffer = (unsigned char *)((uint64_t)(*(uint32_t *)(0x5080)));
	x_res = *(uint16_t *)(0x5084);
	y_res = *(uint16_t *)(0x5086);
	depth = *(uint8_t *)(0x5088);

	//draw a line
	drawline(0, 0, 700, 700, 0xFF, 0xFF, 0xFF);
	drawline(0, 0, 700, 100, 0xFF, 0xFF, 0xFF);

	// draw a square
	drawline(100, 100, 100, 200, 0xFF, 0xFF, 0xFF);
	drawline(100, 200, 200, 200, 0xFF, 0xFF, 0xFF);
	drawline(200, 200, 200, 100, 0xFF, 0xFF, 0xFF);
	drawline(100, 100, 200, 100, 0xFF, 0xFF, 0xFF);

}

void putpixel(int x, int y, char red, char green, char blue)
{
	int offset = ((y * x_res) + x) * (depth / 8);
	frame_buffer[offset+0] = blue;
	frame_buffer[offset+1] = green;
	frame_buffer[offset+2] = red;
}

void drawline(int x0, int y0, int x1, int y1, char red, char green, char blue)
{
	int dx, dy, p, x, y;
	dx = x1 - x0;
	dy = y1 - y0;
	x = x0;
	y = y0;
	p = 2 * dy - dx;
	while (x < x1)
	{
		if (p >= 0)
		{
			putpixel(x, y, red, green, blue);
			y += 1;
			p = p + 2 * dy - 2 * dx;
		}
		else
		{
			putpixel(x, y, red, green, blue);
			p = p + 2 * dy;
		}
		x += 1;
	}
}
