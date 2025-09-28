INCLUDE Irvine32.inc

.data
inputs BYTE 0,0,0,0, 0,0,0,1, 0,0,1,0, 0,0,1,1
       BYTE 0,1,0,0, 0,1,0,1, 0,1,1,0, 0,1,1,1
       BYTE 1,0,0,0, 1,0,0,1, 1,0,1,0, 1,0,1,1
       BYTE 1,1,0,0, 1,1,0,1, 1,1,1,0, 1,1,1,1

outputs BYTE 0,0,0,1, 0,0,1,1, 0,0,0,1, 1,1,1,1

weights REAL8 0.1, 0.4, 0.5, 0.1
half REAL8 0.5
y           REAL8 0.0
temp        REAL8 0.0
error       REAL8 0.0
total_loss  REAL8 0.0

learning_rate REAL8 0.001
i   DD 0
epochs DD 100000

testWeights REAL8 0.152132, 0.400886, 0.401641, 0.15231

space BYTE ' '

.code
main PROC
    


    finit

    mov ecx, epochs            ; outer epochs
epochs_loop:
    mov epochs, ecx
    fldz
    fstp total_loss

    mov edx, 0                 ; pointer into inputs (byte index)
    mov ecx, 16                ; 16 training vectors
for_loop:
    ; ---- reset y = 0 for this sample ----
    finit
    
    fldz
    fstp y

    ; --- inputs[edx] * weights[0] and accumulate into y ---
    movzx eax, inputs[edx]
    push eax
    fild DWORD PTR [esp]
    add esp, 4

    fld weights[0]     ; st0 = weight, st1 = input
    fmulp              ; st0 = input * weight (pops)
    fld y              ; st0 = y, st1 = product
    faddp              ; st0 = product + y (pops)
    fstp y             ; y = new sum, pop

    inc edx

    ; --- inputs[edx] * weights[1] ---
    movzx eax, inputs[edx]
    push eax
    fild DWORD PTR [esp]
    add esp, 4

    fld weights[8]
    fmulp
    fld y
    faddp
    fstp y

    

    inc edx

    ; --- inputs[edx] * weights[2] ---
    movzx eax, inputs[edx]
    push eax
    fild DWORD PTR [esp]
    add esp, 4

    fld weights[16]
    fmulp
    fld y
    faddp
    fstp y

    inc edx

    ; --- inputs[edx] * weights[3] ---
    movzx eax, inputs[edx]
    push eax
    fild DWORD PTR [esp]
    add esp, 4

    fld weights[24]
    fmulp
    fld y
    faddp
    fstp y


    inc edx

    ; ---- compute output index and error = outputs[i] - y ----
    mov eax, edx
    shr eax, 2               ; divide by 4 -> index of vector
    dec eax
    movzx eax, outputs[eax]
    push eax
    fld DWORD PTR [esp]
    add esp, 4

    fsub y                   ; ST0 = output - y
    fstp error               ; error = output - y

    ; ---- total_loss += error*error ----
    fld error
    fld error
    fmul
    fld total_loss
    fadd
    fstp total_loss

    ; ---- backprop: for j=0..3: weights[j] += lr * error * inputs[i][j] ----
    sub edx, 4           

    movzx eax, inputs[edx]
    push eax
    fild DWORD PTR [esp]
    add esp, 4
    fld error
    fmulp                    
    fld learning_rate
    fmulp                   
    fld weights[0]
    faddp                   
    fstp weights[0]          

    inc edx

    movzx eax, inputs[edx]
    push eax
    fild DWORD PTR [esp]
    add esp, 4
    fld error
    fmulp
    fld learning_rate
    fmulp
    fld weights[8]
    faddp
    fstp weights[8]

    inc edx

    ; j=2
    movzx eax, inputs[edx]
    push eax
    fild DWORD PTR [esp]
    add esp, 4
    fld error
    fmulp
    fld learning_rate
    fmulp
    fld weights[16]
    faddp
    fstp weights[16]

    inc edx

    ; j=3
    movzx eax, inputs[edx]
    push eax
    fild DWORD PTR [esp]
    add esp, 4
    fld error
    fmulp
    fld learning_rate
    fmulp
    fld weights[24]
    faddp
    fstp weights[24]

    fld weights[0]

    inc edx

    dec ecx
    jnz for_loop

    ; print total_loss for this epoch
    

    mov ecx, epochs
    dec ecx
    jnz epochs_loop

    ; print final weights
    




    ; Testing with external weights
    mov ecx, 16
    mov edx, 0
    for_test_loop:
    finit
    fldz
    fstp y

    ; --- inputs[edx] * weights[0] and accumulate into y ---
    movzx eax, inputs[edx]
    call writeDec
    push eax
    fild DWORD PTR [esp]
    add esp, 4

    fld testWeights[0] 
    fmulp              
    fld y              
    faddp             
    fstp y            

    inc edx

    ; --- inputs[edx] * weights[1] ---
    movzx eax, inputs[edx]
    call writeDec
    push eax
    fild DWORD PTR [esp]
    add esp, 4

    fld testWeights[8]
    fmulp
    fld y
    faddp
    fstp y

    

    inc edx

    ; --- inputs[edx] * weights[2] ---
    movzx eax, inputs[edx]
    call writeDec
    push eax
    fild DWORD PTR [esp]
    add esp, 4

    fld testWeights[16]
    fmulp
    fld y
    faddp
    fstp y

    inc edx

    ; --- inputs[edx] * weights[3] ---
    movzx eax, inputs[edx]
    call writeDec
    push eax
    fild DWORD PTR [esp]
    add esp, 4

    fld testWeights[24]
    fmulp
    fld y
    faddp
    fstp y
    inc edx

    movzx eax, space
    call WriteChar

    ; compare y vs 0.5
    fld  y
    fld  half
    fcomip st(0), st(1)   
    fstp st(0)            

    ja  greater_than_half 
    mov eax, 1
    call WriteDec
    jmp done_print

greater_than_half:
    mov eax, 0
    call WriteDec

done_print:
    call Crlf
    
    dec ecx
    jnz for_test_loop

exit
main endp
end main
