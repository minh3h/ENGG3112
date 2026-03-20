.syntax unified
.thumb

#include "definitions.s"

.global enable_peripheral_clocks
.global enable_uart
.global change_clock_speed
.global initialise_power

@ function to enable the clocks for the peripherals we could be using
.thumb_func
enable_peripheral_clocks:

	@ load the address of the RCC address boundary
	LDR R0, =RCC

	@ enable all of the GPIO peripherals in AHBENR
	LDR R1, [R0, #AHBENR]
	ORR R1, 1 << GPIOE_ENABLE | 1 << GPIOD_ENABLE | 1 << GPIOC_ENABLE | 1 << GPIOB_ENABLE | 1 << GPIOA_ENABLE
	STR R1, [R0, #AHBENR]

	BX LR @ return

@ function to enable a UART device
@ uses USART1 on PC4 (TX) and PC5 (RX) for ST-LINK VCP
.thumb_func
enable_uart:

	@ select GPIOC because VCP uses PC4 and PC5 on this board
	LDR R0, =GPIOC

	@ set the alternate function for the UART pins
	LDR R1, [R0, #AFRREG]
	BIC R1, R1, AFR_CLEAR_MASK
	ORR R1, R1, AFR_SET_MASK
	STR R1, [R0, #AFRREG]

	@ modify the mode of the GPIO pins to alternate function mode
	LDR R1, [R0, #GPIO_MODER]
	BIC R1, R1, MODER_CLEAR_MASK
	ORR R1, MODER_ALT_MASK
	STR R1, [R0, #GPIO_MODER]

	@ modify the speed of the GPIO pins
	LDR R1, [R0, #GPIO_OSPEEDR]
	ORR R1, (0xF << 8)
	STR R1, [R0, #GPIO_OSPEEDR]

	@ enable USART1 clock
	LDR R0, =RCC
	LDR R1, [R0, #APBENR]
	ORR R1, 1 << UART_EN
	STR R1, [R0, #APBENR]

	@ set baud rate
	LDR R0, =UART
	MOV R1, BAUD_RATE
	STRH R1, [R0, #USART_BRR]

	@ enable transmit, receive and UART
	LDR R1, [R0, #USART_CR1]
	ORR R1, 1 << UART_TE | 1 << UART_RE | 1 << UART_UE
	STR R1, [R0, #USART_CR1]

	BX LR @ return

@ set the PLL (optional for this simple UART demo)
.thumb_func
change_clock_speed:

	@ step 1, set clock to HSE
	LDR R0, =RCC
	LDR R1, [R0, #RCC_CR]
	LDR R2, =1 << HSEBYP | 1 << HSEON
	ORR R1, R2
	STR R1, [R0, #RCC_CR]

wait_for_HSERDY:
	LDR R1, [R0, #RCC_CR]
	TST R1, 1 << HSERDY
	BEQ wait_for_HSERDY

	@ step 2, configure PLL
	LDR R1, [R0, #RCC_CFGR]
	LDR R2, =1 << 20 | 1 << PLLSRC | 1 << 22
	ORR R1, R2
	STR R1, [R0, #RCC_CFGR]

	@ enable PLL
	LDR R1, [R0, #RCC_CR]
	ORR R1, 1 << PLLON
	STR R1, [R0, #RCC_CR]

wait_for_PLLRDY:
	LDR R1, [R0, #RCC_CR]
	TST R1, 1 << PLLRDY
	BEQ wait_for_PLLRDY

	@ step 3, switch over the system clock to PLL
	LDR R1, [R0, #RCC_CFGR]
	MOV R2, 1 << 10 | 1 << 1
	ORR R1, R2
	STR R1, [R0, #RCC_CFGR]

	LDR R1, [R0, #RCC_CFGR]
	ORR R1, 1 << USBPRE
	STR R1, [R0, #RCC_CFGR]

	BX LR @ return

@ initialise the power systems on the microcontroller
.thumb_func
initialise_power:

	LDR R0, =RCC

	@ enable clock power in APB1ENR
	LDR R1, [R0, #APB1ENR]
	ORR R1, 1 << PWREN
	STR R1, [R0, #APB1ENR]

	@ enable clock config in APB2ENR
	LDR R1, [R0, #APB2ENR]
	ORR R1, 1 << SYSCFGEN
	STR R1, [R0, #APB2ENR]

	BX LR @ return

