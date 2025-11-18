

#include "STM32L432KC_I2C.h"
#include "STM32L432KC_RCC.h"
#include "STM32L432KC_GPIO.h"
#include <stdio.h>



#define ToF_sclk      9 // SCLK = PA9
#define ToF_sda      10 // SDA = PA10
#define ToF_addr
#define ToF_read
#define I2C1_TIMINGR_VALUE 0x00403D59
// try above with HSI on
//#define slaveaddr 0x52

//during a write sequence, the second byte received provides a 8-bit index whihc points to one of the 8bit internal registerms


void init_i2c1(){

RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN;              
RCC->CCIPR |= _VAL2FLD(RCC_CCIPR_I2C1SEL, 0b10);  // HSI
RCC->APB1ENR1 |= RCC_APB1ENR1_I2C1EN; 


pinMode(ToF_sclk, GPIO_ALT);                             // PA9 = SCLK want AF4
GPIOA->AFR[1] |= _VAL2FLD(GPIO_AFRH_AFSEL9, 4);     //AF4
pinMode(ToF_sda, GPIO_ALT);                             // PA10 = SDA want AF4
GPIOA->AFR[1] |= _VAL2FLD(GPIO_AFRH_AFSEL10, 4);   //AF4

GPIOA->OSPEEDR |= _VAL2FLD(GPIO_OSPEEDR_OSPEED9, 3); 
GPIOA->OSPEEDR |= _VAL2FLD(GPIO_OSPEEDR_OSPEED10, 3); 

GPIOA->OTYPER |= _VAL2FLD(GPIO_OTYPER_OT9, 1); // not using internal pullups because they dont suffice
GPIOA->OTYPER |= _VAL2FLD(GPIO_OTYPER_OT10, 1); // instead we must use external pullups

GPIOA->PUPDR &= ~(GPIO_PUPDR_PUPD9_Msk | GPIO_PUPDR_PUPD10_Msk); //no pull (external)

I2C1->CR1 &= ~I2C_CR1_PE; // disable
I2C1->CR1 &= ~I2C_CR1_ANFOFF; 
I2C1->CR1 |= I2C_CR1_RXIE;    
I2C1->CR1 |= I2C_CR1_TXIE;   
I2C1->CR1 |= I2C_CR1_TCIE;     
I2C1->CR1 &= ~I2C_CR1_NOSTRETCH;
I2C1->TIMINGR &= ~0b11111111111111111111111111111111;
I2C1->TIMINGR = 0x30420F13;  // from datasheet


I2C1->CR1 |= I2C_CR1_PE; // enable i2c
I2C1->CR1 &= ~I2C_CR1_PE; // toggle just in case
I2C1->CR1 |= I2C_CR1_PE; // 
}





void i2c1_write(uint8_t addr, uint8_t *data, uint8_t nbytes) {
    // Blocking master write (7-bit addressing)
    // Wait until bus not busy
    while (I2C1->ISR & I2C_ISR_BUSY) { }

    // Clear previous flags (NACK, STOP)
    I2C1->ICR = I2C_ICR_NACKCF | I2C_ICR_STOPCF;

    // Configure transfer: 7-bit addr (SADD contains addr<<1), NBYTES, AUTOEND
    // Do NOT set HEAD10R here (we're using 7-bit addressing)
    I2C1->CR2 = ((addr & 0x7F) << 1) | // SADD
                ((uint32_t)nbytes << 16) | // NBYTES
                I2C_CR2_AUTOEND;

    // Generate START
    I2C1->CR2 |= I2C_CR2_START;

    // Send bytes
    for (uint8_t i = 0; i < nbytes; i++) {
        while ((!(I2C1->ISR & I2C_ISR_TXIS))&((!(I2C1->ISR & I2C_ISR_NACKF))));   // Wait for TX ready
       
        if (I2C1->ISR & I2C_ISR_TXIS){
        I2C1->TXDR = data[i];
        }
        if (I2C1->ISR & I2C_ISR_NACKF)
        { 
        printf("nackf \n");
        return; 
        }
    }

    // Wait for STOP flag (transfer complete)
    if (I2C1->ISR & I2C_ISR_TC){
    printf("error2\n");
    //TODO: figure out what we need to put here (pg 1176)
    }
    

}

void i2c1_read(uint8_t addr, uint8_t *data, uint8_t nbytes) {
    // Blocking master read (7-bit addressing)
    // Wait until bus not busy
    while (I2C1->ISR & I2C_ISR_BUSY) { }

    // Clear previous flags
    I2C1->ICR = I2C_ICR_NACKCF | I2C_ICR_STOPCF;

    // Configure transfer: 7-bit addr, NBYTES, AUTOEND, set read direction (RD_WRN)
    I2C1->CR2 = ((addr & 0x7F) << 1) | ((uint32_t)nbytes << 16) | I2C_CR2_AUTOEND | I2C_CR2_RD_WRN;

    // Generate START
    I2C1->CR2 |= I2C_CR2_START;

    // Receive bytes
    for (uint8_t i = 0; i < nbytes; i++) {
        // Wait for RXNE or NACK
        while (!(I2C1->ISR & (I2C_ISR_RXNE | I2C_ISR_NACKF))) { }

        if (I2C1->ISR & I2C_ISR_NACKF) {
            I2C1->ICR = I2C_ICR_NACKCF;
            printf("i2c1_read: NACK received\n");
            return;
        }

        data[i] = I2C1->RXDR;
    }

    // Wait for STOP flag and clear it
    while (!(I2C1->ISR & I2C_ISR_STOPF)) { }
    I2C1->ICR = I2C_ICR_STOPCF;
}

