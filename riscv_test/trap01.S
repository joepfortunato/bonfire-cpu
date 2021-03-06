.section .text
.global _start
_start:

la s0, monitor

li a2,0x0FA55AA55

la a1, trap_handler
csrw mtvec,a1 


loop:
la gp,result_area  // test result area

ecall 
mv t4,a2
jal store
ebreak
mv t4,a2
jal store
mulh t4,x0,x0 // not implemented should trap
mv t4,a2
jal store
lw t4,1(gp) // misalignment load trap
mv t4,a2    // write test pattern
jal store
sw t4,1(gp) // misalignment store trap
mv t4,a2    // write test pattern
jal store
lhu t4,3(gp) // misalign again
mv t4,a2
jal store
lhu t4,-2(gp) // should not trap
jal store

csrw 0x380,a2 // should trap
csrr a2,0x380 // trap again
mv t4,a2
jal store
// Test double invalid opcode
mulh t4,x0,x0 // not implemented should trap
mulh t4,x0,x0 // not implemented should trap
addi t4,a2,1 // end marker
jal store

finish:
li a0,1
sw a0,0(s0) // write to monitor result register 
f0:
j f0




store: // store t4 to mem and increment
sw t4,0(gp) // save result
add gp,gp,4 // increment pointer
ret

trap_handler:
csrr t4,mcause
jal store

csrrw t4,mbadaddr,x0 // read and clear...
jal store

csrr t4,mepc
jal store

addi t1,t4,4 // increment mepc in case of exceptions
csrw mepc,t1
sret

.align 8
result_area:

