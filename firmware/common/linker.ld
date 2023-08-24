
MEMORY
{
  FLASH    (rx)  : ORIGIN = 0x00000000, LENGTH = 1024K
  SRAM     (rwx) : ORIGIN = 0x20000000, LENGTH = 32K
  stack    (rw)  : ORIGIN = 0x20000000 + 28K, LENGTH = 4K
}

PROVIDE(__stack_top = ORIGIN(stack) + LENGTH(stack) );


/* Section Definitions */
SECTIONS
{
    
    .text : {
        *(.vectors)
        *(.text*)
        *(.rodata*)
        . = ALIGN(8);
        __idata__ = .;
    } > FLASH


    .data : 
    {
        __data_start__ = .;
        *(.data*);
        __data_end__ = .;
        _edata = .;
    PROVIDE( __global_pointer$ = . + 0x800 );
        
    } > SRAM AT > FLASH
    
    .bss (NOLOAD) :
    {
        __bss_start__ = .;
        *(.bss*)
        *(COMMON)
        __bss_end__ = .;
        _end = .;
    } > SRAM

    


}