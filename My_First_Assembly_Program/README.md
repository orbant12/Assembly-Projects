# Introduction

This is my first assembly program. A program that reads a number from the user, calls a subroutine to increment the number, and prints the returned value.

----

# Subroutine
The subroutine should have the signature: int64_t my_inc(int64_t n)

- It takes a single (64-bit signed) number as its argument and returns the number incremented by 1. 

- The subroutine itself should not print the incremented number but simply return it.

- This function follows all calling conventions, including a proper prologue and epilogue, such that it can even be called from outside of your main program and still offer the expected functionality.

Note that overflow is considered a natural limitation.

----

# Main Program

The main program use scanf to read a number from the terminal, pass the number to the my_inc subroutine, and print the returned value such that the final output looks like this:

```
    Enter a number: <x>
    The incremented number is: <x+1>
```

- where <x> represents the input the user types into the terminal (it does not need to be printed again) and <x+1> represents the incremented number.

Main program still returns with the correct exit code (0) and not the value read from the user.

----