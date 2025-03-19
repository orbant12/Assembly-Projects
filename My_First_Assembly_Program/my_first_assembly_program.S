#ifdef MACOS
    .global _my_inc
    printf: jmp _printf
    scanf: jmp _scanf
    #ifdef STANDALONE
        .global _main
    #endif
#else
    .global my_inc
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
enter_number:
    .asciz "Enter a number:\n"

incremented_number:
    .asciz "The incremented number is: %ld"

input_long_fmt:
    .asciz "%ld"

_main:
main:
    pushq %rbp                              # Save previous base pointer
    movq %rsp, %rbp                         # Set base pointer for new stack frame

    # |--- INIT PROMPT ---|
    leaq enter_number(%rip), %rdi           # Load Promt Text to first arg (rdi)
    movb $0, %al                        
    call printf                             # Print Promt Text

    # |--- SCAN ---|
    subq $16, %rsp                          # Reserve space for 2 local variables
    leaq input_long_fmt(%rip), %rdi         # Load [long] format - first arg {rdi}
    leaq -8(%rbp), %rsi                     # Load address of first local var as 2nd arg {rsi}
    movb $0, %al                            # Vector 0 for scan function
    call scanf                              # SCAN
    movq -8(%rbp), %rdi                     # Move value to 1st arg {rdi} 

    # |--- INCRMNT ---|
    call my_inc
    
    # |--- PRINT ---|
    leaq incremented_number(%rip), %rdi     # Load Promt Text to first arg (rdi)
    movq %rax, %rsi                         # Move return value {rax} and set it as second arg {rsi} 
    call printf                             # PRINT

    # |--- INIT STATE RESET ---|
    movq $0, %rax                           # Reset rax to init state
    movq %rbp, %rsp                         # Reset stack pointer to bottom
    popq %rbp                               # Restore previous base pointer

    ret

# int64_t my_inc(int64_t n)
_my_inc:
my_inc:
    pushq %rbp                      # Save previous base pointer  
    movq %rsp, %rbp                 # Set base pointer for new stack frame
    # |--- INCRMNT ---|
    incq %rdi                       # Increment first arg {rdi}
    movq %rdi, %rax                 # Set rdi the return arg {rdx}
    
    # |--- INIT STATE RESET ---|
    movq %rbp, %rsp                 # Reset stack pointer to bottom
    popq %rbp                       # Restore previous base pointer
    ret 