REPORT z106.
TABLES: YTBKPF.
SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS S_BUKRS FOR YTBKPF-BUKRS.
SELECT-OPTIONS S_BELNR FOR YTBKPF-BELNR.
SELECT-OPTIONS S_GJANR FOR YTBKPF-GJANR.  
SELECTION-SCREEN END OF BLOCK 001.

TYPES:
BEGIN OF RSDATA,
CHECKBOX,
BUKRS TYPE YTBKPF-BUKRS,
BELNR TYPE YTBKPF-BELNR,
GJANR TYPE YTBKPF-GJANR,
END OF RSDATA.

DATA:
GT_DATA TYPE TABLE OF RSDATA,
GS_DATA TYPE RSDATA,
GT_FIELDCAT TYPE LVC_T_FCAT,
GS_FIELDCAT TYPE LVC_S_FCAT,
GS_LAYOUT TYPE LVC_S_LAYO,
GT_TITLE TYPE LVC_TITLE,
ITEMS TYPE TABLE OF YTBKPF WITH HEADER LINE.

START-OF-SELECTION.
PERFORM GET_DATA.
PERFORM DISPLAY_DATA.

***FORM GET_DATA
FORM GET_DATA.
    SELECT
    TAB~BUKRS
    TAB~BELNR
    TAB~GJANR
    INTO CORRESPONDING FIELDS OF TABLE GT_DATA
    FROM YTBKPF AS TAB
    WHERE TAB~BUKRS IN S_BUKRS
    AND TAB~BELNR IN S_BELNR
    AND TAB~GJANR IN S_GJANR. 
ENDFORM.

***FORM BUILD_FIELDCAT
FORM BUILD_FIELDCAT USING P_FIELDNAME TYPE P_FIELDNAME
P_QFIELDNAME TYPE LVC_QFNAME
P_CFIELDNAME TYPE LVC_CFNAME
P_REF_TABLE TYPE LVC_RTNAME
P_REF_FIELD TYPE LVC_RFNAME
P_CONVEXIT TYPE P_CONVEXIT
P_EMPHASIZE TYPE LVC_EMPHSZ
P_SCRTEXT_L TYPE SCRTEXT_L.

GS_FIELDCAT-FIELDNAME = P_FIELDNAME
GS_FIELDCAT-QFIELDNAME = P_QFIELDNAME
GS_FIELDCAT-CFIELDNAME = P_CFIELDNAME
GS_FIELDCAT-REF_TABLE = P_REF_TABLE
GS_FIELDCAT-REF_FIELD = P_REF_FIELD
GS_FIELDCAT-CONVEXIT = P_CONVEXIT
GS_FIELDCAT-EMPHASIZE = P_EMPHASIZE
GS_FIELDCAT-SCRTEXT_L = P_SCRTEXT_L.
GS_FIELDCAT-COLDDICTXT = 'L'.
IF P_FIELDNAME = 'CHECKBOX'.
    GS_FIELDCAT-CHECKBOX = 'X'.
    GS_FIELDCAT-EDIT = 'X'.
ENDIF.

APPEND GS_FIELDCAT TO GT_FIELDCAT.
CLEAR GS_FIELDCAT.
ENDFORM.

FORM DISPLAY_DATA.
    PERFORM BUILD_FIELDCAT USING 'CHECKBOX' '' '' '' '' '' '' '序号'.
    PERFORM BUILD_FIELDCAT USING 'BUKRS' '' '' '' '' '' '' '序号'.
    PERFORM BUILD_FIELDCAT USING 'BELNR' '' '' '' '' '' '' '序号'.
    PERFORM BUILD_FIELDCAT USING 'GJAHR' '' '' '' '' '' '' '序号'.

    GS_LAYOUT-CWIDTH_OPT = 'X'.
    GS_LAYOUT-ZEBRA = 'X'.

    DATA(LV_LINE) = LINES( GT_DATA ).
    GT_TITLE = '共' && lv_line && '条数据'.
    GS_LAYOUT-GRID_TITLE = GT_TITLE.
    
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
    I_CALLBACK_PROGRAM = SY-REPID
    I_CALLBACK_PF_STATUS_SET = 'PF_STATUS_ALV'
    I_CALLBACK_USER_COMMAND = 'USER_COMMAND_ALV'
    IT_FIELDCAT_LVC = GT_FIELDCAT
    IS_LAYOUT_LVC = GS_LAYOUT
    I_GRID_TITLE = GT_TITLE
    I_DEFAULT = 'X'
    I_SAVE = 'A'
    TABLES
    T_OUTTAB = GT_DATA
    EXCEPTIONS
    OTHERS = 1.
ENDFORM.

***FORM PF_STATUS_ALV
FORM PF_STATUS_ALV USING RT_EXTAB TYPE SLIS_T_EXTAB.
    SET PF-STATUS 'STATUS_ALV' EXCLUDING RT_EXTAB.
ENDFORM.

***FORM USER_COMMAND_ALV
FORM USER_COMMAND_ALV USING R_UCOMM LIKE SY-UCOMM
    RS_SELFIELD TYPE SLIS_SELFIELD.
    DATA LR_GRID TYPE REF TO CL_GUI_ALV_GRID.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
    E_GRID = LR_GRID.
    CALL METHOD LR_GRID->CHECK_CHANGED_DATA.
    CASE R_UCOMM.
        WHEN '&&ALL'.
            GS_DATA-CHECKBOX = 'X'.
            MODIFY GT_DATA FROM GS_DATA TRANSPORTING CHECKBOX WHERE CHECKBOX = ''. 
        WHEN '&&SALL'.
            GS_DATA-CHECKBOX = ''.
            MODIFY GT_DATA FROM GS_DATA TRANSPORTING CHECKBOX WHERE CHECKBOX = 'X'. 
        WHEN '&&PRINT'.
            REFRESH ITEMS.
            LOOP AT GT_DATA INTO GS_DATA WHERE CHECKBOX = 'X'.
                ITEMS-BURKS = GS_DATA-BURKS.
                ITEMS-BELNR = GS_DATA-BELNR.
                ITEMS-GJAHR = GS_DATA-GJAHR.
                APPEND ITEMS.
            ENDLOOP.
            PERFORM FRM_PRINT_DATA.
    ENDCASE.
    RS_SELFIELD-REFRESH = 'X'.
ENDFORM.

FORM FRM_EXPORT_DATA USING P_FLAG.
    DATA LV_FIELNAME TYPE CHAR128.
    DATA L_FILENAME TYPE LOCALFILE.
    DATA L_MESS TYPE CHAR255.

    LV_FIELNAME = SY-UNAME&&'_'&&SY-DATUM&&SY-UZEIT&&'.XML'.
    CALL FUNCTION 'ZFM_TEST_DOWNLOAD'
    EXPORTING
    I_FLAG = 'A'
    I_FIELNAME = LV_FIELNAME
    I_ZJKBM = 'WMS0001'
    IMPORTING
    MESSAGE = L_MESS
    TABLES
    I_TAB = GT_DATA.

    IF L_MESS = 'OK'.
        L_FILENAME = LV_FIELNAME.
        CALL FUNCTION 'ZFM_JL_TO_SAP'
        EXPORTING
        I_FIELNAME = L_FILENAME
        I_FLAG = '1'
        I_ZYWLX = '0'.
        MESSAGE : '传输到网间系统成功' TYPE 'S'.
    ENDIF.
ENDFORM.

FORM FRM_PRINT_DATA.
    CALL FUNCTION **************
    ****************************
    ****************************
    ****************************
ENDFORM.