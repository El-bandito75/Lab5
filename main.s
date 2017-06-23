;*******************************************************************
; main.s
; Author: ***update this***
; Date Created: 11/18/2016
; Last Modified: 11/18/2016
; Section Number: ***update this***
; Instructor: ***update this***
; Lab number: 5
; Brief description of the program
;   If the switch is presses, the LED toggles at 8 Hz
; Hardware connections
;  PE1 is switch input  (1 means pressed, 0 means not pressed)
;  PE0 is LED output (1 activates external LED on protoboard) 
; Overall functionality is similar to Lab 4, with six changes:
;   1) the pin to which we connect the switch is moved to PE1, 
;   2) you will have to remove the PUR initialization because
;      pull up is no longer needed. 
;   3) the pin to which we connect the LED is moved to PE0, 
;   4) the switch is changed from negative to positive logic, and 
;   5) you should increase the delay so it flashes about 8 Hz.
;   6) the LED should be on when the switch is not pressed
; Operation
;   1) Make PE0 an output and make PE1 an input. 
;   2) The system starts with the LED on (make PE0 =1). 
;   3) Wait about 62 ms
;   4) If the switch is pressed (PE1 is 1), then toggle the LED
;      once, else turn the LED on. 
;   5) Steps 3 and 4 are repeated over and over
;*******************************************************************

GPIO_PORTE_DATA_R       EQU   0x400243FC
GPIO_PORTE_DIR_R        EQU   0x40024400
GPIO_PORTE_AFSEL_R      EQU   0x40024420
GPIO_PORTE_DEN_R        EQU   0x4002451C
GPIO_PORTE_AMSEL_R      EQU   0x40024528
GPIO_PORTE_PCTL_R       EQU   0x4002452C
SYSCTL_RCGCGPIO_R       EQU   0x400FE608
PE1                     EQU   0x40024008
PE0                     EQU   0x40024004
	
       IMPORT  TExaS_Init

       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT  Start
        
Start
 
    BL PortE_Init; //go to PortE_Init
    BL LED_OutputON; // turn led on
    
loop   ;// dead loop
    BL SwitchSat_Input; //get input
    CMP r4, #0x02; // if r4(input) =0x02(on)
    BLNE LED_OutputON;
	BLEQ temp;
    BL    loop;       

temp;
	PUSH{LR}; // saves LR to main loop in stack
	BL LED_OutputON;
	BL Delay
	BL LED_OutputOFF;
	BL Delay;
	POP{LR}; // pops out the LR to the main loop
	BX LR;
		
Delay PROC ; delay function
    ldr r0, =0x30D40;
DelayFun
    SUB r0, r0, #1;
    CMP r0, #0;
    BNE DelayFun;
    BX LR ;
    ENDP
 
 
LED_OutputON ;//set led on
    LDR r3, =PE0;   
    MOV r0, #0x01;
    STR r0, [r3];
    BX LR; 
 
LED_OutputOFF ;//set led off
    LDR r2, =PE0;
    MOV r0, #0x00;
    STR r0, [r2];
    BX LR;
    
 
SwitchSat_Input ;//get input of switch
    LDR r0, =GPIO_PORTE_DATA_R; //PE1 maybe?
    LDR r4, [r0];
    AND r4,r4,#0x02;
    
    BX LR;
 
PortE_Init ;// initialize port E
    LDR r1, =SYSCTL_RCGCGPIO_R; // this sets clock port E
    LDR r0, [r1];
    ORR r0, r0,#0x10;
    STR r0, [r1];
    NOP; // delay for clock to start
    NOP;
    
    ;PE1 inpput, PE0 output 0x03
        
    LDR r1, =GPIO_PORTE_AMSEL_R; // turn off analog
    LDR r0, [r1];
    BIC r0, #0x03;
    STR r0, [r1];    
    
    LDR r1, =GPIO_PORTE_PCTL_R; // set PCTL
    LDR r0, [r1];
    BIC r0, #0x03;
    STR r0, [r1];
    
    LDR r1, =GPIO_PORTE_DIR_R; //set the directions
    LDR r0, [r1];
    BIC r0, #0x02; //set PE1 to input
    ORR r0, #0x01; //set PE0 to output
    STR r0,[r1];
    
    LDR r1, =GPIO_PORTE_AFSEL_R; //turn of alt function
    LDR r0, [r1];
    BIC r0, #0x03;
    STR r0,[r1];
    
    LDR r1, =GPIO_PORTE_DEN_R; //turns on Digital I/O
    LDR r0, [r1];
    ORR r0, #0x03;
    STR r0, [r1];
        
    BX LR; //return
    
 
 
       ALIGN      ; make sure the end of this section is aligned
       END        ; end of file