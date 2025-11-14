

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


// want it to be Controller receiver
// switches automatically to controller mode upon generating a START condition

