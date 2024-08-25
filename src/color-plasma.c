#include <stdint.h>
#include "utils/keys.h"
#include "libBareMetal.h"
#include "utils/debug-print.h"
#define size_t uint64_t
#include "utils/math/math.h"
#include "utils/math/vector.h"
#include "utils/memory.h"

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 240

unsigned char *frame_buffer;
unsigned char *video_memory;
unsigned char *cli_save;
uint64_t frameBufferSize;
uint16_t x_res, y_res, offset_x, offset_y;
uint8_t depth;

void putpixel(int x, int y, char red, char green, char blue);
void b_system_delay(unsigned long long delay);
void switchBuffers();
void buildColorPalette();
void plasmaStep(float xShift, float yShift, float radialShift);

typedef struct
{
	unsigned char r, g, b;
} Color;


int main()
{
	// Resolution
	x_res = *(uint16_t *)(0x5088);
	y_res = *(uint16_t *)(0x508A);

	offset_x = (x_res - SCREEN_WIDTH) / 2;
	offset_y = (y_res - SCREEN_HEIGHT) / 2;

	// Gather video memory address, x & y resolution, and BPP
	video_memory = (unsigned char *)(*(uint64_t *)(0x5080));
	depth = 32;
	frameBufferSize = x_res * y_res * 4;
	frame_buffer = (unsigned char *)(0xFFFF800000F00000);
	memset(frame_buffer, 0, frameBufferSize);
	cli_save = (unsigned char *)(0xFFFF800001F00000);

	unsigned char key = 0;
	debug_print("\nResolution %d x", &x_res);
	debug_print(" %d \n", &y_res);
	debug_print("Commands:\nq to go back to shell\nPress SPACE to continue.", 0);

	memcpy(cli_save, video_memory, frameBufferSize); // Save the starting screen state

	while(key != ASCII_SPACE)
	{
		key = b_input();
	}

	key = 0;

	buildColorPalette();

	float shiftX = 0;
	float shiftY = 0;
	float shiftRadial = 0;

	while(key != ASCII_q)
	{
		key = b_input();
		shiftX += 1.0;
		shiftY += 2.0;
		shiftRadial += 3.0;
		plasmaStep(shiftX, shiftY, shiftRadial);
		switchBuffers();
	}

	memcpy(video_memory, cli_save, frameBufferSize); // Restore the original screen
}

static Vec2i screenCenter = {.x = SCREEN_WIDTH / 2, .y = SCREEN_HEIGHT / 2};

static Color colorPalette[255];
static const float colorToPIRelation = PI / 255.0;

void buildColorPalette()
{
	for (int i = 0; i < 255; i++)
	{
		colorPalette[i].r = sin(i * colorToPIRelation * 2) * 128 + 128;
		colorPalette[i].g = sin(i * colorToPIRelation * 3) * 128 + 128;
		colorPalette[i].b = sin(i * colorToPIRelation * 4) * 128 + 128;
	}
}

void drawColorPalette()
{
	for (int i = 0; i < 255; i++)
	{
		putpixel(i, 0, colorPalette[i].r, colorPalette[i].g, colorPalette[i].b);
	}
}

void plasmaStep(float xShift, float yShift, float radialShift)
{
	float components[3] = {0};
	// Column mayor is cache friendly (or the other way around?)
	for (int y = 0; y < SCREEN_HEIGHT; y++)
		for (int x = 0; x < SCREEN_WIDTH; x++)
		{
			unsigned char color[3] = {0};

			components[0] = sin((x + xShift) * 0.1);
			components[1] = sin((x + y + yShift) * 0.01);
			components[2] = sin((vec2i_distance(screenCenter, (Vec2i){x, y}) + radialShift) * 0.3); //sin((vec2i_distance(screenCenter, (Vec2i){x, y}) + radialShift) * 0.3);

			float result = (components[0] + components[1] + components[2]) / 3;

			unsigned char colorIndex = (unsigned char)(result * 128.0 + 128.0);

			putpixel(offset_x + x, offset_y + y, colorPalette[colorIndex].r, colorPalette[colorIndex].g, colorPalette[colorIndex].b);
		}

}

void switchBuffers()
{
	memcpy(video_memory, frame_buffer, frameBufferSize);
}

void b_system_delay(unsigned long long delay) {
	asm volatile ("call *0x00100048" : : "c"(6), "a"(delay));
}

void putpixel(int x, int y, char red, char green, char blue)
{
	int offset = ((y * x_res) + x) * (depth / 8);
	frame_buffer[offset+0] = blue;
	frame_buffer[offset+1] = green;
	frame_buffer[offset+2] = red;
}