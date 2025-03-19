

# Introduction

The program is simplified my_diff function for performing a line-based comparison of two files. It checks every line and see if it is different in some way
- The Unix diff utility is a very powerful and complex tool for comparing files (and directories), my program only covers a small subset of the functionality.

----

Given two files:

```
    Hi, this is a test file.
    Test file 2 to be precise.
    the output of your program should look like the following:

    2c2
    < Test file 1 to be precise.
    ---
    > Test file 2 to be precise.
```

- The output shows that line 2 differs between the files (2c2 means that line 2 in the original has been changed to become line 2 in the new file). 
- For more examples, have a look at the test files and the expected outputs given in the framework.

The exact way this my_diff should handle certain cases may be up to interpretation. 
- As some agreement is needed to allow for automated testing, please consider the interpretation of the teaching team (as given in the expected outputs) as the "correct" interpretation.

----

# Subroutine
The subroutine should have the signature: int my_diff(const char *a, const char *b, bool flag_i, bool flag_B)

- a and b are the filenames of the two files to be compared, while flag_i and flag_B indicate whether the associated flag is active.

- My subroutine opens the files, read and compare their contents line by line, print the result of the comparison, close the files, and finally return with the proper return value. 

- I assumed that lines are not longer than 1,023 characters (excluding the newline character). 

- In the case that one file has more lines than the other, I treat it as if the shorter file has (multiple) empty lines at the end to match the length of the other.

My implementation furthers support both the -i and the -B flags (and their combination).


----

# Main Program

The main program is a c file named : diff-main.c

----