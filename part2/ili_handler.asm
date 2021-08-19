.globl my_ili_handler
.section .data
msg: .ascii "hello im 35"
len: .quad len-msg
.text
.align 4, 0x90
my_ili_handler:
movq (%rsp),%rax
 
  
  pushq %rsi
  pushq %rdx
  pushq %rcx
  pushq %r9
  pushq %r10
  pushq %r11
  
  xorq %rdx,%rdx

  movq (%rax),%rdx
  
  cmp $0x0F,%dl
  jne one_byte_op
  

#cmpq $0x27, %rdx
#  je end

  
two_byte_op:
xorq %rdi,%rdi
 xorq %rdx,%rdx
mov (%rax),%rbx
shr $8,%rbx
mov %bl,%dl

movq  %rdx,%rdi 
pushq %rax
push %rdx
 callq what_to_do
pop %rdx
movq %rax,%rdi
popq %rax
 inc %rax
 inc %rax
jmp con
  
one_byte_op:
xorq %rbx,%rbx
mov %dl,%bl
movq  %rbx,%rdi 
pushq %rax
pushq %rdx
 callq what_to_do
pop %rdx
movq %rax,%rdi
pop %rax
  inc %rax
 con: 

  testq %rdi, %rdi 
je normalHandler
 popq %r11
  popq %r10
  popq %r9
  popq %rcx
  popq %rdx
  popq %rsi
 
 
  movq %rax,(%rsp)
    jmp end  
normalHandler:
  popq %r11
  popq %r10
  popq %r9
  popq %rcx
  popq %rdx
  popq %rsi
	jmp *old_ili_handler

  
  end:
  
  iretq






