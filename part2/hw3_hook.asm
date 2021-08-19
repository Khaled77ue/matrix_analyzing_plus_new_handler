.global hook

.section .data
msg: .ascii "This code was hacked by Noa Killa's gang\n"
endmsg:

.section .text
hook:
  movq $60, %rax
  movq $0, %rdi
  syscall
