.syntax unified
.thumb

.global main
.thumb_func
.type main, %function

#include "definitions.s"

.extern initialise_power
.extern enable_peripheral_clocks
.extern enable_uart

.data
tx_string: .asciz "Test Test\r\n"

.text

main:
	BL initialise_power
	BL enable_peripheral_clocks
	BL enable_uart

	B tx_loop

tx_loop:
	LDR R0, =UART
	LDR R3, =tx_string

tx_uart:
wait_txe:
	LDR R1, [R0, #USART_ISR]
	TST R1, 1 << UART_TXE
	BEQ wait_txe

	LDRB R5, [R3], #1
	CMP R5, #0
	BEQ delay_loop

	STRB R5, [R0, #USART_TDR]
	B tx_uart

delay_loop:
	LDR R9, =0x1FFFFF

delay_inner:
	SUBS R9, #1
	BGT delay_inner

	B tx_loop

