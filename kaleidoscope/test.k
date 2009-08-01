extern cos(x)
extern sqrt(x)
def pi() 3.14159
def square(x) x * x
def sin(x) cos(x + pi() / 2)
def len(x, y) sqrt(square(x) + square(y))
output len(cos(pi()), sin(1.5 * pi()))
