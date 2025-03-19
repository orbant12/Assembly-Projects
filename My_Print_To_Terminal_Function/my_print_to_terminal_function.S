#ifdef MACOS
    .global _my_printf
    putchar: jmp _putchar
    #ifdef STANDALONE
        .global _main
    #endif
#else
    .global my_printf
    _putchar: jmp putchar
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
format_test:
    .asciz "Test: signed=%d, unsigned=%u, string=%s, and percent=%%\n"
    
name_test:
    .asciz "Hello World"

_main:
main:
    # 1.) --[ Prologue ]--
    push %rbp
    mov %rsp, %rbp
    
    # 2.) --[ Setting up arguments for my_printf ]--
    lea format_test(%rip), %rdi
    mov $42, %rsi               # %d test
    mov $123, %rdx              # %u test
    lea name_test(%rip), %rcx   # %s test
    
    # 3.) --[ Call func ]--
    call my_printf
    
    # .) --[Setting up arguments for my_printf]--
    xor %rax, %rax
    leave
    ret


# void my_printf(const char *fmt, ...)
_my_printf:
my_printf:

    
    push %rbp
    mov %rsp, %rbp
    
    # 2.) --[ Callee's ]--
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
        
    # 3.) --[ Save the argument registers to the stack for consistent access ]--

    sub $48, %rsp          # Allocate 6*8 bytes for register args
    mov %rsi, 0(%rsp)      # First arg
    mov %rdx, 8(%rsp)      # Second arg
    mov %rcx, 16(%rsp)     # Third arg
    mov %r8, 24(%rsp)      # Fourth arg
    mov %r9, 32(%rsp)      # Fifth arg
    
    # Register allocation:
    # %r13 - format string pointer (from %rdi)
    # %rbx - current format character
    # %r12 - current argument index (0) - Tracks which argument we're currently processing - Used to calculate the memory address where the current argument is stored
    # %r14 - temporary storage
    # %r15 - temporary storage
    
    
    mov %rdi, %r13      
    # Init current argument index
    movq $0, %r12            
    
process_format:
    
    # 3.) --[ Main loop to process format string ]--

    # 3.) --[ Load current character ]--
    movzb (%r13), %rbx      # fill al 64 bits in rbx -> stores value and then remaining higer bits will be 0, -> Each caracter is 1 byte we need to read byte by byte -> ensuring leftovers
    
    # 3.) --[ Check if we reached end of string ]--
    test %rbx, %rbx                 
    jz done_printf
    
    
    # 3.) --[ Check if it's a format specifier (%) ]--
    cmp $37, %rbx     # % is 37 in ASCII
    je format_specifier
    
    # Regular character - print it
    mov %rbx, %rdi
    call putchar
    
    # Move to next character in format string
    inc %r13
    jmp process_format

format_specifier:
    
    # 3.) --[ Move past '%' ]--
    inc %r13
    
    # 3.) --[ Get the specifier character ]--
    movzb (%r13), %rbx
    
    # 3.) --[ Check type of specifier ]--
    cmp $100, %rbx    # d is 100 in ASCII
    je format_signed_int
    
    cmp $117, %rbx    # u is 117 in ASCII
    je format_unsigned_int
    
    cmp $115, %rbx    # s is 115 in ASCII
    je format_string
    
    cmp $37, %rbx     # % is 37 in ASCII
    je format_percent
    
    # Unknown - Print '%'
    mov $37, %rdi     
    call putchar

    # Print the unknown specifier
    mov %rbx, %rdi    
    call putchar
    
    # Move past the unknown specifier
    inc %r13
    jmp process_format

format_signed_int:
    
    # 3.) --[ Calculate the address of the current argument ]--
    mov %r12, %r14
    mul $8, %r14      # Multiply by 8 bc each is 8 
    
    # Check if we need to get from registers (first 5 args) or stack
    cmp $5, %r12
    jge signed_int_from_stack
    
    # Get from register shadow area
    mov (%rsp, %r14), %rdi
    jmp print_signed
    
signed_int_from_stack:
    mov %r12, %r14

    sub $5, %r14         # from 0-index to stack position
    mul $8, %r14         # multiply by 8 

    lea 16(%rbp, %r14), %rax  # Compute correct address: rbp + 16 + offset

    mov (%rax), %rdi     # Load argument from calculated address
    
print_signed:
    # Increment argument index
    inc %r12
    
    push %r13
    
    call print_signed_int
    
    # Restore format string pointer
    pop %r13
    
    # Move to next character in format string
    inc %r13
    jmp process_format

format_unsigned_int:
    
    mov %r12, %r14
    shl $3, %r14      # Multiply by 8 (size of pointer/integer)
    
    # Check if we need to get from registers (first 5 args) or stack
    cmp $5, %r12
    jge unsigned_int_from_stack
    
    # Get from register shadow area
    mov (%rsp, %r14), %rdi
    jmp print_unsigned
    
unsigned_int_from_stack:
    # For arguments on stack, start at rbp+16
    # Compute this formula: rbp + 16 + (argIndex - 5)*8
    mov %r12, %r14
    sub $5, %r14         # Adjust from 0-index to stack position
    shl $3, %r14         # Multiply by 8 (bytes per argument)
    lea 16(%rbp, %r14), %rax  # Compute correct address: rbp + 16 + offset
    mov (%rax), %rdi     # Load argument from calculated address
    
print_unsigned:
    # Increment argument index
    inc %r12
    
    # Save format string pointer
    push %r13
    
    # Call helper function to print unsigned int
    call print_unsigned_int
    
    # Restore format string pointer
    pop %r13
    
    # Move to next character in format string
    inc %r13
    jmp process_format

format_string:
    # Calculate the address of the current argument
    
    mov %r12, %r14
    shl $3, %r14      # Multiply by 8 (size of pointer/integer)
    
    # Check if we need to get from registers (first 5 args) or stack
    cmp $5, %r12
    jge string_from_stack
    
    # Get from register shadow area
    mov (%rsp, %r14), %r14
    jmp print_string
    
string_from_stack:
    mov %r12, %r15       # Use r15 temporarily to preserve r14
    sub $5, %r15         # from 0-index to stack position
    shl $3, %r15      
    lea 16(%rbp, %r15), %rax  # address: rbp + 16 + offset
    mov (%rax), %r14     # Load string pointer from address
    
print_string:
    # Increment argument index
    inc %r12
    
    # Save format string pointer
    push %r13
    
    # Check if string pointer is NULL
    cmp $0, %r14
    jz string_null
    
    # Print the string character by character
print_string_loop:
    movzb (%r14), %rdi
    cmp $0, %rdi
    jz string_done_restore
    
    call putchar
    
    inc %r14
    jmp print_string_loop
    
string_null:
    # Print "(null)" for NULL pointers
    lea null_str(%rip), %r14
    jmp print_string_loop
    
string_done_restore:
    # Restore format string pointer
    pop %r13
    
    # Move to next character in format string
    inc %r13
    jmp process_format

format_percent:
    # Print '%' character
    mov $37, %rdi
    call putchar
    
    # Move to next character in format string
    inc %r13
    jmp process_format

done_printf:
    # Cleanup register shadow area
    add $48, %rsp
    
    # Restore callee-saved registers
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    
    leave
    ret

null_str:
    .asciz "(null)"

# Helper function to print a signed 32-bit integer
print_signed_int:
    
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    
    # %rdi contains the integer to print
    
    # Check if negative
    mov %rdi, %rax
    mov $0, %r12      
    
    # Sign-extend the 32-bit integer to 64-bit-> handle negative
    # %edi lower 32 bits of rdi 
    # fills all 64 bits of raxso
    movslq %edi, %rax
    
    test %rax, %rax
    jns positive_int
    
    # Handle negative number
    mov $1, %r12      # Set negative flag
    neg %rax          # Make positive | reverses the sign of a number
    
positive_int:
    # Convert to string backwards (in stack)
    sub $64, %rsp     # Allocate buffer on stack
    mov %rsp, %rbx    # %rbx points to buffer
    
    # Handle special case for 0
    test %rax, %rax
    jnz convert_digit
    
    # Just print '0'
    movb $48, (%rbx)  # '0' is 48 in ASCII
    inc %rbx
    jmp print_int_buffer
    
convert_digit:
    # Extract digits one by one
    mov $10, %rcx
    
digit_loop:
    xor %rdx, %rdx    # Clear high bits for division
    div %rcx          # Divide by 10, remainder in %rdx
    
    add $48, %rdx     # Convert to ASCII
    mov %dl, (%rbx)   # Store in buffer
    inc %rbx
    
    test %rax, %rax   # Check if we're done
    jnz digit_loop
    
    # If negative, add the minus sign
    test %r12, %r12
    jz print_int_buffer
    
    movb $45, (%rbx)  # '-' is 45 in ASCII
    inc %rbx
    
print_int_buffer:
    # Print buffer in reverse order
    dec %rbx
    
print_loop:
    movzb (%rbx), %rdi
    call putchar
    
    cmp %rsp, %rbx
    je print_done
    
    dec %rbx
    jmp print_loop
    
print_done:
    # Cleanup and return
    add $64, %rsp     # Deallocate buffer
    
    pop %r13
    pop %r12
    pop %rbx
    leave
    ret

# Helper function to print an unsigned 32-bit integer
print_unsigned_int:
    # Save registers
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    
    # %rdi contains the unsigned integer to print
    # Make sure we're working with a 32-bit value
    mov %edi, %eax    # This zeroes the upper 32 bits
    
    # Convert to string backwards (in stack)
    sub $64, %rsp     # Allocate buffer on stack
    mov %rsp, %rbx    # %rbx points to buffer
    
    # Handle special case for 0
    test %rax, %rax
    jnz convert_digit_unsigned
    
    # Just print '0'
    movb $48, (%rbx)  # '0' is 48 in ASCII
    inc %rbx
    jmp print_unsigned_buffer
    
convert_digit_unsigned:
    # Extract digits one by one
    mov $10, %rcx
    
digit_loop_unsigned:
    xor %rdx, %rdx    # Clear high bits for division
    div %rcx          # Divide by 10, remainder in %rdx
    
    add $48, %rdx     # Convert to ASCII
    mov %dl, (%rbx)   # Store in buffer
    inc %rbx
    
    test %rax, %rax   # Check if we're done
    jnz digit_loop_unsigned
    
print_unsigned_buffer:
    # Print buffer in reverse order
    dec %rbx
    
print_loop_unsigned:
    movzb (%rbx), %rdi
    call putchar
    
    cmp %rsp, %rbx
    je print_done_unsigned
    
    dec %rbx
    jmp print_loop_unsigned
    
print_done_unsigned:
    # Cleanup and return
    add $64, %rsp     # Deallocate buffer
    
    pop %r12
    pop %rbx
    leave
    ret