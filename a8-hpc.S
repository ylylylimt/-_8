#ifdef MACOS
    .global _main
    printf: jmp _printf
    malloc: jmp _malloc
    calloc: jmp _calloc
    realloc: jmp _realloc
    free: jmp _free
    clock_gettime: jmp _clock_gettime
    gettimeofday: jmp _gettimeofday
#else 
    .global main
    _printf: jmp printf
    _malloc: jmp malloc
    _calloc: jmp calloc
    _realloc: jmp realloc
    _free: jmp free
    _clock_gettime: jmp clock_gettime
    _gettimeofday: jmp gettimeofday
#endif

#ifndef STREAM_ARRAY_SIZE
    #define STREAM_ARRAY_SIZE 75000000
#endif

#define D_STREAM_ARRAY_SIZE (STREAM_ARRAY_SIZE - 1)
#define D_NTIMES (NTIMES - 1)
#define TWO_NTIMES (NTIMES * 2)
#define THREE_NTIMES (NTIMES * 3)
#ifndef NTIMES
    #define NTIMES 20
#endif

# Use custom values:        $ make a8-hpc/a8-hpc -B STREAM_ARRAY_SIZE=<custom_size> NTIMES=<custom_reps>
# Revert to default values: $ make a8-hpc/a8-hpc -B

.bss
# [unitialized static variables]
.data
# [initialized static variables]
LC1:
        .long   -536870912
        .long   1206910975
LC7:
        .long   0
        .long   1104273827
LC8:
        .long   -2147483648
        .long   1104859764
LC9:
        .long   0
        .long   1072693248
LC10:
        .long   0
        .long   1073741824
LC11:
        .long   0
        .long   1093567616
LC12:
        .long   0
        .long   1074266112
LC20:
        .long   0
        .long   1077084160
LC21:
        .long   -1598689907
        .long   1051772663
.text        
# Strings for formatted output:
fmt_info: 
    .asciz "Array size = %lu (elements).\nEach kernel will be executed %u times.\n"
    # printf(fmt_info, STREAM_ARRAY_SIZE, NTIMES)
fmt_div: 
    .asciz "-------------------------------------------------------------"
fmt_title: 
    .asciz "%-8s  %13s  %11s  %11s  %11s\n"
    # printf(fmt_title, col_title_function, ...)
fmt_row: 
    .asciz "%-10s  %12.1f  %11.6f  %11.6f  %11.6f\n"
    # printf(fmt_row, row_title_copy, 13029.0, ...)
col_title_function: .asciz "Function"
col_title_rate: .asciz "Best Rate MB/s"
col_title_avg: .asciz "Avg time"
col_title_min: .asciz "Min time"
col_title_max: .asciz "Max time"
row_title_copy: .asciz "Copy:"
row_title_scale: .asciz "Scale:"
row_title_add: .asciz "Add:"
row_title_triad: .asciz "Triad:"        

_main:        
main:
        pushq   %rbp
        movq    %rsp, %rbp
        pushq   %rbx
        subq    $808, %rsp
        movl    $32, %edi               # avg time array allocation
        call    malloc
        movq    %rax, -72(%rbp)
        movl    $0, -20(%rbp)
        jmp     .L2
.L3:
        movl    -20(%rbp), %eax         # filling array with zeroes        
        cltq                            # sign-extends EAX into RAX
        leaq    0(,%rax,8), %rdx
        movq    -72(%rbp), %rax
        addq    %rdx, %rax
        pxor    %xmm0, %xmm0
        movsd   %xmm0, (%rax)
        addl    $1, -20(%rbp)
.L2:
        cmpl    $3, -20(%rbp)
        jle     .L3
        movl    $32, %edi                 # max time array allocation      
        call    malloc
        movq    %rax, -80(%rbp)
        movl    $0, -24(%rbp)
        jmp     .L4
.L5:
        movl    -24(%rbp), %eax           # filling array with zeroes        
        cltq
        leaq    0(,%rax,8), %rdx
        movq    -80(%rbp), %rax
        addq    %rdx, %rax
        pxor    %xmm0, %xmm0
        movsd   %xmm0, (%rax)
        addl    $1, -24(%rbp)
.L4:
        cmpl    $3, -24(%rbp)
        jle     .L5
        movl    $32, %edi                   # min time array allocation        
        call    malloc
        movq    %rax, -88(%rbp)
        movl    $0, -28(%rbp)
        jmp     .L6
.L7:
        movl    -28(%rbp), %eax                  # filling array with 0 with        
        cltq                                    # special case floating point
        leaq    0(,%rax,8), %rdx
        movq    -88(%rbp), %rax
        addq    %rdx, %rax
        movsd   LC1(%rip), %xmm0
        movsd   %xmm0, (%rax)
        addl    $1, -28(%rbp)
.L6:
        cmpl    $3, -28(%rbp)
        jle     .L7
        
        leaq row_title_copy(%rip), %rdi               # create array for labels  
        movq %rdi, -176(%rbp)                           # like copy triad scale

        leaq row_title_scale(%rip), %rdi
        movq %rdi, -168(%rbp)

        leaq row_title_add(%rip), %rdi
        movq %rdi, -160(%rbp)

        leaq row_title_triad(%rip), %rdi
        movq %rdi, -152(%rbp)

        movl    $32, %edi
        call    malloc
        movq    %rax, -96(%rbp)
        movl    $0, -32(%rbp)
        jmp     .L8
.L11:
        movl    -32(%rbp), %eax
        cltq
        movq    -176(%rbp,%rax,8), %rax         # copy labels 
        movq    %rax, %rdi
        call    strlen
        addq    $1, %rax
        movl    -32(%rbp), %edx
        movslq  %edx, %rdx
        leaq    0(,%rdx,8), %rcx
        movq    -96(%rbp), %rdx
        leaq    (%rcx,%rdx), %rbx
        movq    %rax, %rdi
        call    malloc
        movq    %rax, (%rbx)
        movl    -32(%rbp), %eax
        cltq
        leaq    0(,%rax,8), %rdx
        movq    -96(%rbp), %rax
        addq    %rdx, %rax
        movq    (%rax), %rax
        testq   %rax, %rax
        jne     .L9
        
        jmp     .L40
.L9:
        movl    -32(%rbp), %eax                 # create array for bytes
        cltq                                    # fill out with variable space        
        movq    -176(%rbp,%rax,8), %rdx
        movl    -32(%rbp), %eax
        cltq
        leaq    0(,%rax,8), %rcx
        movq    -96(%rbp), %rax
        addq    %rcx, %rax
        movq    (%rax), %rax
        movq    %rdx, %rsi
        movq    %rax, %rdi
        call    strcpy
        addl    $1, -32(%rbp)
.L8:
        cmpl    $3, -32(%rbp)
        jle     .L11
        movl    $2400000000, %eax
        movq    %rax, %rdi
        call    malloc
        movq    %rax, -104(%rbp)
        movq    -104(%rbp), %rax
        movsd   LC7(%rip), %xmm0
        movsd   %xmm0, (%rax)
        movq    -104(%rbp), %rax
        addq    $8, %rax
        movsd   LC7(%rip), %xmm0
        movsd   %xmm0, (%rax)
        movq    -104(%rbp), %rax
        addq    $16, %rax
        movsd   LC8(%rip), %xmm0
        movsd   %xmm0, (%rax)
        movq    -104(%rbp), %rax
        addq    $24, %rax
        movsd   LC8(%rip), %xmm0
        movsd   %xmm0, (%rax)
        movl    $600000000, %edi
        call    malloc
        movq    %rax, -112(%rbp)
        movl    $600000000, %edi
        call    malloc
        movq    %rax, -120(%rbp)
        movl    $600000000, %edi
        call    malloc
        movq    %rax, -128(%rbp)
        movq    $0, -48(%rbp)
        jmp     .L12
.L13:
        movq    -48(%rbp), %rax                 # create array for time
        leaq    0(,%rax,8), %rdx
        movq    -112(%rbp), %rax
        addq    %rdx, %rax
        movsd   LC9(%rip), %xmm0                # starting time
        movsd   %xmm0, (%rax)
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -120(%rbp), %rax
        addq    %rdx, %rax
        movsd   LC10(%rip), %xmm0               # ending time
        movsd   %xmm0, (%rax)
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -128(%rbp), %rax
        addq    %rdx, %rax
        pxor    %xmm0, %xmm0
        movsd   %xmm0, (%rax)
        addq    $1, -48(%rbp)
.L12:
        cmpq    $D_STREAM_ARRAY_SIZE, -48(%rbp)
        jle     .L13
        movl    $0, %eax
        call    mysecond
        movq    %rax, -56(%rbp)                 # set up scalar value
        movq    $0, -48(%rbp)
        jmp     .L14
.L15:
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -112(%rbp), %rax
        addq    %rdx, %rax
        movsd   (%rax), %xmm0
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -112(%rbp), %rax
        addq    %rdx, %rax
        addsd   %xmm0, %xmm0
        movsd   %xmm0, (%rax)
        movl    $0, %eax
        call    mysecond
        subsd   -56(%rbp), %xmm1
        movsd   LC11(%rip), %xmm0
        mulsd   %xmm1, %xmm0
        movsd   %xmm0, -56(%rbp)
        addq    $1, -48(%rbp)
.L14:
        cmpq    $D_STREAM_ARRAY_SIZE, -48(%rbp)
        jle     .L15
        movsd   LC12(%rip), %xmm0
        movsd   %xmm0, -136(%rbp)
        movl    $0, -36(%rbp)
        jmp     .L16
.L25:
        movl    $0, %eax
        call    mysecond
        movl    -36(%rbp), %edx
        movslq  %edx, %rdx
        movq    %rax, -816(%rbp,%rdx,8)
        movq    $0, -48(%rbp)
        jmp     .L17
.L18:
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -112(%rbp), %rax
        addq    %rax, %rdx
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rcx
        movq    -128(%rbp), %rax
        addq    %rcx, %rax
        movsd   (%rdx), %xmm0
        movsd   %xmm0, (%rax)
        addq    $1, -48(%rbp)
.L17:
        cmpq    $D_STREAM_ARRAY_SIZE, -48(%rbp)
        jle     .L18
        movl    $0, %eax
        call    mysecond
        movl    -36(%rbp), %edx
        movslq  %edx, %rdx
        movsd   -816(%rbp,%rdx,8), %xmm1
        movq    %rax, %xmm0
        subsd   %xmm1, %xmm0
        movl    -36(%rbp), %eax
        cltq
        movsd   %xmm0, -816(%rbp,%rax,8)
        movl    $0, %eax
        call    mysecond
        movl    -36(%rbp), %edx
        movslq  %edx, %rdx
        addq    $NTIMES, %rdx
        movq    %rax, -816(%rbp,%rdx,8)
        movq    $0, -48(%rbp)
        jmp     .L19
.L20:
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -128(%rbp), %rax
        addq    %rdx, %rax
        movsd   (%rax), %xmm0
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -120(%rbp), %rax
        addq    %rdx, %rax
        mulsd   -136(%rbp), %xmm0
        movsd   %xmm0, (%rax)
        addq    $1, -48(%rbp)
.L19:
        cmpq    $D_STREAM_ARRAY_SIZE, -48(%rbp)
        jle     .L20
        movl    $0, %eax
        call    mysecond
        movl    -36(%rbp), %edx
        movslq  %edx, %rdx
        addq    $NTIMES, %rdx
        movsd   -816(%rbp,%rdx,8), %xmm1
        movq    %rax, %xmm0
        subsd   %xmm1, %xmm0
        movl    -36(%rbp), %eax
        cltq
        addq    $NTIMES, %rax
        movsd   %xmm0, -816(%rbp,%rax,8)
        movl    $0, %eax
        call    mysecond
        movl    -36(%rbp), %edx
        movslq  %edx, %rdx
        addq    $TWO_NTIMES, %rdx
        movq    %rax, -816(%rbp,%rdx,8)
        movq    $0, -48(%rbp)
        jmp     .L21
.L22:
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -112(%rbp), %rax
        addq    %rdx, %rax
        movsd   (%rax), %xmm1
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -120(%rbp), %rax
        addq    %rdx, %rax
        movsd   (%rax), %xmm0
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -128(%rbp), %rax
        addq    %rdx, %rax
        addsd   %xmm1, %xmm0
        movsd   %xmm0, (%rax)
        addq    $1, -48(%rbp)
.L21:
        cmpq    $D_STREAM_ARRAY_SIZE, -48(%rbp)
        jle     .L22
        movl    $0, %eax
        call    mysecond
        movl    -36(%rbp), %edx
        movslq  %edx, %rdx
        addq    $TWO_NTIMES, %rdx
        movsd   -816(%rbp,%rdx,8), %xmm1
        movq    %rax, %xmm0
        subsd   %xmm1, %xmm0
        movl    -36(%rbp), %eax
        cltq
        addq    $TWO_NTIMES, %rax
        movsd   %xmm0, -816(%rbp,%rax,8)
        movl    $0, %eax
        call    mysecond
        movl    -36(%rbp), %edx
        movslq  %edx, %rdx
        addq    $THREE_NTIMES, %rdx
        movq    %rax, -816(%rbp,%rdx,8)
        movq    $0, -48(%rbp)
        jmp     .L23
.L24:
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -120(%rbp), %rax
        addq    %rdx, %rax
        movsd   (%rax), %xmm1
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -128(%rbp), %rax
        addq    %rdx, %rax
        movsd   (%rax), %xmm0
        mulsd   -136(%rbp), %xmm0
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -112(%rbp), %rax
        addq    %rdx, %rax
        addsd   %xmm1, %xmm0
        movsd   %xmm0, (%rax)
        addq    $1, -48(%rbp)
.L23:
        cmpq    $D_STREAM_ARRAY_SIZE, -48(%rbp)
        jle     .L24
        movl    $0, %eax
        call    mysecond
        movl    -36(%rbp), %edx
        movslq  %edx, %rdx
        addq    $THREE_NTIMES, %rdx
        movsd   -816(%rbp,%rdx,8), %xmm1
        movq    %rax, %xmm0
        subsd   %xmm1, %xmm0
        movl    -36(%rbp), %eax
        cltq
        addq    $THREE_NTIMES, %rax
        movsd   %xmm0, -816(%rbp,%rax,8)
        addl    $1, -36(%rbp)
.L16:
        cmpl    $D_NTIMES, -36(%rbp)
        jle     .L25                                    
        movl    $1, -36(%rbp)
        jmp     .L26
.L35:
        movq    $0, -48(%rbp)
        jmp     .L27
.L34:
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -72(%rbp), %rax
        addq    %rdx, %rax
        movsd   (%rax), %xmm1
        movl    -36(%rbp), %eax
        movslq  %eax, %rcx
        movq    -48(%rbp), %rdx
        movq    %rdx, %rax
        salq    $2, %rax
        addq    %rdx, %rax
        addq    %rax, %rax
        addq    %rcx, %rax
        movsd   -816(%rbp,%rax,8), %xmm0
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -72(%rbp), %rax
        addq    %rdx, %rax
        addsd   %xmm1, %xmm0
        movsd   %xmm0, (%rax)
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -88(%rbp), %rax
        addq    %rdx, %rax
        movsd   (%rax), %xmm1
        movl    -36(%rbp), %eax
        movslq  %eax, %rcx
        movq    -48(%rbp), %rdx
        movq    %rdx, %rax
        salq    $2, %rax
        addq    %rdx, %rax
        addq    %rax, %rax
        addq    %rcx, %rax
        movsd   -816(%rbp,%rax,8), %xmm0
        comisd  %xmm1, %xmm0
        jbe     .L43
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -88(%rbp), %rax
        addq    %rdx, %rax
        movsd   (%rax), %xmm0
        jmp     .L30
.L43:
        movl    -36(%rbp), %eax
        movslq  %eax, %rcx
        movq    -48(%rbp), %rdx
        movq    %rdx, %rax
        salq    $2, %rax
        addq    %rdx, %rax
        addq    %rax, %rax
        addq    %rcx, %rax
        movsd   -816(%rbp,%rax,8), %xmm0
.L30:
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -88(%rbp), %rax
        addq    %rdx, %rax
        movsd   %xmm0, (%rax)
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -80(%rbp), %rax
        addq    %rdx, %rax
        movsd   (%rax), %xmm0
        movl    -36(%rbp), %eax
        movslq  %eax, %rcx
        movq    -48(%rbp), %rdx
        movq    %rdx, %rax
        salq    $2, %rax
        addq    %rdx, %rax
        addq    %rax, %rax
        addq    %rcx, %rax
        movsd   -816(%rbp,%rax,8), %xmm1
        comisd  %xmm1, %xmm0
        jbe     .L44
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -80(%rbp), %rax
        addq    %rdx, %rax
        movsd   (%rax), %xmm0
        jmp     .L33
.L44:
        movl    -36(%rbp), %eax
        movslq  %eax, %rcx
        movq    -48(%rbp), %rdx
        movq    %rdx, %rax
        salq    $2, %rax
        addq    %rdx, %rax
        addq    %rax, %rax
        addq    %rcx, %rax
        movsd   -816(%rbp,%rax,8), %xmm0
.L33:
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -80(%rbp), %rax
        addq    %rdx, %rax
        movsd   %xmm0, (%rax)
        addq    $1, -48(%rbp)
.L27:
        cmpq    $3, -48(%rbp)
        jle     .L34
        addl    $1, -36(%rbp)
.L26:
        cmpl    $D_NTIMES, -36(%rbp)
        jle     .L35
        movq    $NTIMES, %rdx
        movq    $STREAM_ARRAY_SIZE, %rsi
        leaq    fmt_info(%rip), %rdi
        movl    $0, %eax
        call    printf
        leaq    fmt_div(%rip), %rdi
        call    puts
        leaq    col_title_max(%rip), %r9
        leaq    col_title_min(%rip), %r8
        leaq    col_title_avg(%rip), %rcx
        leaq    col_title_rate(%rip), %rdx
        leaq    col_title_function(%rip), %rsi
        leaq    fmt_title(%rip), %rdi
        movl    $0, %eax
        call    printf
        movq    $0, -48(%rbp)
        jmp     .L36
.L37:
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -72(%rbp), %rax
        addq    %rdx, %rax
        movsd   (%rax), %xmm0
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -72(%rbp), %rax
        addq    %rdx, %rax
        movsd   LC20(%rip), %xmm1
        divsd   %xmm1, %xmm0
        movsd   %xmm0, (%rax)
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -80(%rbp), %rax
        addq    %rdx, %rax
        movsd   (%rax), %xmm3
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -88(%rbp), %rax
        addq    %rdx, %rax
        movsd   (%rax), %xmm2
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -72(%rbp), %rax
        addq    %rdx, %rax
        movsd   (%rax), %xmm4
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -104(%rbp), %rax
        addq    %rdx, %rax
        movsd   (%rax), %xmm1
        movsd   LC21(%rip), %xmm0
        mulsd   %xmm1, %xmm0
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rdx
        movq    -88(%rbp), %rax
        addq    %rdx, %rax
        movsd   (%rax), %xmm1
        divsd   %xmm1, %xmm0
        movq    %xmm0, %rdx
        movq    -48(%rbp), %rax
        leaq    0(,%rax,8), %rcx
        movq    -96(%rbp), %rax
        addq    %rcx, %rax
        movq    (%rax), %rax
        movapd  %xmm4, %xmm1
        movq    %rdx, %xmm0
        movq    %rax, %rsi
        leaq    fmt_row(%rip), %rdi
        movl    $4, %eax
        call    printf
        addq    $1, -48(%rbp)
.L36:
        cmpq    $3, -48(%rbp)
        jle     .L37
        movq    -112(%rbp), %rax
        movq    %rax, %rdi
        call    free
        movq    -120(%rbp), %rax
        movq    %rax, %rdi
        call    free
        movq    -128(%rbp), %rax
        movq    %rax, %rdi
        call    free
        movq    -72(%rbp), %rax
        movq    %rax, %rdi
        call    free
        movq    -80(%rbp), %rax
        movq    %rax, %rdi
        call    free
        movq    -88(%rbp), %rax
        movq    %rax, %rdi
        call    free
        movl    $0, -60(%rbp)
        jmp     .L38
.L39:
        movl    -60(%rbp), %eax
        cltq
        leaq    0(,%rax,8), %rdx
        movq    -96(%rbp), %rax
        addq    %rdx, %rax
        movq    (%rax), %rax
        movq    %rax, %rdi
        call    free
        addl    $1, -60(%rbp)
.L38:
        cmpl    $3, -60(%rbp)
        jle     .L39
        movq    -96(%rbp), %rax
        movq    %rax, %rdi
        call    free
        movq    -104(%rbp), %rax
        movq    %rax, %rdi
        call    free
        movl    $0, %eax
.L40:
        movq    -8(%rbp), %rbx
        movq    $0, %rax
    
        movq %rbp, %rsp
        popq %rbp

        ret
_mysecond:        
mysecond:
        pushq   %rbp
        movq    %rsp, %rbp
        subq    $48, %rsp
        leaq    -40(%rbp), %rdx
        leaq    -32(%rbp), %rax
        movq    %rdx, %rsi
        movq    %rax, %rdi
        call    gettimeofday
        movl    %eax, -4(%rbp)
        movq    -32(%rbp), %rax
        pxor    %xmm1, %xmm1
        cvtsi2sdq       %rax, %xmm1
        movq    -24(%rbp), %rax
        pxor    %xmm2, %xmm2
        cvtsi2sdq       %rax, %xmm2
        movsd   LC21(%rip), %xmm0
        mulsd   %xmm2, %xmm0
        addsd   %xmm1, %xmm0
        movq    %xmm0, %rax
        movq %rbp, %rsp
        popq %rbp
        ret
