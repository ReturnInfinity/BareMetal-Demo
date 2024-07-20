// Modified IOCCC Ray Tracer from Anders Gavare
// https://www.ioccc.org/2004/gavare.c (see https://www.ioccc.org/2004/gavare.hint also)

// gcc -c -m64 -nostdlib -nostartfiles -nodefaultlibs -o gavare.o gavare.c
// ld -T c.ld -o gavare.app gavare.o

#include <stdint.h>

unsigned char *frame_buffer;
int offset = 0;
int X = 1024;
int Y = 768;
int BPP = 32;
int A = 3; // Anti-alias value, 1 to disable

int J = 0;
int K = -10;
int L = -7;
int M = 1296;
int N = 36;
int O = 255;
int P = 9;
int _ = 1 << 15;
int E, S, C, D, p, Z, W, Q, T, U, u, v, w, R, G, B;

int F(int b);
int I(int x, int Y, int X);
int H(int x);
int q(int c, int x, int y, int z, int k, int l, int m, int a, int b);
int o(int c, int x, int y, int z, int k, int l, int m, int a);
int n(int e, int f, int g, int h, int i, int j, int d, int a, int b, int V);
int t(int x, int y, int a, int b);
int r(int x, int y);

int main() {
	int x, y;
	frame_buffer = (unsigned char *)(*(uint64_t *)(0x5080));
	X = *(uint16_t *)(0x5088);
	Y = *(uint16_t *)(0x508A);
	for (y=0; y<Y; y++)
		for (x=0; x<X; x++)
			r(x, y); // render each pixel
}

int F(int b) {
	E = "1111886:6:??AAFFHHMMOO55557799@@>>>BBBGGIIKK" [b] - 64;
	C = "C@=::C@@==@=:C@=:C@=:C531/513/5131/31/531/53" [b] - 64;
	S = b < 22 ? 9 : 0;
	D = 2;
}

int I(int x, int Y, int X) {
	Y ? (X ^= Y, X * X > x ? (X ^= Y) : 0, I(x, Y / 2, X)) : (E = X);
}

int H(int x) {
	I(x, _, 0);
}

int q(int c, int x, int y, int z, int k, int l, int m, int a, int b) {
	F(c);
	x -= E * M;
	y -= S * M;
	z -= C * M;
	b = x * x / M + y * y / M + z * z / M - D * D * M;
	a = -x * k / M - y * l / M - z * m / M;
	p = ((b = a * a / M - b) >= 0 ? (I(b * M, _, 0), b = E, a + (a > b ? -b : b)) : -1.0);
}

int o(int c, int x, int y, int z, int k, int l, int m, int a) {
	Z = !c ? -1 : Z;
	c < 44 ? (q(c, x, y, z, k, l, m, 0, 0), (p > 0 && c != a && (p < W || Z < 0)) ? (W = p, Z = c) : 0, o(c + 1, x, y, z, k, l, m, a)) : 0;
}

int n(int e, int f, int g, int h, int i, int j, int d, int a, int b, int V) {
	o(0, e, f, g, h, i, j, a);
	d > 0 && Z >= 0 ? (e += h * W / M, f += i * W / M, g += j * W / M, F(Z), u = e - E * M, v = f - S * M, w = g - C * M, b = (-2 * u - 2 * v + w) / 3, H(u * u + v * v + w * w), b /= D, b *= b, b *= 200, b /= (M * M), V = Z, E != 0 ? (u = -u * M / E, v = -v * M / E, w = -w * M / E) : 0, E = (h * u + i * v + j * w) / M, h -= u * E / (M / 2), i -= v * E / (M / 2), j -= w * E / (M / 2), n(e, f, g, h, i, j, d - 1, Z, 0, 0), Q /= 2, T /= 2, U /= 2, V = V < 22 ? 7 : (V < 30 ? 1 : (V < 38 ? 2 : (V < 44 ? 4 : (V == 44 ? 6 : 3)))), Q += V & 1 ? b : 0, T += V & 2 ? b : 0, U += V & 4 ? b : 0) : (d == P ? (g += 2, j = g > 0 ? g / 8 : g / 20) : 0, j > 0 ? (U = j * j / M, Q = 255 - 250 * U / M, T = 255 - 150 * U / M, U = 255 - 100 * U / M) : (U = j * j / M, U < M / 5 ? (Q = 255 - 210 * U / M, T = 255 - 435 * U / M, U = 255 - 720 * U / M) : (U -= M / 5, Q = 213 - 110 * U / M, T = 168 - 113 * U / M, U = 111 - 85 * U / M)), d != P ? (Q /= 2, T /= 2, U /= 2) : 0);
	Q = Q < 0 ? 0 : Q > O ? O : Q;
	T = T < 0 ? 0 : T > O ? O : T;
	U = U < 0 ? 0 : U > O ? O : U;
}

int t(int x, int y, int a, int b) {
	n(M * J + M * 40 * (A * x + a) / X / A - M * 20, M * K, M * L - M * 30 * (A * y + b) / Y / A + M * 15, 0, M, 0, P, -1, 0, 0);
	R += Q;
	G += T;
	B += U;
	++a < A ? t(x, y, a, b) : (++b < A ? t(x, y, 0, b) : 0);
}

int r(int x, int y) {
	R = G = B = 0;
	t(x, y, 0, 0);

	frame_buffer[offset++] = B / A / A; // dump the pixel values straight to video RAM
	frame_buffer[offset++] = G / A / A;
	frame_buffer[offset++] = R / A / A;
	if (BPP == 32) {
		frame_buffer[offset++] = 0;
	}
}


// EOF
