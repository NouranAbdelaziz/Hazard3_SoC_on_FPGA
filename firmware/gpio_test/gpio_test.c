
#include <stdint.h>

#define GPIO_REG_ADDR 0x40008000

int main(){

    int i; 
	
	// for simulation 

	while (1){
        for (i = 0; i < 10; i++) {
			(*(volatile uint32_t*) GPIO_REG_ADDR ) = 1;
		}
		for (i = 0; i < 10; i++) {
			(*(volatile uint32_t*) GPIO_REG_ADDR ) = 0;
		}
    }

	// for FPGA validation 

    /*while (1){
        for (i = 0; i < 100000; i++) {
			(*(volatile uint32_t*) GPIO_REG_ADDR ) = 1;
		}
		for (i = 0; i < 100000; i++) {
			(*(volatile uint32_t*) GPIO_REG_ADDR ) = 0;
		}
    }*/

    
}
