#include <stdint.h>
#include "libBareMetal.h"
#include "utils/keys.h"
#include "utils/debug-print.h"
#define size_t uint64_t

void putpixel(int x, int y, char red, char green, char blue);
void drawline(int x0, int y0, int x1, int y1, char red, char green, char blue);

unsigned char *frame_buffer;
unsigned char *video_memory;
unsigned char *cli_save;
uint16_t x_res, y_res;
uint8_t depth;

#define S3L_RESOLUTION_X x_res
#define S3L_RESOLUTION_Y y_res

void usleep(uint64_t microseconds);

#define S3L_PIXEL_FUNCTION drawPixel

#include "utils/small3dlib.h"

void b_system_delay(unsigned long long delay)
{
	asm volatile ("call *0x00100048" : : "c"(6), "a"(delay));
}


void drawPixel(S3L_PixelInfo *p)
{
	char r, g, b;
	if (p->triangleIndex == 0 || p->triangleIndex == 1 || p->triangleIndex == 4 || p->triangleIndex == 5)
	{
		r = 0; g = 255, b = 0;
	}
	else if (p->triangleIndex == 2 || p->triangleIndex == 3 || p->triangleIndex == 6 || p->triangleIndex == 7)
	{
		r = 0; g = 0, b = 255;
	}
	else
	{
		r = 255; g = 0, b = 0;
	}

	putpixel(p->x, p->y, r, g, b);
}

S3L_Unit cubeVertices[] = { S3L_CUBE_VERTICES(S3L_F) };
S3L_Index cubeTriangles[] = { S3L_CUBE_TRIANGLES };

S3L_Model3D cubeModel; // 3D model, has a geometry, position, rotation etc.
S3L_Scene scene;       // scene we'll be rendring (can have multiple models)

uint64_t frameBufferSize;

void *memcpy(void *dest, const void *src, size_t n)
{
	unsigned char *d = (unsigned char *)dest;
	const unsigned char *s = (const unsigned char *)src;

	while (n--) {
		*d++ = *s++;
	}

	return dest;
}

void switchBuffers()
{
	memcpy(video_memory, frame_buffer, frameBufferSize);
}

int main(void)
{
	x_res = *(uint16_t *)(0x5088);
	y_res = *(uint16_t *)(0x508A);
	unsigned char key = 0;
	debug_print("\nResolution %d x", &x_res);
	debug_print(" %d \n", &y_res);
	debug_print("Commands:\nd/a/w/s to rotate the cube\nq to go back to shell\nPress SPACE to continue.", 0);

	while(key != ASCII_SPACE)
	{
		key = b_input();
	}

	// Gather video memory address, x & y resolution, and BPP
	video_memory = (unsigned char *)(*(uint64_t *)(0x5080));

	depth = 32;
	frameBufferSize = x_res * y_res * 4;
	frame_buffer = (unsigned char *)(0xFFFF800000F00000);
	cli_save = (unsigned char *)(0xFFFF800001F00000);
	memcpy(cli_save, video_memory, frameBufferSize); // Save the starting screen state

	S3L_model3DInit(
		cubeVertices,
		S3L_CUBE_VERTEX_COUNT,
		cubeTriangles,
		S3L_CUBE_TRIANGLE_COUNT,
		&cubeModel);

	S3L_sceneInit( // Initialize the scene we'll be rendering.
		&cubeModel,  // This is like an array with only one model in it.
		1,
		&scene);

	// shift the camera a little bit backwards so that it's not inside the cube:
	scene.camera.transform.translation.z = -2 * S3L_F;

	scene.models[0].transform.rotation.y += 45;
	scene.models[0].transform.rotation.x += 45;

	S3L_newFrame(); // has to be called before each frame
	S3L_drawScene(scene);

	int i = 0;
	while(key != ASCII_q && key != ASCII_Q)
	{
		i++;
		key = b_input();

		// clear the screen
		for (int j = 0; j < frameBufferSize; ++j)
		frame_buffer[j] = 0;

		S3L_newFrame();        // has to be called before each frame
		S3L_drawScene(scene);  /* This starts the scene rendering. The drawPixel
								function will be called to draw it. */
		switchBuffers();

		b_system_delay(100000);        // wait a bit to let the user see the frame

		// now move and rotate the cube a little to see some movement:
		switch(key)
		{
			case ASCII_d:
				scene.models[0].transform.rotation.y += 10;
				break;
			case ASCII_a:
				scene.models[0].transform.rotation.y -= 10;
				break;
			case ASCII_s:
				scene.models[0].transform.rotation.x += 10;
				break;
			case ASCII_w:
				scene.models[0].transform.rotation.x -= 10;
				break;
		}
	}
	memcpy(video_memory, cli_save, frameBufferSize); // Restore the original screen
}

void putpixel(int x, int y, char red, char green, char blue)
{
	int offset = ((y * x_res) + x) * (depth / 8);
	frame_buffer[offset+0] = blue;
	frame_buffer[offset+1] = green;
	frame_buffer[offset+2] = red;
}
