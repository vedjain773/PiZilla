.globl load
load:
    ldar x0, [x0]
    ret

.globl store
store: 
    stlr x1, [x0]
    ret

.globl compare_and_swap
compare_and_swap:
    ldaxr x3, [x0]
    cmp x3, x1
    bne failure
    stlxr w4, x2, [x0]
    cmp w4, #0
    bne compare_and_swap
    mov x0, #1
    ret

failure:
    mov x0, #0
    ret
