.globl vector_init
vector_init:
	adr	x0, vectors         // load VBAR_EL1 with virtual
	msr	vbar_el1, x0        // vector table address
	ret

// Mask interrupts

.globl enable
enable:
	msr daifclr, #2 
	ret

// Unmask interrupts

.globl disable
disable:
	msr	daifset, #2
	ret
