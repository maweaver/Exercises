extern cos(x)
extern sqrt(x)
extern fib(n)
def pi() 3.14159
def square(x) x * x
def sin(x) cos(x + pi() / 2)
def len(x, y) sqrt(square(x) + square(y))
def fib(n)
  if(n < 2) then 
    n - 1
  else
    fib(n - 2) + fib(n - 1)

output len(sin(pi()), fib(input()))
