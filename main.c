#include "STM32L432KC.h"
#include "STM32L432KC_I2C.h"
#include "VL53L0X.h"
#include <stdlib.h>
#include <stdio.h>


#define Lidar1 PA11
#define Lidar2 PA12
#define Lidar3 PA3
#define Lidar4 PA2
#define Lidar5 PA1
#define CS     PB7
#define reset  PB0 //CHANGE!
#define nextRoundButton  PB1 //CHANGE!

#define rstScreen 00000100
#define startScreen 00000110
#define plcMoveScreen 00001000
#define dsplCompScreen 10001010
#define dsplWinLoseScreen 10010000
#define nextrndScreen 00010000
#define tenDoneScreen 01111110


//Fn Prototype
uint8_t formatPlays(uint8_t userRPS, uint8_t computerRPS);
uint8_t scan(struct VL53L0X *TOF1,
             struct VL53L0X *TOF2,
             struct VL53L0X *TOF3,
             struct VL53L0X *TOF4,
             struct VL53L0X *TOF5);
void play_round(struct VL53L0X *TOF1,
             struct VL53L0X *TOF2,
             struct VL53L0X *TOF3,
             struct VL53L0X *TOF4,
             struct VL53L0X *TOF5);


int main(){

    struct VL53L0X myTOFsensor1;
    myTOFsensor1.io_2v8 = false;
    myTOFsensor1.address = 0b0101001;
    myTOFsensor1.io_timeout = 500;
    myTOFsensor1.did_timeout = false;

    struct VL53L0X myTOFsensor2;
    myTOFsensor2.io_2v8 = false;
    myTOFsensor2.address = 0b0101001;
    myTOFsensor2.io_timeout = 500;
    myTOFsensor2.did_timeout = false;


    struct VL53L0X myTOFsensor3;
    myTOFsensor3.io_2v8 = false;
    myTOFsensor3.address = 0b0101001;
    myTOFsensor3.io_timeout = 500;
    myTOFsensor3.did_timeout = false;

    struct VL53L0X myTOFsensor4;
    myTOFsensor4.io_2v8 = false;
    myTOFsensor4.address = 0b0101001;
    myTOFsensor4.io_timeout = 500;
    myTOFsensor4.did_timeout = false;

    struct VL53L0X myTOFsensor5;
    myTOFsensor5.io_2v8 = false;
    myTOFsensor5.address = 0b0101001;
    myTOFsensor5.io_timeout = 500;
    myTOFsensor5.did_timeout = false;

    configurePLL();
    configureFlash();
    configureHSIasClk();
    gpioEnable(GPIO_PORT_A);
    gpioEnable(GPIO_PORT_B);
    pinMode(PB3, GPIO_OUTPUT);
    init_i2c1();
    RCC->APB2ENR |= (1<<16);
    initTIM(TIM15);
    initSPI(1, 0, 0);


    pinMode(Lidar1, GPIO_OUTPUT);
    pinMode(Lidar2, GPIO_OUTPUT);
    pinMode(Lidar3, GPIO_OUTPUT);
    pinMode(Lidar4, GPIO_OUTPUT);
    pinMode(Lidar5, GPIO_OUTPUT);
    pinMode(CS, GPIO_OUTPUT);

    digitalWrite(Lidar1, PIO_LOW);
    digitalWrite(Lidar2, PIO_LOW);
    digitalWrite(Lidar3, PIO_LOW);
    digitalWrite(Lidar4, PIO_LOW);
    digitalWrite(Lidar5, PIO_LOW);
    digitalWrite(CS, PIO_LOW);

    
    

    
    digitalWrite(Lidar1, PIO_HIGH);
    delay_millis(TIM15, 1);
    printf("initTOF1addr = %d\n", myTOFsensor1.address);
    VL53L0X_init(&myTOFsensor1);
    VL53L0X_setAddress(&myTOFsensor1, 0b0000001);
    myTOFsensor1.address = 0b0000001;
    printf("secondTOF1addr = %d\n", myTOFsensor1.address);
    
    digitalWrite(Lidar2, PIO_HIGH);
    delay_millis(TIM15, 1);
    printf("initTOF2addr = %d\n", myTOFsensor2.address);
    VL53L0X_init(&myTOFsensor2);
    VL53L0X_setAddress(&myTOFsensor2, 0b0000010);
    myTOFsensor2.address = 0b0000010;
    printf("secondTOF2addr = %d\n", myTOFsensor2.address);

    digitalWrite(Lidar3, PIO_HIGH);
    delay_millis(TIM15, 1);
    printf("initTOF3addr = %d\n", myTOFsensor3.address);
    VL53L0X_init(&myTOFsensor3);
    VL53L0X_setAddress(&myTOFsensor3, 0b0000011);
    myTOFsensor3.address = 0b0000011;
    printf("secondTOF3addr = %d\n", myTOFsensor3.address);

    digitalWrite(Lidar4, PIO_HIGH);
    delay_millis(TIM15, 1);
    VL53L0X_init(&myTOFsensor4);
    printf("initTOF4addr = %d\n", myTOFsensor4.address);
    VL53L0X_setAddress(&myTOFsensor4, 0b0000100);
    myTOFsensor4.address = 0b0000100;
    printf("secondTOF4addr = %d\n", myTOFsensor4.address);

    digitalWrite(Lidar5, PIO_HIGH);
    delay_millis(TIM15, 1);
    VL53L0X_init(&myTOFsensor5);
    printf("initTOF5addr = %d\n", myTOFsensor5.address);
    VL53L0X_setAddress(&myTOFsensor5, 0b0000101);
    myTOFsensor5.address = 0b0000101;
    printf("secondTOF5addr = %d\n", myTOFsensor5.address);
    
    delay_millis(TIM15, 100);



    if (reset) {
      digitalWrite(CS, PIO_HIGH);
      spiSend(rstScreen);
      digitalWrite(CS, PIO_LOW);
    }

    while(~reset){
    while(~nextRoundButton);
    
    digitalWrite(CS, PIO_HIGH);
    spiSend(startScreen);
    digitalWrite(CS, PIO_LOW);

    delay_millis(TIM15, 5000);

    int i;

    while(~reset){
    for (i=0; i<10; i++){
      play_round(&myTOFsensor1, &myTOFsensor2, &myTOFsensor3, &myTOFsensor4, &myTOFsensor5);
    }
    printf("next round \n");
    delay_millis(TIM15, 5000);
    }

    digitalWrite(CS, PIO_HIGH);
    spiSend(tenDoneScreen);
    digitalWrite(CS, PIO_LOW);
    }

    while(1);



}


uint8_t formatPlays(uint8_t userRPS, uint8_t computerRPS) {

  uint8_t formatPlay;

    switch(computerRPS){
        case 0: // computer choses rock
            printf("computer chooses rock\n");
            if (userRPS == 0){
                formatPlay = 1; // 8'b00_00_00_1 
                printf("user rock\n");
                break;
            } else if (userRPS == 1){
                formatPlay = 33; // 8'b01_00_00_1 
                printf("user paper\n");
                break;
            } else if (userRPS == 2){
                formatPlay = 65; // 8'b10_00_00_1 
                printf("user scissors\n");
                break;
            }

        case 1: // computer chooses paper
            printf("computer chooses paper\n");
            if (userRPS == 0){
                formatPlay = 9; // 8'b00_01_00_1 
                printf("user rock\n");
                break;
            } else if (userRPS == 1){
                formatPlay = 41; // 8'b01_01_00_1 
                printf("user paper\n");
                break;
            } else if (userRPS == 2){
                formatPlay = 73; // 8'b10_01_00_1 
                printf("user scissors\n");
                break;
            }

        case 2: // computer chooses scissors
            printf("computer chooses scissors\n");
            if (userRPS == 0){
                formatPlay = 17; // 8'b00_10_00_1 
                printf("user rock\n");
                break;
            } else if (userRPS == 1){
                formatPlay = 49;  // 8'b01_10_00_1 
                printf("user paper\n");
                break;
            } else if (userRPS == 2){
                formatPlay = 81;     // 8'b10_10_00_1 
                printf("user scissors\n");
                break;
            }
    }

    return formatPlay;
}

uint8_t scan(struct VL53L0X *TOF1,
             struct VL53L0X *TOF2,
             struct VL53L0X *TOF3,
             struct VL53L0X *TOF4,
             struct VL53L0X *TOF5) {
  float dist1, dist2, dist3, dist4, dist5;
    float dist2cont, dist3cont;


     int count = 0;
     uint8_t userRPS = 0;



      delay_millis(TIM15, 2);
      dist1 = VL53L0X_readRangeSingleMillimeters(TOF1);
      delay_millis(TIM15, 2);
      dist2 = VL53L0X_readRangeSingleMillimeters(TOF2);
      delay_millis(TIM15, 2);
      dist3 = VL53L0X_readRangeSingleMillimeters(TOF3);
      delay_millis(TIM15, 2);
      dist4 = VL53L0X_readRangeSingleMillimeters(TOF4);
      delay_millis(TIM15, 2);
      dist5 = VL53L0X_readRangeSingleMillimeters(TOF5); 
      delay_millis(TIM15, 2);

      printf("1= %f\n", dist1);
      printf("2= %f\n", dist2);
      printf("3= %f\n", dist3);
      printf("4= %f\n", dist4);
      printf("5= %f\n", dist5);



      if(dist1 < 500){
        count++;
      }
      if(dist3 < 500){
        count++;
      }
      if(dist5 < 500){
        count++;
      }

      if(count == 0){
        userRPS = 0;      // rock
        printf("you chose rock!\n");
      }
      if(count == 1){
        userRPS = 2;      // scissors
        printf("you chose scissors!\n");
      }
      if(count == 2){
        userRPS = 2;      // scissors
        printf("you chose scissors!\n");
      }
      if(count == 3){
        userRPS = 1;      // paper
        printf("you chose paper!\n");
      }

      return userRPS;
}



void play_round(struct VL53L0X *TOF1,
             struct VL53L0X *TOF2,
             struct VL53L0X *TOF3,
             struct VL53L0X *TOF4,
             struct VL53L0X *TOF5){

    digitalWrite(CS, PIO_HIGH);
    spiSend(nextrndScreen); // ask to play next round
    digitalWrite(CS, PIO_LOW);

    while(~nextRoundButton); // wait till button pushed
    
    delay_millis(TIM15, 2000);

    digitalWrite(CS, PIO_HIGH);
    spiSend(plcMoveScreen); // ask to place move
    digitalWrite(CS, PIO_LOW);

    delay_millis(TIM15, 2000);

    
    uint8_t userRPS = scan(TOF1, TOF2, TOF3, TOF4, TOF5);  // scan move
    int computerRPSint = rand() % 3; // 0, 1, or 2
    uint8_t computerRPS = (uint8_t) computerRPSint;
    uint8_t formatPlay = formatPlays(userRPS, computerRPS);

    digitalWrite(CS, PIO_HIGH);
    spiSend(formatPlay); // send the computer and user's play to FPGA
    digitalWrite(CS, PIO_LOW);


    digitalWrite(CS, PIO_HIGH);
    spiSend(dsplCompScreen); // display the computer's move
    digitalWrite(CS, PIO_LOW);

    delay_millis(TIM15, 1000);

    digitalWrite(CS, PIO_HIGH);
    spiSend(dsplWinLoseScreen); // display who won or lost
    digitalWrite(CS, PIO_LOW);
}