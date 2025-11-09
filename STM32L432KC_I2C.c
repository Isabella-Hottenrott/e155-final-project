#include "STM32L432KC_I2C.h"
#include "STM32L432KC_RCC.h"
#include "STM32L432KC_GPIO.h"


#define ToF_sclk      9 // SCLK = PA9
#define ToF_sda      10 // SDA = PA10
#define ToF_addr
#define ToF_read

uint8_t ToF_readaddr = (ToF_addr << 1);  //{addr, 0}
uint8_t ToF_write = (ToF_addr << 1) | 1;  //{addr, 1}



void init_i2c1(){

RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
RCC->APB1ENR |= RCC_APB1ENR_I2C2EN;

pinMode(ToF_sclk, GPIO_ALT);                             // PA9 = SCLK want AF4
GPIOA->AFR[1] |= _VAL2FLD(GPIO_AFRL_AFSEL9, 4);     //AF4
pinMode(ToF_sda, GPIO_ALT);                             // PA10 = SDA want AF4
GPIOA->AFR[1] |= _VAL2FLD(GPIO_AFRL_AFSEL10, 4);   //AF5

GPIOA->OSPEEDR |= _VAL2FLD(GPIO_OSPEEDR_OSPEED9, 3); 
GPIOA->OSPEEDR |= _VAL2FLD(GPIO_OSPEEDR_OSPEED10, 3); 

GPIOA->OTYPER |= _VAL2FLD(GPIO_OTYPER_OTYPER9, 1); // not using internal pullups because they dont suffice
GPIOA->OTYPER |= _VAL2FLD(GPIO_OTYPER_OTYPER10, 1); // instead we must use external pullups 

I2C1->CR1 = I2C_CR1_SWRST;
I2C1->CR1 &= ~I2C_CR1_SWRST;
I2C1->CR2 |= 0x10;  // set clk source
I2C1->CCR = 0x50;   // set freq of sclk
I2C1->TRISE = 0x10; // look at website to do calculation for this. setting clock control
I2C1->CR1 |= I2C_CR1_PE; // enable i2c
}


uint8_t i2c1_read(uint8_t addr, uint8_t wordAddr){

uint8_t slaveaddrWr = (slaveaddr<<1) | 0;
uint8_t slaveaddrR = (slaveaddr << 1) | 1;

I2C1->CR1 |= I2C_CR1_START | I2C_CR1_ACK;       // create a start condition and make HW acknowledge every byte received
while (!(I2C1->SR1 & I2C_SR1_SB));              // wait to see if condition has been generated yet
I2C1->DR = slaveaddrWR;                        // send addr of slave device <WORD ADDR>
while (!(I2C1->SR1 & I2C_SR1_ADDR));            // monitor to addr has been received
uint16_t reg = I2C2->SR1 | I2C2->SR2;           // now clear ic2reg

while (!(I2C1->SR1 & I2C_SR1_TXE));             // check that the data register is empty
I2C1->DR = wordAddr;                             // now set the register pointer for addr we want to read from
while (!(I2C1->SR1 & I2C_SR1_BTF));             // wait for data to finish being transmitted

I2C1->CR1 |= I2C_CR1_START;                     // 
while (!(I2C1->SR1 & I2C_SR1_SB));
I2C1->DR = slaveaddrR;                          // send the Slave Address (reading)
while (!(I2C1->SR1 & I2C_SR1_ADDR));
reg = I2C1->SR1 | I2C1->SR2;                    // slave

while (!(I2C1->SR1 & I2C_SR1_RXNE));
uint8_t data = I2C1->DR;
I2C1->CR1 &= ~I2C_CR1_ACK;
I2C1->CR1 |= I2C_CR1_STOP;

return data;

}