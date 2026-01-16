################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Columns.
#
# Student 1: Ediz Cagan Uysal, 1011105590
# Student 2: Name, Student Number (if applicable)
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 1
# - Unit height in pixels: 1
# - Display width in pixels: 16
# - Display height in pixels: 16
# - Base Address for Display: 0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
    
COLORS:
    .word 0xff0000  # red
    .word 0x0000ff  # blue
    .word 0x00ff00  # green
    .word 0xffff00  # yellow
    .word 0xffa500  # orange
    .word 0xff00ff  # purple
    .word 0xffffff  # white


##############################################################################
# Mutable Data
##############################################################################

CUR_ROW:
    .word 1
CUR_COL:
    .word 4

GRAVITY_COUNTER:
    .word 0
GRAVITY_DELAY:
    .word 500
    
PAUSED:
    .word 0
    
NEXT1_TOP:
    .word 0
NEXT1_MID:
    .word 0
NEXT1_BOT:
    .word 0

NEXT2_TOP:
    .word 0
NEXT2_MID:
    .word 0
NEXT2_BOT:
    .word 0

NEXT3_TOP:
    .word 0
NEXT3_MID:
    .word 0
NEXT3_BOT:
    .word 0

NEXT4_TOP:
    .word 0
NEXT4_MID:
    .word 0
NEXT4_BOT:
    .word 0

NEXT5_TOP:
    .word 0
NEXT5_MID:
    .word 0
NEXT5_BOT:
    .word 0
    
SAVED_TOP:
    .word 0
SAVED_MID:
    .word 0
SAVED_BOT:
    .word 0
HAS_SAVED:
    .word 0

##############################################################################
# Code
##############################################################################
    .text
    .globl main

    # Run the game.
main:
    # Initialize the game

    lw $t0, ADDR_DSPL # $t0 = base address for display
    jal assign_colors # t1, t2, t3 = gem colors respectively
    jal gen_all_next_columns
    li $t4, 0x777777 # $t4 = grey
    lw $t9, ADDR_KBRD # $t9 = base address for keyboard
    # t5, t6, t7, t8 are free

game_loop:
    la $s4, PAUSED
    lw $s5, 0($s4)
    bne $s5, $zero, skip_gravity

    la $t5, GRAVITY_COUNTER
    lw $t6, 0($t5)
    addi $t6, $t6, 1
    la $t7, GRAVITY_DELAY
    lw $t8, 0($t7)
    slt $s0, $t6, $t8
    beq $s0, $zero, do_auto_drop
    sw $t6, 0($t5)

    # 1a. Check if key has been pressed
    skip_gravity:
        li $s0, 0
        lw $t8, 0($t9)
        beq $t8, $zero, after_move

    # 1b. Check which key has been pressed
    lw $s0, 4($t9)
    
    li $t5, 0x70
    beq $s0, $t5, toggle_pause

    la $s4, PAUSED
    lw $s5, 0($s4)
    bne $s5, $zero, after_move

    li $t5, 0x71
    beq $s0, $t5, quit_game
    
    li $t5, 0x77
    beq $s0, $t5, rotate
    
    li $t5, 0x31
    beq $s0, $t5, set_easy
    li $t5, 0x32
    beq $s0, $t5, set_medium
    li $t5, 0x33
    beq $s0, $t5, set_hard
    
    li $t5, 0x63
    beq $s0, $t5, hold_column


    # 2a. Check for collisions
    la $t5, CUR_ROW
    lw $t6, 0($t5)
    la $t5, CUR_COL
    lw $t7, 0($t5)

    li $t5, 0x61
    beq $s0, $t5, coll_left
    li $t5, 0x64
    beq $s0, $t5, coll_right
    li $t5, 0x73
    beq $s0, $t5, coll_down
    j after_move

    do_auto_drop:
        li $t6, 0
        la $t5, GRAVITY_COUNTER
        sw $t6, 0($t5)
    
        la $t5, CUR_ROW
        lw $t6, 0($t5)
        la $t5, CUR_COL
        lw $t7, 0($t5)
    
        addi $t6, $t6, 3
        sll $t8, $t6, 4
        addu $t8, $t8, $t7
        sll $t8, $t8, 2
        addu $t8, $t8, $t0
        lw $t5, 0($t8)
        bne $t5, $zero, lock_and_new_block
        j move_down
    
        
    coll_left:
        li $t5, 1
        beq $t7, $t5, after_move
        addi $t6, $t6, 2
        addi $t7, $t7, -1
        sll $t8, $t6, 4
        addu $t8, $t8, $t7
        sll $t8, $t8, 2
        addu $t8, $t8, $t0
        lw $t5, 0($t8)
        bne $t5, $zero, after_move
        j move_left
    
    coll_right:
        li $t5, 14
        beq $t7, $t5, after_move
        addi $t6, $t6, 2
        addi $t7, $t7, 1
        sll $t8, $t6, 4
        addu $t8, $t8, $t7
        sll $t8, $t8, 2
        addu $t8, $t8, $t0
        lw $t5, 0($t8)
        bne $t5, $zero, after_move
        j move_right
    
    coll_down:
        addi $t6, $t6, 3
        sll $t8, $t6, 4
        addu $t8, $t8, $t7
        sll $t8, $t8, 2
        addu $t8, $t8, $t0
        lw $t5, 0($t8)
        bne $t5, $zero, lock_and_new_block
        j move_down
    
    toggle_pause:
        la $s4, PAUSED
        lw $s5, 0($s4)
        xori $s5, $s5, 1
        sw $s5, 0($s4)
        j after_move
        
    set_easy:
        la $t6, GRAVITY_DELAY
        li $t7, 1000
        sw $t7, 0($t6)
        j after_move

    set_medium:
        la $t6, GRAVITY_DELAY
        li $t7, 650
        sw $t7, 0($t6)
        j after_move

    set_hard:
        la $t6, GRAVITY_DELAY
        li $t7, 400
        sw $t7, 0($t6)
        j after_move
    
    # 2b. Update locations (capsules)
    hold_column:
        la $t5, HAS_SAVED
        lw $t6, 0($t5)
        beq $t6, $zero, hold_empty
        j hold_swap

    hold_empty:
        la $t5, SAVED_TOP
        sw $t1, 0($t5)
        la $t5, SAVED_MID
        sw $t2, 0($t5)
        la $t5, SAVED_BOT
        sw $t3, 0($t5)

        li $t6, 1
        la $t5, HAS_SAVED
        sw $t6, 0($t5)

        la $t5, NEXT1_TOP
        lw $t1, 0($t5)
        la $t5, NEXT1_MID
        lw $t2, 0($t5)
        la $t5, NEXT1_BOT
        lw $t3, 0($t5)

        jal shift_next_columns
        j after_move

    hold_swap:
        la $t5, SAVED_TOP
        lw $t7, 0($t5)
        sw $t1, 0($t5)
        move $t1, $t7

        la $t5, SAVED_MID
        lw $t7, 0($t5)
        sw $t2, 0($t5)
        move $t2, $t7

        la $t5, SAVED_BOT
        lw $t7, 0($t5)
        sw $t3, 0($t5)
        move $t3, $t7

        j after_move


        
    rotate:
        move $t5, $t1
        move $t6, $t2
        move $t7, $t3
        
        move $t1, $t7
        move $t2, $t5
        move $t3, $t6
        
        j after_move
    
    move_left:
        la $t5, CUR_ROW
        lw $t6, 0($t5)
        la $t5, CUR_COL
        lw $t7, 0($t5)
        
        sll $t6, $t6, 4
        addu $t8, $t6, $t7
        sll $t8, $t8, 2
        addu $t8, $t8, $t0
        sw $zero, 0($t8)
        addi $t8, $t8, 64
        sw $zero, 0($t8)
        addi $t8, $t8, 64
        sw $zero, 0($t8)
    
        la $t5, CUR_COL
        lw $t6, 0($t5)
        addi $t6, $t6, -1
        sw $t6, 0($t5)
        j after_move
    
    move_right:
        la $t5, CUR_ROW
        lw $t6, 0($t5)
        la $t5, CUR_COL
        lw $t7, 0($t5)
    
        sll $t6, $t6, 4
        addu $t8, $t6, $t7
        sll $t8, $t8, 2
        addu $t8, $t8, $t0
        sw $zero, 0($t8)
        addi $t8, $t8, 64
        sw $zero, 0($t8)
        addi $t8, $t8, 64
        sw $zero, 0($t8)
    
        la $t5, CUR_COL
        lw $t6, 0($t5)
        addi $t6, $t6, 1
        sw $t6, 0($t5)
        j after_move
    
    move_down:
        la $t5, CUR_ROW
        lw $t6, 0($t5)
        la $t5, CUR_COL
        lw $t7, 0($t5)
    
        sll $t6, $t6, 4
        addu $t8, $t6, $t7
        sll $t8, $t8, 2
        addu $t8, $t8, $t0
        sw $zero, 0($t8)
        addi $t8, $t8, 64
        sw $zero, 0($t8)
        addi $t8, $t8, 64
        sw $zero, 0($t8)
    
        la $t5, CUR_ROW
        lw $t6, 0($t5)
        addi $t6, $t6, 1
        sw $t6, 0($t5)
        j after_move
    
    lock_and_new_block:
        jal match
        la $t6, GRAVITY_DELAY
        lw $t7, 0($t6)
        li $t8, 150
        ble $t7, $t8, skip_speed_update
        addi $t7, $t7, -30
        sw $t7, 0($t6)

    skip_speed_update:
            la $t5, NEXT1_TOP
            lw $t1, 0($t5)
            la $t5, NEXT1_MID
            lw $t2, 0($t5)
            la $t5, NEXT1_BOT
            lw $t3, 0($t5)
            jal shift_next_columns
        
            la $t5, CUR_ROW
            li $t6, 1
            sw $t6, 0($t5)
        
            la $t5, CUR_COL
            li $t6, 4
            sw $t6, 0($t5)
            
            li $t5, 0x000000
            lw $t6, 208($t0)
            bne $t5, $t6, game_over
        
            j after_move
        
        game_over:
            jal clear_board
            li $t7, 0xffffff
        
            sw $t7, 200($t0)
            sw $t7, 204($t0)
            sw $t7, 208($t0)
            sw $t7, 212($t0)
            sw $t7, 216($t0)
            sw $t7, 264($t0)
            sw $t7, 328($t0)
            sw $t7, 392($t0)
            sw $t7, 456($t0)
            sw $t7, 520($t0)
            sw $t7, 524($t0)
            sw $t7, 528($t0)
            sw $t7, 532($t0)
            sw $t7, 536($t0)
            sw $t7, 472($t0)
            sw $t7, 408($t0)
            sw $t7, 404($t0)
            
            sw $t7, 228($t0)
            sw $t7, 232($t0)
            sw $t7, 236($t0)
            sw $t7, 240($t0)
            sw $t7, 244($t0)
            sw $t7, 292($t0)
            sw $t7, 356($t0)
            sw $t7, 420($t0)
            sw $t7, 484($t0)
            sw $t7, 548($t0)
            sw $t7, 552($t0)
            sw $t7, 556($t0)
            sw $t7, 560($t0)
            sw $t7, 564($t0)
            sw $t7, 500($t0)
            sw $t7, 436($t0)
            sw $t7, 372($t0)
            sw $t7, 308($t0)
            
        
        
        
        wait_game_over_key:
            lw $t8, 0($t9)
            beq $t8, $zero, wait_game_over_key
            lw $s0, 4($t9)
            li $t5, 0x72
            beq $s0, $t5, restart_game
            li $t5, 0x71
            beq $s0, $t5, quit_game
            j wait_game_over_key
    
         clear_board:
            addi $t5, $t0, 0
            addi $t6, $t0, 1024
            clear_loop:
                sw $zero, 0($t5)
                addi $t5, $t5, 4
                blt $t5, $t6, clear_loop
                jr $ra
    
        restart_game:
            jal clear_board
    
            la $t5, CUR_ROW
            li $t6, 1
            sw $t6, 0($t5)
    
            la $t5, CUR_COL
            li $t6, 4
            sw $t6, 0($t5)
    
            la $t5, GRAVITY_COUNTER
            sw $zero, 0($t5)
    
            la $t5, PAUSED
            sw $zero, 0($t5)
    
            la $t5, GRAVITY_DELAY
            li $t6, 500
            sw $t6, 0($t5)
    
            jal assign_colors
            jal gen_all_next_columns
            j game_loop
    
        quit_game:
            li $v0, 10
            syscall
        
        after_move:
        
        # 3. Draw the screen
        draw_screen:
        
            addi $t5, $t0, 0
            addi $t6, $t0, 36
            
            #add grey borders
            top_row:
                sw $t4, 0($t5)
            addi $t5, $t5, 4
            slt $t7, $t5, $t6
            bne $t7, $zero, top_row
        
            addi $t5, $t0, 0
            addi $t6, $t0, 1024
                
        left_col:
            sw $t4, 0($t5)
            addi $t5, $t5, 64
            slt $t7, $t5, $t6
            bne $t7, $zero, left_col
                
            addi $t5, $t0, 32
            addi $t6, $t5, 1024
                
        right_col:
            sw $t4, 0($t5)
            addi $t5, $t5, 64
            slt $t7, $t5, $t6
            bne $t7, $zero, right_col
                
            addi $t5, $t0, 960
            addi $t6, $t5, 36
                
        bottom_row:
            sw $t4, 0($t5)
            addi $t5, $t5, 4
            slt $t7, $t5, $t6
            bne $t7, $zero, bottom_row
            
        
        #add columns
        la $t5, CUR_ROW
        lw $t6, 0($t5)
        la $t5, CUR_COL
        lw $t7, 0($t5)
        
        sll $t6, $t6, 4
        addu $t8, $t6, $t7
        sll $t8, $t8, 2
        addu $t8, $t8, $t0
        
        sw $t1, 0($t8)
        sw $t2, 64($t8)
        sw $t3, 128($t8)

        la $t5, NEXT5_TOP
        lw $t6, 0($t5)
        sw $t6, 104($t0)
        la $t5, NEXT5_MID
        lw $t6, 0($t5)
        sw $t6, 168($t0)
        la $t5, NEXT5_BOT
        lw $t6, 0($t5)
        sw $t6, 232($t0)

        la $t5, NEXT4_TOP
        lw $t6, 0($t5)
        sw $t6, 108($t0)
        la $t5, NEXT4_MID
        lw $t6, 0($t5)
        sw $t6, 172($t0)
        la $t5, NEXT4_BOT
        lw $t6, 0($t5)
        sw $t6, 236($t0)

        la $t5, NEXT3_TOP
        lw $t6, 0($t5)
        sw $t6, 112($t0)
        la $t5, NEXT3_MID
        lw $t6, 0($t5)
        sw $t6, 176($t0)
        la $t5, NEXT3_BOT
        lw $t6, 0($t5)
        sw $t6, 240($t0)

        la $t5, NEXT2_TOP
        lw $t6, 0($t5)
        sw $t6, 116($t0)
        la $t5, NEXT2_MID
        lw $t6, 0($t5)
        sw $t6, 180($t0)
        la $t5, NEXT2_BOT
        lw $t6, 0($t5)
        sw $t6, 244($t0)

        la $t5, NEXT1_TOP
        lw $t6, 0($t5)
        sw $t6, 120($t0)
        la $t5, NEXT1_MID
        lw $t6, 0($t5)
        sw $t6, 184($t0)
        la $t5, NEXT1_BOT
        lw $t6, 0($t5)
        sw $t6, 248($t0)
        
        
        la $t5, HAS_SAVED
        lw $t6, 0($t5)
        beq $t6, $zero, clear_hold_slot

        la $t5, SAVED_TOP
        lw $t6, 0($t5)
        sw $t6, 744($t0)
        la $t5, SAVED_MID
        lw $t6, 0($t5)
        sw $t6, 808($t0)
        la $t5, SAVED_BOT
        lw $t6, 0($t5)
        sw $t6, 872($t0)
        j after_hold_draw

    clear_hold_slot:
        sw $zero, 744($t0)
        sw $zero, 808($t0)
        sw $zero, 872($t0)

    after_hold_draw:
        li $t7, 0
        addi $t8, $t0, 432
        sw  $t7, 0($t8)
        addi $t8, $t0, 436
        sw  $t7, 0($t8)
        addi $t8, $t0, 440
        sw  $t7, 0($t8)
    
        addi $t8, $t0, 496
        sw  $t7, 0($t8)
        addi $t8, $t0, 504
        sw  $t7, 0($t8)
    
        addi $t8, $t0, 560
        sw  $t7, 0($t8)
        addi $t8, $t0, 564
        sw  $t7, 0($t8)
        addi $t8, $t0, 568
        sw  $t7, 0($t8)
    
        addi $t8, $t0, 624
        sw  $t7, 0($t8)
    
        addi $t8, $t0, 688
        sw  $t7, 0($t8)
    
        la  $t5, PAUSED
        lw  $t6, 0($t5)
        beq $t6, $zero, skip_pause_text
    
        li  $t7, 0xffffff
    
        addi $t8, $t0, 432
        sw  $t7, 0($t8)
        addi $t8, $t0, 436
        sw  $t7, 0($t8)
        addi $t8, $t0, 440
        sw  $t7, 0($t8)
    
        addi $t8, $t0, 496
        sw  $t7, 0($t8)
        addi $t8, $t0, 504
        sw  $t7, 0($t8)
    
        addi $t8, $t0, 560
        sw  $t7, 0($t8)
        addi $t8, $t0, 564
        sw  $t7, 0($t8)
        addi $t8, $t0, 568
        sw  $t7, 0($t8)
    
        addi $t8, $t0, 624
        sw  $t7, 0($t8)
    
        addi $t8, $t0, 688
        sw  $t7, 0($t8)
    
    # 4. Sleep
    skip_pause_text:
        li $v0, 32
        li $a0, 1
        syscall

    # 5. Go back to Step 1
    j game_loop

    helpers:
        assign_colors:
            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t1, 0($t5)
                
            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t2, 0($t5)
                
            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t3, 0($t5)
                
            jr $ra
        
        gen_all_next_columns:
            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t7, 0($t5)
            la $t5, NEXT1_TOP
            sw $t7, 0($t5)

            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t7, 0($t5)
            la $t5, NEXT1_MID
            sw $t7, 0($t5)

            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t7, 0($t5)
            la $t5, NEXT1_BOT
            sw $t7, 0($t5)

            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t7, 0($t5)
            la $t5, NEXT2_TOP
            sw $t7, 0($t5)

            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t7, 0($t5)
            la $t5, NEXT2_MID
            sw $t7, 0($t5)

            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t7, 0($t5)
            la $t5, NEXT2_BOT
            sw $t7, 0($t5)

            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t7, 0($t5)
            la $t5, NEXT3_TOP
            sw $t7, 0($t5)

            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t7, 0($t5)
            la $t5, NEXT3_MID
            sw $t7, 0($t5)

            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t7, 0($t5)
            la $t5, NEXT3_BOT
            sw $t7, 0($t5)

            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t7, 0($t5)
            la $t5, NEXT4_TOP
            sw $t7, 0($t5)

            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t7, 0($t5)
            la $t5, NEXT4_MID
            sw $t7, 0($t5)

            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t7, 0($t5)
            la $t5, NEXT4_BOT
            sw $t7, 0($t5)

            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t7, 0($t5)
            la $t5, NEXT5_TOP
            sw $t7, 0($t5)

            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t7, 0($t5)
            la $t5, NEXT5_MID
            sw $t7, 0($t5)

            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t7, 0($t5)
            la $t5, NEXT5_BOT
            sw $t7, 0($t5)

            jr $ra
        
                shift_next_columns:
            la $t5, NEXT2_TOP
            lw $t7, 0($t5)
            la $t6, NEXT1_TOP
            sw $t7, 0($t6)

            la $t5, NEXT2_MID
            lw $t7, 0($t5)
            la $t6, NEXT1_MID
            sw $t7, 0($t6)

            la $t5, NEXT2_BOT
            lw $t7, 0($t5)
            la $t6, NEXT1_BOT
            sw $t7, 0($t6)

            la $t5, NEXT3_TOP
            lw $t7, 0($t5)
            la $t6, NEXT2_TOP
            sw $t7, 0($t6)

            la $t5, NEXT3_MID
            lw $t7, 0($t5)
            la $t6, NEXT2_MID
            sw $t7, 0($t6)

            la $t5, NEXT3_BOT
            lw $t7, 0($t5)
            la $t6, NEXT2_BOT
            sw $t7, 0($t6)

            la $t5, NEXT4_TOP
            lw $t7, 0($t5)
            la $t6, NEXT3_TOP
            sw $t7, 0($t6)

            la $t5, NEXT4_MID
            lw $t7, 0($t5)
            la $t6, NEXT3_MID
            sw $t7, 0($t6)

            la $t5, NEXT4_BOT
            lw $t7, 0($t5)
            la $t6, NEXT3_BOT
            sw $t7, 0($t6)

            la $t5, NEXT5_TOP
            lw $t7, 0($t5)
            la $t6, NEXT4_TOP
            sw $t7, 0($t6)

            la $t5, NEXT5_MID
            lw $t7, 0($t5)
            la $t6, NEXT4_MID
            sw $t7, 0($t6)

            la $t5, NEXT5_BOT
            lw $t7, 0($t5)
            la $t6, NEXT4_BOT
            sw $t7, 0($t6)

            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t7, 0($t5)
            la $t6, NEXT5_TOP
            sw $t7, 0($t6)

            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t7, 0($t5)
            la $t6, NEXT5_MID
            sw $t7, 0($t6)

            li $v0, 42
            li $a0, 0
            li $a1, 7
            syscall
            la $t5, COLORS
            sll $t6, $a0, 2
            addu $t5, $t5, $t6
            lw $t7, 0($t5)
            la $t6, NEXT5_BOT
            sw $t7, 0($t6)

            jr $ra
     
        match:
            li $v0, 0
            check_match:
                li $t5, 68
                addu $t5, $t5, $t0
                li $t6, 916
                addu $t6, $t6, $t0
                li $s3, 0x000000
                
                #check for all horizontal matches
                horizontal_loop:
                    lw $t7, 0($t5)
                    beq $t7, $s3, not_equal1
                    lw $t8, 4($t5)
                    lw $s2, 8($t5)
                    bne $t7, $t8, not_equal1
                    bne $t8, $s2, not_equal1
                    j equal1
                    
                    #match found                   
                    equal1:
                        addi $v0, $v0, 1
                        sw $s3, 0($t5)
                        sw $s3, 4($t5)
                        sw $s3, 8($t5)
                        
                        move $s1, $t5
                        addi $s1, $s1, 12
                        equal_loop1:
                            lw $s5, 0($s1)
                            bne $t8, $s5, not_equal1
                            sw $s3, 0($s1)
                            addi $s1, $s1, 4
                            j equal_loop1
                    
                    not_equal1:
                    
                    #modify t5
                    subu $t7, $t5, $t0 
                    li $t8, 64
                    div $t7, $t8
                    mfhi $t7
                    
                    li $t8, 4
                    div $t7, $t8
                    mflo $t7
                    
                    li $t8, 5
                    beq $t7, 5, next_row1
                    j next_col1
                    
                    next_row1:
                        addi $t5, $t5, 44
                        
                    next_col1:
                        addi $t5, $t5, 4
                    
                    ble $t5, $t6, horizontal_loop
                    
                        
                li $t5, 68
                addu $t5, $t5, $t0
                li $t6, 796
                addu $t6, $t6, $t0
                
                #check for all vertical matches
                vertical_loop:
                    lw $t7, 0($t5)
                    beq $t7, $s3, not_equal2
                    lw $t8, 64($t5)
                    lw $s2, 128($t5)
                    bne $t7, $t8, not_equal2
                    bne $t8, $s2, not_equal2
                    j equal2
                    
                    #match found
                    equal2:
                        addi $v0, $v0, 1
                        sw $s3, 0($t5)
                        sw $s3, 64($t5)
                        sw $s3, 128($t5)
                        
                        move $s1, $t5
                        addi $s1, $s1, 192
                        equal_loop2:
                            lw $s5, 0($s1)
                            bne $t8, $s5, not_equal2
                            sw $s3, 0($s1)
                            addi $s1, $s1, 64
                            j equal_loop2
                    
                    not_equal2:
                    
                    #modify t5
                    subu $t7, $t5, $t0 
                    
                    li $t8, 64
                    div $t7, $t8
                    mfhi $t7
                    
                    li $t8, 4
                    div $t7, $t8
                    mflo $t7
                    
                    li $t8, 7
                    beq $t7, 7, next_row2
                    j next_col2
                    
                    next_row2:
                        addi $t5, $t5, 36
                        
                    next_col2:
                        addi $t5, $t5, 4
                    
                    ble $t5, $t6, vertical_loop
                
                li $t5, 68
                addu $t5, $t5, $t0
                li $t6, 796
                addu $t6, $t6, $t0

                #check for all down-right diagonal matches
                diagonal1_loop:
                    lw $t7, 0($t5)
                    beq $t7, $s3, not_equal3
                    lw $t8, 68($t5)
                    lw $s2, 136($t5)
                    bne $t7, $t8, not_equal3
                    bne $t8, $s2, not_equal3
                    j equal3

                    #match found
                    equal3:
                        addi $v0, $v0, 1
                        sw $s3, 0($t5)
                        sw $s3, 68($t5)
                        sw $s3, 136($t5)

                        move $s1, $t5
                        addi $s1, $s1, 204
                    equal_loop3:
                        lw $s5, 0($s1)
                        bne $t8, $s5, not_equal3
                        sw $s3, 0($s1)
                        addi $s1, $s1, 68
                        j equal_loop3

                    not_equal3:

                    #modify t5
                    subu $t7, $t5, $t0

                    li $t8, 64
                    div $t7, $t8
                    mfhi $t7

                    li $t8, 4
                    div $t7, $t8
                    mflo $t7

                    li $t8, 7
                    beq $t7, 7, next_row3
                    j next_col3

                    next_row3:
                        addi $t5, $t5, 36

                    next_col3:
                        addi $t5, $t5, 4

                    ble $t5, $t6, diagonal1_loop


                li $t5, 68
                addu $t5, $t5, $t0
                li $t6, 796
                addu $t6, $t6, $t0

                #check for all down-left diagonal matches
                diagonal2_loop:
                    lw $t7, 0($t5)
                    beq $t7, $s3, not_equal4
                    lw $t8, 60($t5)
                    lw $s2, 120($t5)
                    bne $t7, $t8, not_equal4
                    bne $t8, $s2, not_equal4
                    j equal4

                    #match found
                    equal4:
                        addi $v0, $v0, 1
                        sw $s3, 0($t5)
                        sw $s3, 60($t5)
                        sw $s3, 120($t5)

                        move $s1, $t5
                        addi $s1, $s1, 180
                    equal_loop4:
                        lw $s5, 0($s1)
                        bne $t8, $s5, not_equal4
                        sw $s3, 0($s1)
                        addi $s1, $s1, 60
                        j equal_loop4

                    not_equal4:

                    #modify t5
                    subu $t7, $t5, $t0

                    li $t8, 64
                    div $t7, $t8
                    mfhi $t7

                    li $t8, 4
                    div $t7, $t8
                    mflo $t7

                    li $t8, 7
                    beq $t7, 7, next_row4
                    j next_col4

                    next_row4:
                        addi $t5, $t5, 36

                    next_col4:
                        addi $t5, $t5, 4

                    ble $t5, $t6, diagonal2_loop
            
            gravity:
                li $t5, 860
                addu $t5, $t5, $t0
                li $t6, 64
                addu $t6, $t6, $t0
                
                gravity_loop:
                    lw $t7, 0($t5)
                    beq $t7, $s3, no_gravity

                    lw $t8, 64($t5)
                    bne $t8, $s3, no_gravity
                    
                    move $s5, $t5
                    
                    apply_gravity:
                        sw $s3, 0($s5)
                        sw $t7, 64($s5)
                        addi $s5, $s5, 64
                    
                        lw $t7, 0($s5)
                        lw $t8, 64($s5)
                        bne $t8, $s3, no_gravity
                        j apply_gravity
                        
                    
                    no_gravity:
                    
                    #modify t5
                    subu $t7, $t5, $t0

                    li $t8, 64
                    div $t7, $t8
                    mfhi $t7

                    li $t8, 4
                    div $t7, $t8
                    mflo $t7

                    li $t8, 1
                    beq $t7, 1, next_row5
                    j next_col5

                    next_row5:
                        subi $t5, $t5, 36

                    next_col5:
                        subi $t5, $t5, 4
                    
                    
                    bge $t5, $t6, gravity_loop
                    
            bne $v0, 0, match
            jr $ra            
        