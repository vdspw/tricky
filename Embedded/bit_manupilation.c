#include<stdio.h> 
#include<stdint.h> //uint32_t

typedef enum{
    BIT_SET,
    BIT_CLEAR
} bit_op_t;
// this is the structrue to define the operating states.

uint32_t bit_manupilation(uint32_t *reg,int bit_pos, bit_op_t op){
    if(bit_pos < 0 || bit_pos >31){
        return *reg; //no change
    }
    
    //creation of the mask 
    uint32_t mask = (1U << bit_pos); 
    
    if(op == BIT_SET){
        *reg = *reg | mask;
    }else if(op == BIT_CLEAR){
        *reg = *reg & ~mask;
    }
    return *reg;
}

// main function
int main(){
    uint32_t reg = 0x0000005; // hex value 5
    printf("Initial value is 0x%08X\n", reg);
    
    bit_manupilation(&reg, 3, BIT_SET);
    printf("After set bit 3: 0x%08X\n", reg);
    
    bit_manupilation(&reg, 0, BIT_CLEAR);
    printf("After clear bit 0: 0x%08X\n", reg);
    
    return 0;
}

