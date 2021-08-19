.global get_elemnt_from_matrix, multiplyMatrices
.extern set_elemnt_in_matrix


.section .text
get_elemnt_from_matrix:
	#int get_elemnt_from_matrix(int* matrix(rdi), int n(rsi), int row(rdx), int col(rcx))

	imulq %rsi,%rdx     # rdx=n*row
 	addq  %rcx,%rdx     # rdx+= col
	imulq $4,%rdx,%rdx  # rdx=4*rdx  |int|=4 bytes
	addq  %rdx,%rdi     # rdi+= 4*(n*row+col)
	movl  (%rdi),%eax   # rax=*matrix(...)
	ret


multiplyMatrices:
	#void multiplyMatrices(int* first(mxn)(rdi), int* second(nxr)(rsi), int* result(mxr)(rdx),
						   #int m(rcx), int n(r8), int r(r9),unsigned int p(onStack))
	
        pushq   %rbp
        movq    %rsp, %rbp
	subq    $4, %rsp         # -4(%rbp)=tmp , 16(%rbp)=p 

	xorq %r12,%r12  #f_i
	xorq %r13,%r13  #f_j
	xorq %r14,%r14  #s_i
	xorq %r15,%r15  #s_j

	xorq %rbx,%rbx  	# curr_sum

myloop:
	
	# get_elemnt_from_matrix(first,n,f_i,f_j)
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8
	pushq %r9
	movq %r8,%rsi						# rsi=n
	movq %r12,%rdx
	movq %r13,%rcx
	xorq %rax,%rax
	call get_elemnt_from_matrix	
	xorq %rdx,%rdx   					# for div
	xorq %rdi,%rdi	
	movl 16(%rbp),%edi 					# edi=p
	divq  %rdi                          # first[i,j]=rax/rdi=op=p -> reminder=rdx
	movl %edx,-4(%rbp)                  # tmp=first[i,j]%p
	popq %r9
	popq %r8
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi
	
	# get_elemnt_from_matrix(second,r,s_i,s_j)
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8
	pushq %r9
	movq %rsi,%rdi
	movq %r9,%rsi
	movq %r14,%rdx
	movq %r15,%rcx
	xorq %rax,%rax
	call get_elemnt_from_matrix
	xorq %rdx,%rdx   		          # for div
	xorq %rdi,%rdi
	movl 16(%rbp),%edi 		          # edi=p
	divq  %rdi				  # rdx=second[i,j]%p
	
	xorq %rax,%rax
	movl -4(%rbp),%eax
	imul %rdx,%rax   			  # rcx= first[i,j]%p*second[i,j]%p

	xorq %rdx,%rdx
	divq  %rdi                                # edx=(first[i,j]%p*second[i,j]%p)(mod p)

	addq %rdx,%rbx                    	  #curr_sum+=rdx
	movq %rbx,%rax
	xorq %rdx,%rdx
	divq  %rdi
	movq %rdx,%rbx                            #curr_sum=curr_sum(mod p)

	popq %r9
	popq %r8
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi
	
	incq %r13        # f_j++
	incq %r14        # s_i++
	cmpq %r13,%r8    # if(f_j==n)
	je next_res_ij
	jmp myloop
	
next_res_ij:
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8
	pushq %r9
	
	#void set_elemnt_in_matrix(int* matrix(rdi), int num_of_columns(rsi), int row(rdx), int col(rcx), int value(r8))
	movq %rdx,%rdi
	movq %r9,%rsi    # num_of_columns=r
	movq %r12,%rdx   # row=f_i
	movq %r15,%rcx   # col=s_j
	movq %rbx,%r8    # value=curr_sum
	call set_elemnt_in_matrix
	popq %r9
	popq %r8
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi

	xorq %rbx,%rbx   # curr_sum=0	
	xorq %r13,%r13   # f_j=0
	xorq %r14,%r14   # s_i=0
	incq %r15        # s_j++

	cmp %r15,%r9     # if (s_j==r)
	je newColSec
	jmp myloop

newColSec:
	xorq %r15,%r15	 # s_j=0
	incq %r12        # f_i++
	cmpq %r12,%rcx   # if(f_i==m)
    	je end
	jmp myloop
	
end:	
	leave
	ret
