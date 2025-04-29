/*** asmEncrypt.s   ***/

#include <xc.h>

/* Declare the following to be in data memory */
.data  

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Javier Ayala"  
.align
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

/* Define the globals so that the C code can access them */
/* (in this lab we return the pointer, so strictly speaking, */
/* does not really need to be defined as global) */
/* .global cipherText */
.type cipherText,%gnu_unique_object

.align
 
@ NOTE: THIS .equ MUST MATCH THE #DEFINE IN main.c !!!!!
@ TODO: create a .h file that handles both C and assembly syntax for this definition
.equ CIPHER_TEXT_LEN, 200
 
/* space allocated for cipherText: 200 bytes, prefilled with 0x2A */
cipherText: .space CIPHER_TEXT_LEN,0x2A  

.align
 
.global cipherTextPtr
.type cipherTextPtr,%gnu_unique_object
cipherTextPtr: .word cipherText

/* Tell the assembler that what follows is in instruction memory     */
.text
.align

/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

    
/********************************************************************
function name: asmEncrypt
function description:
     pointerToCipherText = asmEncrypt ( ptrToInputText , key )
     
where:
     input:
     ptrToInputText: location of first character in null-terminated
                     input string. Per calling convention, passed in via r0.
     key:            shift value (K). Range 0-25. Passed in via r1.
     
     output:
     pointerToCipherText: mem location (address) of first character of
                          encrypted text. Returned in r0
     
     function description: asmEncrypt reads each character of an input
                           string, uses a shifted alphabet to encrypt it,
                           and stores the new character value in memory
                           location beginning at "cipherText". After copying
                           a character to cipherText, a pointer is incremented 
                           so that the next letter is stored in the bext byte.
                           Only encrypt characters in the range [a-zA-Z].
                           Any other characters should just be copied as-is
                           without modifications
                           Stop processing the input string when a NULL (0)
                           byte is reached. Make sure to add the NULL at the
                           end of the cipherText string.
     
     notes:
        The return value will always be the mem location defined by
        the label "cipherText".
     
     
********************************************************************/    
.global asmEncrypt
.type asmEncrypt,%function
asmEncrypt:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
    
    /* YOUR asmEncrypt CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
     // Load the address of cipherText (destination buffer) into r2
    ldr r2, =cipherText
    // Copy the input string address (plaintext) from r0 into r3 so we don't modify r0
    mov r3, r0

encrypt_loop:
    // Load the next character (byte) from the plaintext string and post-increment r3
    ldrb r4, [r3], #1
    // Check if the current character is the null terminator (end of string)
    cmp r4, #0
    // If it's the end, branch to encrypt_done to terminate the cipherText
    beq encrypt_done

    // Check if the character is before 'A' (non-uppercase letter)
    cmp r4, #'A'
    blt copy_char
    // If it's between 'A' and 'Z', handle uppercase shifting
    cmp r4, #'Z'
    ble shift_uppercase

    // Check if the character is before 'a' (non-lowercase letter)
    cmp r4, #'a'
    blt copy_char
    // If it's between 'a' and 'z', handle lowercase shifting
    cmp r4, #'z'
    ble shift_lowercase

copy_char:
    // For non-letter characters (symbols, numbers, etc.), copy them unchanged
    strb r4, [r2], #1
    // Go back to process the next character
    b encrypt_loop

shift_uppercase:
    // Shift the uppercase letter into a 0-25 range relative to 'A'
    sub r5, r4, #'A'      
    // Apply the cipher shift (key stored in r1)
    add r5, r5, r1        
    // Update condition flags to check for possible underflow
    movs r5, r5
    // If underflow occurred (r5 negative), wrap it by adding 26
    bge no_underflow_upper
    add r5, r5, #26
no_underflow_upper:
    // If after adding key, r5 is 26 or more, wrap back within [0, 25] range
    cmp r5, #26
    blt no_wrap_upper
    sub r5, r5, #26
no_wrap_upper:
    // Convert back from 0-25 range to actual ASCII uppercase letter
    add r5, r5, #'A'
    // Store the encrypted character and increment output pointer
    strb r5, [r2], #1
    // Continue with next character
    b encrypt_loop

shift_lowercase:
    //Shift the lowercase letter into a 0-25 range relative to 'a'
    sub r5, r4, #'a'
    // Apply the cipher shift
    add r5, r5, r1
    // if after shifting it stays within [0, 25], no wrap needed
    cmp r5, #26
    blt no_wrap_lower
    // If it exceeds, subtract 26 to wrap around alphabetically
    sub r5, r5, #26    

no_wrap_lower:
    // Convert back from 0-25 range to actual ASCII lowercase letter
    add r5, r5, #'a'
    // Store the encrypted lowercase letter
    strb r5, [r2], #1
    // Continue with next character
    b encrypt_loop

encrypt_done:
    // Store null terminator at the end of cipherText string
    movs r4, #0
    strb r4, [r2]

    // Return cipherText address in r0 for caller convenience
    ldr r0, =cipherText
    
    /* YOUR asmEncrypt CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

    /* restore the caller's registers, as required by the ARM calling convention */
    pop {r4-r11,LR}

    mov pc, lr	 /* asmEncrypt return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




