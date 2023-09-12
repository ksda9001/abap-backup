REPORT mutilTab.

*& AUTO WRITED BY SPWIZARD


CONSTANTS: BEGIN OF C_TBS,
        TAB1 LIKE SY-UCOMM VALUE 'TBS_FC1',
        TAB2 LIKE SY-UCOMM VALUE 'TBS_FC2',
        TAB3 LIKE SY-UCOMM VALUE 'TBS_FC3',
        END OF C_TBS.

CONTROLS: TBS TYPE TABSTRIP.
DATA: BEGIN OF G_TBS,
    SUBSCREEN LIKE SY-DYNNR,
    PROG LIKE SY-REPID VALUE 'ZHELL66',
    PRESSED_TAB LIKE SY-UCOMM VALUE C_TBS-TAB1,
    END OF G_TBS.

DATA: OK_CODE LIKE SY-UCOMM.

CALL SCREEN 100.

MODULE TBS_ACTIVE_TAB_SET OUTPUT.
    TBS_ACTIVETAB = G_TBS-PRESSED_TAB.
    CASE G_TBS-PRESSED_TAB.
        WHEN C_TBS-TAB1.
            G_TBS-SUBSCREEN = '0101'.
        WHEN C_TBS-TAB2.
            G_TBS-SUBSCREEN = '0102'.
        WHEN C_TBS-TAB3.
            G_TBS-SUBSCREEN = '0103'.
    ENDCASE.
ENDMODULE.

MODULE TBS_ACTIVE_TAB_GET INPUT.
    OK_CODE = SY-UCOMM.
    CASE OK_CODE.
        WHEN C_TBS-TAB1.
            G_TBS-PRESSED_TAB = C_TBS-TAB1
        WHEN C_TBS-TAB2.
            G_TBS-PRESSED_TAB = C_TBS-TAB2
        WHEN C_TBS-TAB3.
            G_TBS-PRESSED_TAB = C_TBS-TAB3
    ENDCASE.
ENDMODULE.
***********************************************************************
*****************This in se51.*****************************************
*                                                                     *
*PROCESS BEFORE OUTPUT.                                               *
*MODULE TBS_ACTIVE_TAB_SET.                                           *
*CALL SUBSCREEN TBS_SCA                                               *
*INCLUDING G_TBS-PROG G_TBS-SUBSCREEN                                 *
*PROCESS AFTER INPUT.                                                 *
*CALL SUBSCREEN TBS_SCA.                                              *
*MODULE TBS_ACTIVE_TAB_GET.                                           *
*                                                                     *
***********************************************************************