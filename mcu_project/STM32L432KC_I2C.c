

#include "STM32L432KC_I2C.h"
#include "STM32L432KC_RCC.h"
#include "STM32L432KC_GPIO.h"



#define ToF_sclk      9 // SCLK = PA9
#define ToF_sda      10 // SDA = PA10
#define ToF_addr
#define ToF_read
#define I2C1_TIMINGR_VALUE 0x00B07CB4
//#define slaveaddr 0x52

//during a write sequence, the second byte received provides a 8-bit index whihc points to one of the 8bit internal registerms


void init_i2c1(){

RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN;

pinMode(ToF_sclk, GPIO_ALT);                             // PA9 = SCLK want AF4
GPIOA->AFR[1] |= _VAL2FLD(GPIO_AFRH_AFSEL9, 4);     //AF4
pinMode(ToF_sda, GPIO_ALT);                             // PA10 = SDA want AF4
GPIOA->AFR[1] |= _VAL2FLD(GPIO_AFRH_AFSEL10, 4);   //AF4

GPIOA->OSPEEDR |= _VAL2FLD(GPIO_OSPEEDR_OSPEED9, 3); 
GPIOA->OSPEEDR |= _VAL2FLD(GPIO_OSPEEDR_OSPEED10, 3); 

GPIOA->OTYPER |= _VAL2FLD(GPIO_OTYPER_OT9, 1); // not using internal pullups because they dont suffice
GPIOA->OTYPER |= _VAL2FLD(GPIO_OTYPER_OT10, 1); // instead we must use external pullups

GPIOA->PUPDR &= ~(GPIO_PUPDR_PUPD9_Msk | GPIO_PUPDR_PUPD10_Msk); //no pull (external)

RCC->CR |= RCC_CR_HSION;
while ((RCC->CR & RCC_CR_HSIRDY) == 0) { /* wait */ }

RCC->CCIPR &= ~(RCC_CCIPR_I2C1SEL_Msk);
RCC->CCIPR |=  (2U << RCC_CCIPR_I2C1SEL_Pos);
RCC->APB1ENR1 |= RCC_APB1ENR1_I2C1EN;

I2C1->CR1 &= ~I2C_CR1_PE; // disable
I2C1->CR1 &= ~I2C_CR1_NOSTRETCH;
I2C1->TIMINGR = I2C1_TIMINGR_VALUE;
I2C1->CR1 |= I2C_CR1_PE; // enable i2c
}

/*
uint8_t i2c1_read(uint8_t slaveaddr, uint8_t wordAddr){

uint8_t slaveaddrWr = (slaveaddr<<1) | 0;
uint8_t slaveaddrR = (slaveaddr << 1) | 1;

I2C1->CR1 |= I2C_CR2_START | I2C_CR1_ACK;       // create a start condition and make HW acknowledge every byte received
while (!(I2C1->SR1 & I2C_SR1_SB));              // wait to see if condition has been generated yet
I2C1->TXDR = slaveaddrWr;  //TODO: correct register??                      // send addr of slave device <WORD ADDR>
while (!(I2C1->SR1 & I2C_SR1_ADDR));            // monitor to addr has been received
uint16_t reg = I2C2->SR1 | I2C2->SR2;           // now clear ic2reg

while (!(I2C1->SR1 & I2C_SR1_TXE));             // check that the data register is empty
I2C1->TXDR = wordAddr;                             // now set the register pointer for addr we want to read from
while (!(I2C1->SR1 & I2C_SR1_BTF));             // wait for data to finish being transmitted

I2C1->CR1 |= I2C_CR1_START;                     // 
while (!(I2C1->SR1 & I2C_SR1_SB));
I2C1->RXDR = slaveaddrR;                          // send the Slave Address (reading)
while (!(I2C1->SR1 & I2C_SR1_ADDR));
reg = I2C1->SR1 | I2C1->SR2;                    // slave

while (!(I2C1->SR1 & I2C_SR1_RXNE));
uint8_t data = I2C1->DR;
I2C1->CR1 &= ~I2C_CR1_ACK;
I2C1->CR1 |= I2C_CR1_STOP;

return data;

}



// want it to be Controller receiver
// switches automatically to controller mode upon generating a START condition





//I2C1->CR2 
// set ADD10 to 7-bit
// set 

uint8_t i2c1_read(uint8_t slaveaddr, uint8_t wordAddr){


I2C1->CR2 |= _VAL2FLD(I2C_CR2_ADD10, 0); 
I2C1->CR2 |= _VAL2FLD(I2C_CR2_SADD, slaveaddr); 
I2C1->CR2 |= _VAL2FLD(I2C_CR2_RD_WRN, 1);     // Requesting read transfer
I2C1->CR2 |= _VAL2FLD(I2C_CR2_HEAD10R, 1);     // Requesting read
I2C1->CR2 |= _VAL2FLD(I2C_CR2_NBYTES, 1);     // Will only be receiving one byte


I2C1->CR1 |= I2C_CR2_START;                     // create a start condition and make HW acknowledge every by
while (!(I2C1->SR1 & I2C_SR1_SB));              // wait to see if condition has been generated yet
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
*/

void i2c1_write(uint8_t addr, uint8_t *data, uint8_t nbytes) {
    // Wait if busy
    while (I2C1->ISR & I2C_ISR_BUSY);

    // Set slave address, write mode (RD_WRN=0), number of bytes, AUTOEND=1
    I2C1->CR2 = ((addr & 0x7F) << 1) |  // SADD
                (nbytes << 16)        |  // NBYTES
                I2C_CR2_AUTOEND;         // Auto STOP after last byte

    // Generate START
    I2C1->CR2 |= I2C_CR2_START;

    // Send bytes
    for (uint8_t i = 0; i < nbytes; i++) {
        while (!(I2C1->ISR & I2C_ISR_TXIS));   // Wait for TX ready
        I2C1->TXDR = data[i];
    }

    // Wait for STOP flag (transfer complete)
    while (!(I2C1->ISR & I2C_ISR_STOPF));
    I2C1->ICR |= I2C_ICR_STOPCF;  // Clear STOP flag
}

void i2c1_read(uint8_t addr, uint8_t *data, uint8_t nbytes) {
    // Wait if busy
    while (I2C1->ISR & I2C_ISR_BUSY);

    // Configure transfer: RD_WRN=1 (read), NBYTES, AUTOEND=1
    I2C1->CR2 = ((addr & 0x7F) << 1) |
                (1 << 10) |            // RD_WRN = 1 (read)
                (nbytes << 16) |
                I2C_CR2_AUTOEND;

    // Generate START
    I2C1->CR2 |= I2C_CR2_START;

    // Receive bytes
    for (uint8_t i = 0; i < nbytes; i++) {
        while (!(I2C1->ISR & I2C_ISR_RXNE));  // Wait for received byte
        data[i] = I2C1->RXDR;
    }

    // Wait for STOP flag
    while (!(I2C1->ISR & I2C_ISR_STOPF));
    I2C1->ICR |= I2C_ICR_STOPCF;  // Clear STOP flag
}

