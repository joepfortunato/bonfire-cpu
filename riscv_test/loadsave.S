.section .text
.global _start
.extern monitor
.extern mtime

_start:

la s0, monitor
la s1,mtime
li a1,0x100 // store area
li a2,0x0FA55AA55

lw a3,0(s1) // get timer
sw a3,4(s0)
addi t1,a3,100 // increment timer value by 100
sw t1,8(s1) // write to timer compare register

loop:
li gp,0x200  // test result area
sw a2, 0(a1)  // Test word r/w
lw t4, 0(a1)   // => FA55AA55
jal store 
sb a2, 8(a1) // store two bytes
sb a2, 9(a1)
lw t4,8(a1)  // => 00005555
jal store
lbu t4, 1(a1) // 1(a1) contains AA (see above) => 000000AA
jal store
lb t4,1(a1)   // same signed => FFFFFFAA
jal store
lbu t4,0(a1) // => 00000055
jal store
lb  t4,0(a1) // => 00000055
jal store
sh a2,12(a1) // Store 16 Bit Word
srli t1,a2,16  
sh t1,14(a1) // Store Upper half of a2
 
lw t4,12(a1) // should be FA55AA55
jal store

lhu t4,14(a1) // => 0000FA55
jal store
lh  t4,14(a1) // => FFFFFA55
jal store
lhu t4,12(a1) // => 0000AA55
jal store
lh  t4,12(a1) // => FFFFAA55
jal store

sh t1,17(a1) // test store of "middle" half word
lw t4,16(a1) // => 00FA5500
jal store
lhu t4,1(a1) // => 000055AA
jal store 

lw a3,0(s1) 
sw a3,4(s0)

li t0,1  
sw t0,0(s0) // write 1 to monitor result register 

j loop

store: // store t4 to mem and increment
sw t4,0(gp) // save result
add gp,gp,4 // increment pointer
ret
