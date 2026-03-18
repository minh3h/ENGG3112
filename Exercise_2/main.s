// main.s
// Exercise 2: Digital I/O – STM32F3 Discovery
//
// five sub-tasks:
// a) set_leds – write an 8-bit bitmask to PE8–PE15
// b) button loop – increment counter on press, display as binary on LEDs
// c) up/down SM – reverse direction at 0xFF (all on) and 0x00 (all off)
// d) debounce – 50 ms software debounce on button read
// e) auto-mode – timed counter steps; MODE_SELECT constant selects mode
//
// Register conventions (within functions):
//   R4 = current counter value  (0–255)
//   R5 = current direction      (STATE_UP / STATE_DOWN)
//   R6 = scratch / loop counter
//   R7 = scratch

.syntax unified
.thumb

#include "definitions.s"

    .extern gpio_init

//  .data  –  variables
    .section .data
counter:    .byte  0 // Current LED counter value (0–255)
direction:  .byte  0 // STATE_UP(0) or STATE_DOWN(1)

    .section .text

// set_leds
//   Write an 8-bit pattern to PE8–PE15.
//   Input : R0 = 8-bit LED bitmask (bit 0 → PE8, bit 7 → PE15)
//   Output: none

    .global set_leds
    .thumb_func
set_leds:
    LDR  R1, =GPIOE_BASE
    LDR  R2, [R1, #GPIO_ODR]
    LDR  R3, =LED_MASK
    BIC  R2, R2, R3 // Clear current LED bits (PE8–PE15)
    LSL  R0, R0, #LED_PIN_BASE // Shift pattern into PE8–PE15 position
    ORR  R2, R2, R0 // Merge with rest of ODR
    STR  R2, [R1, #GPIO_ODR]
    BX   LR

// delay_ms
//   Blocking software delay for bouncing.
//   Input : R0 = number of milliseconds to wait
    .global delay_ms
    .thumb_func
delay_ms:
    // Outer loop: R0 iterations (one per ms)
delay_ms_outer:
    CBZ  R0, delay_ms_done
    LDR  R1, =DELAY_1MS
delay_ms_inner:
    SUBS R1, R1, #1
    BNE  delay_ms_inner
    SUBS R0, R0, #1
    B    delay_ms_outer
delay_ms_done:
    BX   LR

// read_button
//   Returns the current (debounced) state of PA0.
//   Waits 50 ms after a detected press before returning to filter bounce.
//   Output: R0 = 1 if button is pressed (high), 0 otherwise
    .global read_button
    .thumb_func
read_button:
    LDR  R1, =GPIOA_BASE
    LDR  R2, [R1, #GPIO_IDR]
    AND  R0, R2, #BUTTON_MASK   // Isolate PA0
    CBZ  R0, read_button_done   // Not pressed → return 0 immediately

    // Button pressed: debounce delay then re-sample
    PUSH {LR}
    MOV  R0, #DEBOUNCE_MS
    BL   delay_ms

    // Re-read after debounce window
    LDR  R1, =GPIOA_BASE
    LDR  R2, [R1, #GPIO_IDR]
    AND  R0, R2, #BUTTON_MASK
    // R0 = 1 if still pressed (genuine press), 0 if it was noise
    POP  {PC}

read_button_done:
    BX   LR

// wait_for_release
//   Polls until the button is no longer pressed (PA0 = 0).
//   Prevents the counter advancing multiple times for one long press.
    .global wait_for_release
    .thumb_func
wait_for_release:
    PUSH {LR}
wait_release_loop:
    LDR  R1, =GPIOA_BASE
    LDR  R2, [R1, #GPIO_IDR]
    AND  R0, R2, #BUTTON_MASK
    CMP  R0, #0
    BNE  wait_release_loop      // Still pressed – keep waiting
    // Small delay to debounce the release edge too
    MOV  R0, #DEBOUNCE_MS
    BL   delay_ms
    POP  {PC}

// update_counter
//   Advances or retreats the counter by 1 according to current direction,
//   flips direction at the boundaries (0 and 255), then updates the LEDs.
//
//   Input : R4 = current counter value
//           R5 = current direction (STATE_UP / STATE_DOWN)
//   Output: R4, R5 updated in place; LEDs set to new counter value
    .global update_counter
    .thumb_func
update_counter:
    PUSH {LR}
    CMP  R5, #STATE_DOWN
    BEQ  update_do_down

update_do_up:
    ADDS R4, R4, #1
    CMP  R4, #MAX_COUNT
    BLT  update_show // Still below max – no state change
    MOV  R4, #MAX_COUNT // Clamp to 255
    MOV  R5, #STATE_DOWN // Flip direction
    B    update_show

update_do_down:
    SUBS R4, R4, #1
    CMP  R4, #0
    BGT  update_show // Still above 0 – no state change
    MOV  R4, #0 // Clamp to 0
    MOV  R5, #STATE_UP // Flip direction

update_show:
    MOV  R0, R4
    BL   set_leds // Display current count on LEDs
    POP  {PC}

// main
//   Entry point.  Initialises GPIO, loads MODE_SELECT and runs either
//   the button-driven loop or the timed auto-counter loop.
    .global main
    .thumb_func
main:
    BL   gpio_init

    LDR  R6, =counter
    LDRB R4, [R6]               // R4 = counter value
    LDR  R7, =direction
    LDRB R5, [R7]               // R5 = direction

    // Show initial state (all LEDs off)
    MOV  R0, R4
    BL   set_leds

    // Choose operating mode (resolved at assemble time)
.if MODE_SELECT == 1
    B    auto_mode
.else
    B    button_mode_loop
.endif

//  BUTTON MODE  (MODE_SELECT = 0)
//  Poll the button; on each confirmed press advance the counter.
button_mode_loop:
    BL   read_button // R0 = 1 if pressed
    CMP  R0, #0
    BEQ.W button_mode_loop // Not pressed – keep polling (wide branch)

    // Confirmed press: advance counter, update LEDs
    BL   update_counter

    // Persist updated state to RAM
    STRB R4, [R6]
    STRB R5, [R7]

    // Wait until button is released before accepting the next press
    BL   wait_for_release

    B.W  button_mode_loop

//  AUTO TIMED MODE  (MODE_SELECT = 1)
//  Step through the counter automatically at AUTO_DELAY_MS intervals.
//  Useful for demonstrations without pressing the button 512 times.
auto_mode:
    BL   update_counter

    // Persist state
    STRB R4, [R6]
    STRB R5, [R7]

    MOV  R0, #AUTO_DELAY_MS
    BL   delay_ms

    B    auto_mode

    .end
