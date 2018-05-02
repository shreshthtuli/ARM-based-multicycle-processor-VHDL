@@@ Lab 6 Code for binary to decimala
@@@ Switches at memory location 29, LEDs at 30, BCD at 31

Shashank: .word 1657

Main:
;ldr r0, =Shashank
MOV R0, #0
LDR R1, [r0] ; r1 has data of switches
STR R1, [r0, #4] ; saving data to LEDs

MOV R2, #1000

MOV R0,#0 ; initialise counter
	Subtract:
SUBS R1,R1,R2 ; subtract R2 from R1 and set flags
ADD R0,R0,#1 ; add 1 to counter,
CMP R1, R2
BHI Subtract ; branch to start of loop
; quotient in r0, remainder in r1
MOV R9, R0, LSL #12 ; Left 4 bits of R9 has 1000s 

MOV R2, #100

MOV R0,#0 ; initialise counter
	Subtract1:
SUBS R1,R1,R2 ; subtract R2 from R1 and set flags
ADD R0,R0,#1 ; add 1 to counter,
CMP R1, R2
BHI Subtract1 ; branch to start of loop
; quotient in r0, remainder in r1

MOV R3, R0, LSL #8
ORR R9, R9, R3 ; mid-left 4 bits has 100s

MOV R2, #10

MOV R0,#0 ; initialise counter
	Subtract2:
SUBS R1,R1,R2 ; subtract R2 from R1 and set flags
ADD R0,R0,#1 ; add 1 to counter,
CMP R1, R2
BHI Subtract2 ; branch to start of loop
; quotient in r0, remainder in r1

MOV R3, R0, LSL #4
ORR R9, R9, R3 ; mid-right bits has 10s
ORR R9, R9, R1 ; r9[15 downto 0] has full bcd

MOV R0, #0
STR R9, [R0, #8]

b Main


