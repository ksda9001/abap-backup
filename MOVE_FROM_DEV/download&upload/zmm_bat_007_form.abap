FORM DATA_PROCESS.
IF GT_ALV_DATA IS NOT INITIAL.
    "进度条
    DATA: L_PERC TYPE I VALUE 0.
    DATA: L_LINE TYPE STRING,
    L_TOTAL TYPE STRING.
    DATA: L_STXT TYPE STRING.
    DATA: L_SPERC(3) TYPE C.

    DESCRIBE TABLE GT_ALV_DATA LINES L_TOTAL.
    LOOP AT GT_ALV_DATA ASSIGNING <FS_DATA>.
        "传输选中数据
        IF <FS_DATA>-CHECK = 'X'.
            ADD 1 TO L_LINE.

            PERFORM BAPI.
            IF SY-SUBRC = 0.
                <fs_data>-sign = 'X'.

                l_perc = l_line * 100 / L_TOTAL.

                concatenate '已导入：第' L_LINE '条，共' L_TOTAL '条' INTO L_STXT.
                CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
                EXPORTING
                PERCENTAGE = L_PERC
                TEXT = L_STXT.
            ENDIF.

        ELSE.
            MESSAGE '请至少选中一条数据' TYPE 'E'.
        ENDIF.
    ENDLOOP.
ENDIF.
ENDFORM.

FORM BAPI.
    xxxxxxxx
    xxxxxxxx
    xxxxxxxx
    xxxxxxxx
    
ENDFORM.