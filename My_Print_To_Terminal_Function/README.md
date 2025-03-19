# Introduction

- In this program I implemented my own printf function, that matches the original in quite some of its functionality.

- My own implementation of printf (Linux man page: man printf) function (or its relatives). 

----

# Printf

The printf function is pretty flexible, especially in its number of arguments. How many arguments do you need to give it? 1. How many arguments can you give it? Well, pretty much unlimited.

- printf takes a variable number of arguments, so the argument count is not fixed in its signature. 
- The first argument is always the so-called format string. 
- This argument is a pointer to a memory location of the first character of the string to print. 
- This string, however, may not only include "regular" characters but also so-called format specifiers (yes that's the official name of the %ds or %us that you've been using so far). 
- Whenever the function encounters such a specifier in the format string it will look at the next argument in the argument list for the correct substitution (at least for most specifiers, depending on the type).

----

# My Printf

My version only has to understand the format specifiers listen below. 
- If a format specifier is not recognized, it will be printed without modification. 
- Your function follows the x86_64 calling conventions.
- It accepts any number of arguments (so even tens or hundreds), like any standard printf implementation.
- void my_printf(char *fmt, ...);

----

### Format Specifiers


This implementation supports the following format specifiers:

- %d: print a signed, 32-bit integer in decimal

- %u: print an unsigned, 32-bit integer in decimal

- %s: print a null-terminated string - no format specifiers should be parsed in this string

- %%: print a percentage sign

Example:

Suppose you have the following format string:

"My name is %s and I am %u years old. My favorite ASCII character is %%."
and the additional arguments: "Lennart" and 21, then the output of your subroutine should be:

My name is Lennart and I am 21 years old. My favorite ASCII character is %.

----

### Main Function

```
    my_printf(FMT=My number: %d\n, ARG=(int32_t) 55)
    [ERROR] my_printf did not match printf!
    Expected output:
        My number: 55

    Actual output:
        My number: ((not implemented))
```

In the example above, the call was my_printf("My number: %d\n", 55) and the expected output was My number: 55.