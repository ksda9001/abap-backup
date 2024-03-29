****** TWO WAY OF LISTBOX ******
*** 30082023 ***

REPORT Listbox.

PARAMETERS: P_PRTMV TYPE CHAR25 AS LISTBOX VISIBLE LENGTH 25.
PARAMETERS: P_OUTIN AS LISTBOX VISIBLE LENGTH 8 OBLIGATORY DEFAULT '1'.

INITIALIZATION.
PERFORM FRM_INIT.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_OUTIN.
PERFORM P_SET_SELECTION2.

FORM FRM_INIT.
    DATA: L_FIELD TYPE VRM_ID,
    LIT_LISTBOX TYPE VRM_VALUES,
    LWA_LISTBOX LIKE LINE OF LIT_LISTBOX.

    LWA_LISTBOX-KEY = 'A'.
    LWA_LISTBOX-TEXT = 'DO NOT PRINT'.
    APPEND LWA_LISTBOX TO LIT_LISTBOX.

    LWA_LISTBOX-KEY = 'B'.
    LWA_LISTBOX-TEXT = 'PRINT'.
    APPEND LWA_LISTBOX TO LIT_LISTBOX.

    LWA_LISTBOX-KEY = 'C'.
    LWA_LISTBOX-TEXT = 'PRINT AND MOVE STOCK'.
    APPEND LWA_LISTBOX TO LIT_LISTBOX.

    L_FIELD = 'P_PRTMV'.

    CALL FUNCTION 'VRM_SET_VALUES'.
    EXPORTING
    ID = L_FIELD
    VALUES = LIT_LISTBOX.
ENDFORM.

FORM P_SET_SELECTION2.
    TYPES: BEGIN OF TY,
        COL1 TYPE CHAR1,
        COL2 TYPE CHAR2,
    END OF TY.

    DATA STAB TYPE TABLE OF TY.
    STAB = VALUE #(
    ( COL1 = '1' COL2 = '出库' )
    ( COL1 = '2' COL2 = '入库' )
    ).

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
    RETFIELD = 'COL1'
    DYNPPROG = SY-REPID
    DYNPNR = SY-DYNNR
    DYNPROFIELD = 'COL1'
    VALUE_ORG = 'S'
    CALLBACK_PROGRAM = SY-REPID
    TABLES
    VALUE_TAB = STAB
    EXCEPTIONS
    PARAMETER_ERROR = 1
    NO_VALUES_FOUND = 2
    OTHERS = 3.
    IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
ENDFORM.