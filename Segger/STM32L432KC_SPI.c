// STM32L432KC_SPI.c
// Isabella Hottenrott
// ihottenrott@g.hmc.edu
// 30/10/25


#include "STM32L432KC_RCC.h"
#include "STM32L432KC_GPIO.h"
#include "STM32L432KC_SPI.h"



void initSPI(int br, int cpol, int cpha){

// GPIO and SPI Clock enables
RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN;
RCC->AHB2ENR |= RCC_AHB2ENR_GPIOBEN;
RCC->APB2ENR |= RCC_APB2ENR_SPI1EN;

//disable SPI for the configurations
SPI1->CR1 |= _VAL2FLD(SPI_CR1_SPE, 0);                          

SPI1->CR1 |= _VAL2FLD(SPI_CR1_BR, br);            // set the Baud rate (will want 3)
SPI1->CR1 |= _VAL2FLD(SPI_CR1_CPOL, cpol);              // set CPOL 0 when idle
SPI1->CR1 |= _VAL2FLD(SPI_CR1_CPHA, cpha);              // set CPHA 1 to match DS1722
SPI1->CR1 |= _VAL2FLD(SPI_CR1_BIDIMODE, 0);          // two line unidirectional data mode
SPI1->CR1 |= _VAL2FLD(SPI_CR1_LSBFIRST, 0);          // msb transmitted first

SPI1->CR1 |= _VAL2FLD(SPI_CR1_SSM, 1);              // Software peripheral management
SPI1->CR1 |= _VAL2FLD(SPI_CR1_SSI, 1);              // value forced onto NSS pin
SPI1->CR1 |= _VAL2FLD(SPI_CR1_MSTR, 1);             // master

SPI1->CR2 |= _VAL2FLD(SPI_CR2_DS, 7);               // Data size is eight bits
SPI1->CR2 |= _VAL2FLD(SPI_CR2_FRXTH, 1);            // FIFO reception threshold if 8 bits
SPI1->CR2 |= _VAL2FLD(SPI_CR2_SSOE, 0);             // SS output disable

pinMode(PB3, GPIO_ALT);                             // PB3 = SCLK want AF5
GPIOB->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL3, 5);     //AF5
pinMode(PB4, GPIO_ALT);                             // PB4 = MISO want AF5
GPIOB->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL4, 5);   //AF5
pinMode(PB5, GPIO_ALT);                             // PB5 = MOSI want AF5
GPIOB->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL5, 5);   //AF5


GPIOB->OSPEEDR |= _VAL2FLD(GPIO_OSPEEDR_OSPEED3, 1); 

SPI1->CR1 |= _VAL2FLD(SPI_CR1_SPE, 1);                            //Enable SPI
}


// Simultaneously Send and Receive a single byte
uint8_t spiSendReceive(uint8_t send){
    while (!(SPI1->SR & SPI_SR_TXE));               // wait until TX FIFO is empty
    *(volatile uint8_t *) (&SPI1->DR) = send;       // Send a byte
    while (!(SPI1->SR & SPI_SR_RXNE));              // wait until RX FIFO is empty
    uint8_t r = *(volatile uint8_t *)&SPI1->DR;     // return whats in the buffer
    return r;
}

uint8_t spiSend(uint8_t send){
    while (!(SPI1->SR & SPI_SR_TXE));               // wait until TX FIFO is empty
    *(volatile uint8_t *) (&SPI1->DR) = send;       // Send a byte
    while (!(SPI1->SR & SPI_SR_RXNE));              // wait until RX FIFO is empty
}



// on FPGA:
// PB3 -> Pin 21 (sck)
// PB4 -> Pin x (MISO) (so sdo non existent on fpga dont need)
// PB5 -> Pin 19 (MOSI) (so sdo non existent on fpga dont need)
// PB6 -> Pin 20 (CS) 