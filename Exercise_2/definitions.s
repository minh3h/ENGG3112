// definitions.s
// Hardware constant definitions for Exercise 2: Digital I/O
// All GPIO addresses, bit masks, and timing constants used across modules.

#ifndef DEFINITIONS_S
#define DEFINITIONS_S

// RCC (Reset & Clock Control)
.equ RCC_BASE,        0x40021000
.equ RCC_AHBENR,      0x14          // AHB peripheral clock enable register offset

.equ RCC_GPIOA_EN,    (1 << 17)     // GPIOA clock enable bit
.equ RCC_GPIOE_EN,    (1 << 21)     // GPIOE clock enable bit

// GPIOA (User Button – PA0)
.equ GPIOA_BASE,      0x48000000
.equ GPIO_MODER,      0x00          // Mode register offset
.equ GPIO_IDR,        0x10          // Input data register offset
.equ GPIO_ODR,        0x14          // Output data register offset
.equ GPIO_BSRR,       0x18          // Bit set/reset register offset

.equ BUTTON_PIN,      0             // PA0 = user button
.equ BUTTON_MASK,     (1 << BUTTON_PIN)

// GPIOE (LEDs – PE8..PE15)
.equ GPIOE_BASE,      0x48001000

// LEDs are on PE8–PE15 (8 LEDs, active high)
.equ LED_PIN_BASE,    8             // First LED pin number
.equ LED_MASK,        0xFF00         // Bits 8–15 in ODR / IDR

// MODER: each pin = 2 bits.  PE8–PE15 occupy bits 16–31 of MODER.
// Set all 8 to output (01): pattern 0x55555555 in upper half.
.equ LED_MODER_MASK,  0xFFFF0000   // Clear bits for PE8–PE15
.equ LED_MODER_OUT,   0x55550000   // Set PE8–PE15 as outputs

// Timing / Debounce
// Software delay loop iteration counts .
// Approximate: 1 ms ≈ 800 iterations of a 10-cycle inner loop.
.equ DELAY_1MS,       800
.equ DEBOUNCE_MS,     50            // 50 ms debounce period

// Counter / State Machine
.equ MAX_COUNT,       255           // 8 LEDs -> max binary value
.equ STATE_UP,        0             // Counting up
.equ STATE_DOWN,      1             // Counting down

// Auto-counter mode
// Set MODE_SELECT to STATE_UP (0) for button-driven, or 1 for timed auto-counter.
// Change this constant to switch between modes at compile time.
.equ MODE_SELECT,     0             // 0 = button mode, 1 = auto-timed mode
.equ AUTO_DELAY_MS,   300           // Delay between auto-steps (ms)

#endif // DEFINITIONS_S
