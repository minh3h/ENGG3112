@ base register for resetting and clock settings
.equ RCC, 0x40021000
.equ AHBENR, 0x14	@ register for enabling clocks
.equ APB1ENR, 0x1C
.equ APB2ENR, 0x18
.equ AFRH, 0x24
.equ AFRL, 0x20
.equ RCC_CR, 0x00 @ control clock register
.equ RCC_CFGR, 0x04 @ configure clock register

@ =========================
@ specific base address for the desired UART to use
@ use USART1 so output can be viewed through ST-LINK virtual COM port
@ STM32F3DISCOVERY routes VCP to USART1 on PC4 / PC5
@ =========================
.equ UART, 0x40013800 @ USART1
.equ UART_EN, 14 @ specific bit to enable this UART
.equ APBENR, APB2ENR

@ GPIOC pins PC4 and PC5 for USART1 VCP
.equ MODER_CLEAR_MASK, (0xF << 8)
.equ MODER_ALT_MASK, (0xA << 8)
.equ AFRREG, AFRL
.equ AFR_CLEAR_MASK, (0xFF << 16)
.equ AFR_SET_MASK, (0x77 << 16)

@ BAUD RATE
@ 8MHz / 115200 ~= 69
.equ BAUD_RATE, 69

@ register addresses and offsets for general UARTs
.equ USART_CR1, 0x00
.equ USART_BRR, 0x0C
.equ USART_ISR, 0x1C @ UART status register offset
.equ USART_ICR, 0x20 @ UART clear flags for errors
.equ USART_RQR, 0x18
.equ USART_RDR, 0x24
.equ USART_TDR, 0x28

.equ UART_TE, 3	@ transmit enable bit
.equ UART_RE, 2	@ receive enable bit
.equ UART_UE, 0	@ enable bit for the whole UART
.equ UART_ORE, 3 @ Overrun flag
.equ UART_FE, 1 @ Frame error

.equ UART_ORECF, 3 @ Overrun clear flag
.equ UART_FECF, 1 @ Frame error clear flag

@ different GPIOs
.equ GPIOA, 0x48000000	@ base register for GPIOA
.equ GPIOB, 0x48000400
.equ GPIOC, 0x48000800
.equ GPIOD, 0x48000C00
.equ GPIOE, 0x48001000

.equ GPIOA_ENABLE, 17	@ enable bit for GPIOA
.equ GPIOB_ENABLE, 18
.equ GPIOC_ENABLE, 19
.equ GPIOD_ENABLE, 20
.equ GPIOE_ENABLE, 21

.equ GPIO_MODER, 0x00	@ set the mode for the GPIO
.equ GPIO_OSPEEDR, 0x08	@ set the speed for the GPIO

@ transmitting and receiving data
.equ UART_TXE, 7	@ transmit register empty
.equ UART_RXNE, 5	@ receive register not empty
.equ UART_RXFRQ, 3	@ receive data flush request

@ setting the clock speed higher using the PLL clock option
.equ HSEBYP, 18	@ bypass the external clock
.equ HSEON, 16 @ set to use the external clock
.equ HSERDY, 17 @ wait for this to indicate HSE is ready
.equ PLLON, 24 @ set the PLL clock source
.equ PLLRDY, 25 @ wait for this to indicate PLL is ready
.equ PLLEN, 16 @ enable the PLL clock
.equ PLLSRC, 16
.equ USBPRE, 22 @ with PLL active, this must be set for the USB

.equ PWREN, 28
.equ SYSCFGEN, 0

