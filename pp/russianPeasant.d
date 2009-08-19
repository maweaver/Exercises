import std.c.stdio;
import std.stdio;

int russianPeasant(int m1, int m2, int result) {
	if(m1 == 1) {
		return result + m2;
	} else if(m1 % 2 == 1) {
		return russianPeasant(m1 / 2, m2 * 2, result + m2);
	} else {
		return russianPeasant(m1 / 2, m2 * 2, result);
	}
}

int russianPeasantRecursive(int m1, int m2) {
	if(m1 == 1) {
		return m2;
	} else if(m1 % 2 == 1) {
		return m2 + russianPeasantRecursive(m1 / 2, m2 * 2);
	} else {
		return russianPeasantRecursive(m1 / 2, m2 * 2);
	}
}

void main() {
	int m1, m2;
	scanf("%d %d", &m1, &m2);
	writefln("Straight multiplication: %d, russian peasant: %d, recursive russian peasant: %d", m1 * m2, russianPeasant(m1, m2, 0), russianPeasantRecursive(m1, m2));
}