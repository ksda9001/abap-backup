FORM FRM_UPLOAD_DATA,
DATA: LS_DATA TYPE TRUXS_T_TEXT_DATA,
LS_PATH TYPE RLGRAP-FILENAME.
LS_PATH = P_PATH. 
ENDFORM.


"文档上传用
CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
EXPORTING
I_LINE_HEADER = 'X'
I_TAB_RAW_DATA = LS_DATA
I_FIELNAME = LS_PATH
TABLES
I_TAB_CONVERTED_DATA = GT_ALV_DATA
EXCEPTIONS
CONVERSION_FAILED = 1
OTHERS = 2.
IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.