#define P(x1, x2) x1 char* s; s = #x1 ", " #x2; x2
P(int main(int argc, char** argv) {, printf("#define P(x1, x2) x1 char* s; s = #x1 #x2; x2\nP(%s)\n", s); })
