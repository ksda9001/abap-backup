MODULE F4_POSID INPUT.
CLEAR g_f4.
GET CURSOR LINE l_low.
IF ZSDT00070-KUNNR IS INITIAL.
    MESSAGE S021 WITH '请输入用户单位' DISPLAY LIKE 'E'.
    CHECK
ENDIF.

CLEAR: lv_kunnr.

CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
EXPORTING
INPUT = ZSDT00070-KUNNR
IMPORTING
OUTPUT = lv_kunnr.

IF SY-TCODE = 'XXX'.
    REFRESH GIT_TAB.
    GIT_TAB-TABNAME = 'XXXX' "表名
    GIT_TAB-FIELDNAME = 'XXXX' "列名
    GIT_TAB-FIELDTEXT = 'XXXXXX' "列名描述
    GIT_TAB-FIELD_ATTR = ''
    APPEND GIT_TAB.

    CALL FUNCTION 'POPUP_GET_VALUES_USER_HELP' "子屏幕选择器
    EXPORTING
    POPUP_TITLE = 'XXXXXXX'
    IMPORTING
    RETURNCODE = L_RET
    TABLES
    FIELDS = GIT_TAB
    EXCEPTIONS
    ERROR_IN_FIELDS = 1
    OTHERS = 2.

    IF SY-SUBRC = 0.
        LOOP AT GIT_TAB.
        IF GIT_TAB-FIELDNAME = 'XXXX'. "判断列名并取值
            CONCATENATE '%'GIT_TAB-VALUE'%' INTO XXXX. "拼接模糊查询
        ENDIF.
        CLEAR GIT_TAB.
        ENDLOOP.

        SELECT * INTO TABLE @DATA(LT_POSID)
        FROM ZSDT00180 AS APPEND
        WHERE A~KUNNR = @XXXX-XXXX
        AND A~XXXX LIKE @XXXX. "匹配模糊查询
        IF SY-SUBRC = 0.
            CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
            EXPORTING
            REFIELD = 'XXXX'
            DYNPPROG = SY-REPID
            DYNPNR = SY-DYNNR
            DYNPROFIELD = 'GT_DATA-XXXX'
            VALUE_ORG = 'S'
            TABLES
            VALUE_TAB = LT_POSID
            RETURN_TAB = RETURN_TAB
            EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS = 3.
            IF SY-SUBRC = 0.
                READ TABLE RETURN_TAB INDEX 1.
                IF SY-SUBRC = 0.
                    CALL FUNCTION 'CONVERSION_EXIT_ABPSN_INPUT'
                    EXPORTING
                    INPUT = RETURN_TAB-FIELDVAL
                    IMPORTING
                    OUTPUT = RETURN_TAB-FIELDVAL.

                    READ TABLE LT_POSID INTO DATA(LS_POSID) WITH KEY XXXX
                    XXXX
                    XXXX

                    I_FIELD = 'XXXXXX'.
                    I_VALUE = LS_POSID-POSID.

                    CALL FUNCTION 'SET_DYNP_VALUE'
                    EXPORTING
                    I_FIELD = I_FIELD
                    I_REPID = SY-REPID
                    I_DYNNR = SY-DYNNR
                    I_VALUE = I_VALUE.
                    MODIFY GT_DATA INDEX l_low.
                    g_f4 = 'X'.
                    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
                    EXPORTING
                    FUNCTIONCODE = '='
                    EXCEPTIONS
                    FUNCTION_NOT_SUPPORTED = 1
                    OTHERS = 2.
                ENDIF.
            ENDIF.
        ENDIF.
    ENDIF.
ENDIF.
ENDMODULE.