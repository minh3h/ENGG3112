// initialise.s
// Peripheral initialisation for Exercise 2: Digital I/O
// Enables clocks for GPIOA (button) and GPIOE (LEDs), and
// configures the relevant pins as input / output.

#ifndef INITIALISE_S
#define INITIALISE_S

.syntax unified
.thumb

#include "definitions.s"


    .global gpio_init
    .thumb_func
gpio_init:
    //Enable clocks for GPIOA and GPIOE
    LDR  R0, =RCC_BASE
    LDR  R1, [R0, #RCC_AHBENR]
    ORR  R1, R1, #RCC_GPIOA_EN
    ORR  R1, R1, #RCC_GPIOE_EN
    STR  R1, [R0, #RCC_AHBENR]

    // Configure PA0 as input (MODER bits 1:0 = 00)
    // Default reset value is 0 for most pins, so just clear bits 1:0.
    LDR  R0, =GPIOA_BASE
    LDR  R1, [R0, #GPIO_MODER]
    BIC  R1, R1, #0x3        		// Clear MODER0[1:0]
    STR  R1, [R0, #GPIO_MODER]

    // Configure PE8–PE15 as general-purpose outputs
    LDR  R0, =GPIOE_BASE
    LDR  R1, [R0, #GPIO_MODER]
    LDR  R2, =LED_MODER_MASK
    BIC  R1, R1, R2                 // Clear existing mode bits for PE8–PE15
    LDR  R2, =LED_MODER_OUT
    ORR  R1, R1, R2                 // Set PE8–PE15 to output mode
    STR  R1, [R0, #GPIO_MODER]

    // All LEDs off at startup
    LDR  R0, =GPIOE_BASE
    LDR  R1, [R0, #GPIO_ODR]
    LDR  R2, =LED_MASK
    BIC  R1, R1, R2                 // Clear PE8–PE15
    STR  R1, [R0, #GPIO_ODR]

    BX   LR

#endif // INITIALISE_S
