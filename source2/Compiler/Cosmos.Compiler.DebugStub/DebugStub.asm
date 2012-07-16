



DebugStub_HackCompareAsmBreakEIP:
Cmp EAX, DebugStub_AsmBreakEIP
DebugStub_HackCompareAsmBreakEIP_Exit:
Ret

DebugStub_BreakOnAddress:
Pushad
Call DebugStub_ComReadEAX
Mov ECX, EAX

Mov EAX, 0
Call DebugStub_ComReadAL

Mov EBX, DebugBPs
SHL EAX, 2
Add EBX, EAX

Mov [EBX + 0], ECX
DebugStub_BreakOnAddress_Exit:
Popad
Ret

DebugStub_Executing2:

Mov EAX, [DebugStub_CallerEIP]
Cmp EAX, [DebugStub_AsmBreakEIP]
JNE DebugStub_Executing2_Block1_End
Call DebugStub_ClearAsmBreak
Call DebugStub_Break
Jmp DebugStub_Executing2_Normal
DebugStub_Executing2_Block1_End:


Mov EAX, [DebugStub_CallerEIP]
Mov EDI, DebugBPs
Mov ECX, 256
repne scasd
JZ DebugStub_Executing2_Block2_End
Call DebugStub_Break
Jmp DebugStub_Executing2_Normal
DebugStub_Executing2_Block2_End:

Cmp dword[DebugStub_DebugBreakOnNextTrace], DebugStub_Const_StepTrigger_Into
JNE DebugStub_Executing2_Block3_End
Call DebugStub_Break
Jmp DebugStub_Executing2_Normal
DebugStub_Executing2_Block3_End:

Cmp dword[DebugStub_DebugBreakOnNextTrace], DebugStub_Const_StepTrigger_Over
JNE DebugStub_Executing2_Block4_End
Mov EAX, [DebugStub_CallerEBP]
Cmp EAX, [DebugStub_BreakEBP]
JA DebugStub_Executing2_Block5_End
Call DebugStub_Break
DebugStub_Executing2_Block5_End:
Jmp DebugStub_Executing2_Normal
DebugStub_Executing2_Block4_End:

Cmp dword[DebugStub_DebugBreakOnNextTrace], DebugStub_Const_StepTrigger_Out
JNE DebugStub_Executing2_Block6_End
Mov EAX, [DebugStub_CallerEBP]
Cmp EAX, [DebugStub_BreakEBP]
JE DebugStub_Executing2_Normal
JZ DebugStub_Executing2_Block7_End
Call DebugStub_Break
DebugStub_Executing2_Block7_End:
Jmp DebugStub_Executing2_Normal
DebugStub_Executing2_Block6_End:

DebugStub_Executing2_Normal:
Cmp dword[DebugStub_TraceMode], DebugStub_Const_Tracing_On
JNE DebugStub_Executing2_Block8_End
Call DebugStub_SendTrace
DebugStub_Executing2_Block8_End:

DebugStub_Executing2_CheckForCmd:
Mov DX, [DebugStub_ComAddr]
Add DX, 5
In AL, DX
Test AL, 1
JZ DebugStub_Executing2_Block9_End
Call DebugStub_ProcessCommand
Jmp DebugStub_Executing2_CheckForCmd
DebugStub_Executing2_Block9_End:
DebugStub_Executing2_Exit:
Ret

DebugStub_Break2:
Mov dword[DebugStub_DebugBreakOnNextTrace], DebugStub_Const_StepTrigger_None
Mov dword[DebugStub_BreakEBP], 0
Mov dword[DebugStub_DebugStatus], DebugStub_Const_Status_Break
Call DebugStub_SendTrace

DebugStub_Break2_WaitCmd:
Call DebugStub_ProcessCommand


Cmp AL, DebugStub_Const_Vs2Ds_Continue
JE DebugStub_Break2_Done

Cmp AL, DebugStub_Const_Vs2Ds_SetAsmBreak
JNE DebugStub_Break2_Block1_End
Call DebugStub_SetAsmBreak
Jmp DebugStub_Break2_WaitCmd
DebugStub_Break2_Block1_End:

Cmp AL, DebugStub_Const_Vs2Ds_StepInto
JNE DebugStub_Break2_Block2_End
Mov dword[DebugStub_DebugBreakOnNextTrace], DebugStub_Const_StepTrigger_Into
Jmp DebugStub_Break2_Done
DebugStub_Break2_Block2_End:

Cmp AL, DebugStub_Const_Vs2Ds_StepOver
JNE DebugStub_Break2_Block3_End
Mov dword[DebugStub_DebugBreakOnNextTrace], DebugStub_Const_StepTrigger_Over
Mov EAX, [DebugStub_CallerEBP]
Mov [DebugStub_BreakEBP], EAX
Jmp DebugStub_Break2_Done
DebugStub_Break2_Block3_End:

Cmp AL, DebugStub_Const_Vs2Ds_StepOut
JNE DebugStub_Break2_Block4_End
Mov dword[DebugStub_DebugBreakOnNextTrace], DebugStub_Const_StepTrigger_Out
Mov EAX, [DebugStub_CallerEBP]
Mov [DebugStub_BreakEBP], EAX
Jmp DebugStub_Break2_Done
DebugStub_Break2_Block4_End:

Jmp DebugStub_Break2_WaitCmd

DebugStub_Break2_Done:
Call DebugStub_AckCommand
Mov dword[DebugStub_DebugStatus], DebugStub_Const_Status_Run
DebugStub_Break2_Exit:
Ret

