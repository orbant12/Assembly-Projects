# Introduction

This is all about saving and reusing results and some (slightly) more advanced user interaction. It works with explicit memory management (through functions like malloc, realloc, or free)

- Main topic: Memory Management

----

# Subroutine

Signature is as follows: uint64_t *my_fib(uint64_t i, uint64_t *arr, uint64_t size)

- This routine not only takes the index of the Fibonacci number to calculate (i) but now also takes a pointer to an array (arr) of already computed Fibonacci numbers (the length of which is indicated by size). 
- It furthermore no longer returns a computed value, but rather also a pointer to an array. The arr argument can be NULL in the case that there are no pre-calculated numbers.

---

When the function is called, there are two possible executions:

- size>i: the Fibonacci sequence is already calculated up to the requested index

- size≤i: the Fibonacci sequence is not yet calculated up to the requested index

---

Handling the first case is trivial (as no work has to be done and the array should stay untouched), for the second, however, the function should:

- resize the array to fit the Fibonacci sequence up to the requested index

- calculate the missing numbers (without recalculating any existing numbers)

- return a pointer to the new array

while not allocating more memory than needed for the sequence or leaking any memory.

----

# Main Program

The main routine will continuously asks the user for an index and then prints the associated Fibonacci number, until the user enters a non-numeric input, at which point the program should exit gracefully.

- Output:

```
   Enter an index: <x>
    F_<x> = <fib(x)>
    Enter an index: <y>
    F_<y> = <fib(y)>
    Enter an index: <z>
    F_<z> = <fib(z)>
    Enter an index: q
    Exiting...
```

----