#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {
asm volatile("sidt %0":"=m" (*idtr));
}

void my_load_idt(struct desc_ptr *idtr) {
asm volatile("lidt %0"::"m" (*idtr));
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
gate->segment = __KERNEL_CS;
	gate->reserved= 0;
	gate->bits.ist = 0;
	gate->bits.p = 1;
	gate->bits.dpl = 0;
	gate->bits.zero = 0;
	//gate->zero1 = 0;
	gate->bits.type = GATE_INTERRUPT;
	gate->offset_low = (unsigned long long)(addr) & 0xFFFF;
	gate->offset_middle = ((unsigned long long)(addr) >> 16) & 0xFFFF;
	gate->offset_high = (unsigned long long)(addr) >> 32;
}

unsigned long my_get_gate_offset(gate_desc *gate) {
return gate->offset_low | ((unsigned long)gate->offset_middle << 16) |
		((unsigned long)gate->offset_high << 32);

}