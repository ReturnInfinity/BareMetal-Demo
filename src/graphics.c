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
	// Gather video memory address, x & y resolution, and BPP
	frame_buffer = (unsigned char *)(*(uint64_t *)(0x5080));
	x_res = *(uint16_t *)(0x5088);
	y_res = *(uint16_t *)(0x508A);
	depth = 32;

	//draw a line
	drawline(0, 0, x_res - 1, y_res - 1, 0xFF, 0xFF, 0xFF);
	drawline(0, y_res - 1, x_res - 1, 0, 0xFF, 0xFF, 0xFF);

	// draw a square
	drawline(100, 100, 100, 200, 0xFF, 0xFF, 0xFF);
	drawline(100, 200, 200, 200, 0xFF, 0xFF, 0xFF);
	drawline(200, 200, 200, 100, 0xFF, 0xFF, 0xFF);
	drawline(200, 100, 100, 100, 0xFF, 0xFF, 0xFF);

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
	// Shamelessly adapted from https://stackoverflow.com/questions/10060046/drawing-lines-with-bresenhams-line-algorithm
	int x,y,dx,dy,dx1,dy1,px,py,xe,ye,i;
	dx = x1 - x0;
	dy = y1 - y0;
	dx1 = dx;
	dy1 = dy;
	if (dx1 < 0) // Poor mans abs()
		dx1 = dx1 - dx1 - dx1;
	if (dy1 < 0) // Poor mans abs()
		dy1 = dy1 - dy1 - dy1;
	px = 2 * dy1 - dx1;
	py = 2 * dx1 - dy1;
	if (dy1 <= dx1)
	{
		if(dx >= 0)
		{
			x = x0;
			y = y0;
			xe = x1;
		}
		else
		{
			x = x1;
			y = y1;
			xe = x0;
		}
		putpixel(x, y, red, green, blue);
		for(i=0; x<xe; i++)
		{
			x = x + 1;
			if(px < 0)
			{
				px = px + 2 * dy1;
			}
			else
			{
				if((dx < 0 && dy < 0) || (dx > 0 && dy > 0))
				{
					y = y + 1;
				}
				else
				{
					y = y - 1;
				}
				px = px + 2 * (dy1 - dx1);
			}
			putpixel(x, y, red, green, blue);
		}
	}
	else
	{
		if(dy >= 0)
		{
			x = x0;
			y = y0;
			ye = y1;
		}
		else
		{
			x = x1;
			y = y1;
			ye = y0;
		}
		putpixel(x, y, red, green, blue);
		for(i=0; y<ye; i++)
		{
			y = y + 1;
			if(py <= 0)
			{
				py = py + 2 * dx1;
			}
			else
			{
				if((dx < 0 && dy < 0) || (dx > 0 && dy > 0))
				{
					x = x + 1;
				}
				else
				{
					x = x - 1;
				}
				py = py + 2 * (dx1 - dy1);
			}
			putpixel(x, y, red, green, blue);
		}
	}
}
