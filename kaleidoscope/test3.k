extern cos(x)
extern sqrt(x)
def pi() 3.14159
def square(x) x * x
def sin(x) cos(x + pi() / 2)
def len(x, y) sqrt(square(x) + square(y))
def f(x, y, z) (x * (y + 2 / 3 - (z * z * sin(z))) / sin(x) * cos(y))
