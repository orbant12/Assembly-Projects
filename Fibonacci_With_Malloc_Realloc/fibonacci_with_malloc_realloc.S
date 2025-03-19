#ifdef MACOS
    .global _my_fib
    printf: jmp _printf
    scanf: jmp _scanf
    malloc: jmp _malloc
    calloc: jmp _calloc
    realloc: jmp _realloc
    free: jmp _free
    #ifdef STANDALONE
        .global _main
    #endif
#else
    .global my_fib
    _printf: jmp printf
    _scanf: jmp scanf
    _malloc: jmp malloc
    _calloc: jmp calloc
    _realloc: jmp realloc
    _free: jmp free
    #ifdef STANDALONE
        .global main
    #endif
#endif

.bss
    .align 8
g_fib_array:
    .zero 8           # Pointer to Fibonacci array (uint64_t *)
g_fib_size:
    .zero 8           # Current number of valid entries (uint64_t)

.data
exit_prompt:
    .asciz "Exiting..."

user_input_prompt:
    .asciz "Enter an index: "

output_prompt:
    .asciz "F_%lu = %lu\n"

input_long_fmt:
    .asciz "%lu"      # Unsigned long 64 bit

.text

_main:
main:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $16, %rsp                               # Reserve space for local variable 'n'

.loop:
    # 1.) --[ Print the prompt ]--
    leaq    user_input_prompt(%rip), %rdi           # Load prompt to rdi (location address not the value)
    movb    $0, %al
    call    printf 

    # 2.) --[ Read an unsigned long ]--
    leaq    input_long_fmt(%rip), %rdi              # Load type[unsigned unsigned 64bit] to rdi (location address not the value) 
    leaq    -8(%rbp), %rsi                          # Load the reserved space to rsi [sec arg] for the scan function it will load the scanned value to the address -8(%rbp)
    movb    $0, %al
    call    scanf
    movq    -8(%rbp), %rdi  

    # 3.) --[ Checking scanned value if nummerical ]--
    cmpq    $1, %rax
    jne     .exit

    cmpq    $0, %rax
    jl      .exit

    # 3.) --[ Calling fib ]--
    movq    g_fib_array(%rip), %rsi                 # Content of global variable into rsi
    movq    g_fib_size(%rip), %rdx                  # Content of global variable into rdx
    call    my_fib                                  # now rdi = scanned val, rsi = array, rdx = size

    
    # 4.) --[ Store the returned pointer globally ]-- | The returns from the my_fib
 
    movq    %rax, g_fib_array(%rip)

    # 5.) --[ Print output with format ]--
    movq    -8(%rbp), %rcx          # n
    movq    (%rax,%rcx,8), %rdx     # fib[n]
    leaq    output_prompt(%rip), %rdi
    movq    -8(%rbp), %rsi
    movb    $0, %al
    call    printf

    jmp     .loop

.exit:
    leaq    exit_prompt(%rip), %rdi
    movb    $0, %al
    call    printf

    xorq    %rax, %rax      

    movq    %rbp, %rsp
    popq    %rbp
    ret


# uint64_t *my_fib(uint64_t n, uint64_t *arr, uint64_t size)
_my_fib:
my_fib:

    #--[ Prologue ]--
    pushq   %rbp
    movq    %rsp, %rbp

    # 3.) --[ Save callee-saved registers - keeping their value is the resp. of the fib() ]--
    pushq   %rbx                     
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15

    # 4.) --[ Move params into calee saved registers ]--
    movq    %rdi, %r12                          # n
    movq    %rsi, %r13                          # arr
    movq    %rdx, %r14                          # size

    # 5.) --[ Checked if final size reacched ]--
    mov     %r12, %r15
    incq    %r15                                # n + 1 - showing how many possible values gonna be in the array
    cmpq    %r15, %r14                          # compare n + 1 with size
    jge     .return_val

    
    # 6.) --[ Making the array we will return 1.) Storing the number of bytes needed to store array with n + 1 ]--
    movq    %r15, %rbx
    shlq    $3, %rbx                            # Multiply (n+1) by 8 to get total bytes needed (8 bytes per uint64_t) -> %rbx × 2^3

    # 7.) --[ Dynamic memory allocation if needed ]--
    cmpq $0, %r13       # Compare array pointer to 0 (NULL)
    jz      .apply_malloc
    cmpq $0, %r14       # Compare size to 0
    jz      .apply_malloc

    # 8.) --[ Realloc - Resizes a block in the memory that was previously allocated with malloc ]--
    movq    %r13, %rdi                          # rdi the array for realloc
    movq    %rbx, %rsi                          # rsi bytes size needed to realloc
    call    _realloc
    cmpq   $0, %rax                          # Check for fail
    jz      .failed_return
    movq    %rax, %r13                          # Update the array with the reallocated memory
    jmp     .array_setup

.apply_malloc:
    # Dynamically allocates memory of a certain size on the heap. The allocated memory is uninitialized.
    movq    %rbx, %rdi                          # needed bytes calculated to allocate -> rdi setup for malloc func
    call    _malloc
    cmpq   $0, %rax                       
    jz      .failed_return
    movq    %rax, %r13                          # move the allocated memory location to the array variable
    movq    $0, %r14                            # resetting to an empty array

.array_setup:
    # 1.) --[ Check if the array has at least one element already ]--
    cmpq    $1, %r14                            # Cmp with 1 the size
    jge     .array_setup_2                      # IF r14 >= 1 -> It has
    movq    $0, (%r13)                          # IF it doesnt have then -> init the array with 0 in the [0] index

.array_setup_2:
    # 1.) --[ If array size is greater than or equal to 2, it means that the first two Fibonacci numbers are already initialized ]
    cmpq    $2, %r14                            
    jge     .fill_remaining                     
    cmpq    $2, %r15                            # if n + 1 - pissbile values - is less than 2
    jb      .fill_remaining                     # If the final REQUIRED size needed is below 2, there's no need for arr[1]
    movq    $1, 8(%r13)                         # Init the second element in the array with the value 1 so arr[1] = 1 -> 8(%r13) = the memory address 8 bytes after the address in %r13

.fill_remaining: 
    # 1.) --[Filling in the remaining Fibonacci numbers - making sure that rcx starts at index 2]--
    movq    %r14, %rcx                          # The size callee reg -[into]> Initial Scanned input -> LOOP COUNTER
    cmpq    $2, %rcx                            
    jge     .fill_loop_start                    # If n >= 2 -> then we need to 
    movq    $2, %rcx                            # Otherwise, set the scanned input to 2

.fill_loop_start:
    cmpq    %r15, %rcx        # while (rcx < n+1) 
    jge     .update_size

    # arr[rcx] = arr[rcx-1] + arr[rcx-2]
    movq    %rcx, %rdx                      # temp for array index decrease
    decq    %rdx
    movq    (%r13,%rdx,8), %rax             # Load arr[index-1] value into %rax -> %r13 + %rdx*8
    decq    %rdx
    addq    (%r13,%rdx,8), %rax             # SUM with => Load arr[index-2] value into %rax -> %r13 + %rdx*8
    movq    %rax, (%r13,%rcx,8)             # stores this sum at the current index

    incq    %rcx
    jmp     .fill_loop_start

.update_size:
    movq    %r15, g_fib_size(%rip)              # Update global variable with new size

.return_val:

    # --[ return array ]
    movq    %r13, %rax

    # --[ Epilog ] --
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbx
    popq    %rbp
    ret

.failed_return:
    # --[ Epilog ] --
    mov     $0, %rax
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbx
    popq    %rbp
    ret
