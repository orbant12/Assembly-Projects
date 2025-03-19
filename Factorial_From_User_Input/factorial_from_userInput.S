#ifdef MACOS
    .global _my_factorial
    printf: jmp _printf
    scanf: jmp _scanf
    #ifdef STANDALONE
        .global _main
    #endif
#else
    .global my_factorial
    _printf: jmp printf
    _scanf: jmp scanf
    #ifdef STANDALONE
        .global main
    #endif
#endif

.bss
# [unitialized static variables]

.data
# [initialized static variables]

.text
# [constants/strings]
prompt_term:
    .asciz "Enter a number:\n"
    
input_long_fmt:
    .asciz "%lu" # Unsigned long 64 bit

end_val_print:
    .asciz "%lu! = %lu\n"


_main:
main:
    pushq   %rbp                               # Save previous base pointer
    movq    %rsp, %rbp                         # Set base pointer for new stack frame
    
    # |--- INIT PROMPT ---|
    leaq    prompt_term(%rip), %rdi            # Load Promt Text to first arg (rdi)
    movb    $0, %al                        
    call    printf     

    # |--- SCAN ---|
    subq    $16, %rsp                          # Reserve space for 2 local variables
    leaq    input_long_fmt(%rip), %rdi         # Load [long] format - first arg {rdi}
    leaq    -8(%rbp), %rsi                     # Load address of first local var as 2nd arg {rsi}
    movb    $0, %al                            # Vector 0 for scan function
    call    scanf                              # SCAN
    movq    -8(%rbp), %rdi                     # Move value to 1st arg {rdi}

    # |--- FNCTION ---|
    call    my_factorial

    # |--- PRINT ---|
    leaq    end_val_print(%rip), %rdi           # Load Promt Text to first arg (rdi)
    movq    -8(%rbp), %rsi                      # First argument: the original number n
    movq    %rax, %rdx                          # Second argument: computed factorial (n!)
    movb    $0, %al                             # Clear al for variadic call
    call    printf
    
    # |--- INIT STATE RESET ---|
    movq    $0, %rax                           # Reset rax to init state
    movq    %rbp, %rsp                         # Reset stack pointer to bottom
    popq    %rbp                               # Restore previous base pointer

    ret

# uint64_t my_factorial(uint64_t n)
_my_factorial:
my_factorial:
    pushq   %rbp                                # Save old base pointer
    movq    %rsp, %rbp                          # New stack frame

    # Base Case: if (n == 0) return 1
    cmpq    $0, %rdi
    jne     .loop
    movq    $1, %rax
    jmp     .end

    .loop:
        pushq   %rdi                               # 1. Push n onto stack 
        decq    %rdi                               # 2. Decrement n in %rdi
        call    my_factorial                       # 3. Recursively call my_factorial(n - 1)

        popq    %rdx                               # Pop the original n into %rdx
        imulq   %rdx, %rax                         # Multiply: %rax = %rax * %rdx
                                                   # (factorial(n - 1) * n)

    .end:
        popq    %rbp                                # Restore old base pointer
        ret

