REPORT transactionProgram.
DATA: OK_CODE TYPE SY-UCOMM,
    SAVE_OK TYPE SY-UCOMM.

CALL SCREEN 100.

MODULE EXIT INPUT.
    LEAVE PROGRAM.
ENDMODULE.

MODULE USER_COMMAND_0100 INPUT.
    SAVE_OK = OK_CODE.
    CLEAR OK_CODE.
    CASE SAVE_OK.
        WHEN 'TEST'.
            LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
        WHEN 'TEST2'.
            LEAVE LIST-PROCESSING.
        WHEN 'TEST3'.
            LEAVE TO CURRENT TRANSACTION.
        WHEN 'TEST4'.
            CALL TRANSACTION 'SE38'.
        WHEN 'TEST5'.
            CALL TRANSACTION 'SE51'.
        WHEN 'TEST6'.
            LEAVE TO SCREEN 0.
    ENDCASE.
ENDMODULE.

***********************************************************************
*****************This in se51.*****************************************
*                                                                     *
*PROCESS BEFORE OUTPUT.                                               *
**MODULE STATUS_0100.                                                 *
*                                                                     *
*PROCESS AFTER INPUT.                                                 *
*MODULE EXIT AT EXIT-COMMAND.                                         *
*MODULE USER_COMMAND_0100.                                            *
*                                                                     *
***********************************************************************