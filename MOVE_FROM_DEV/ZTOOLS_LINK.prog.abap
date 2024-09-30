*&---------------------------------------------------------------------*
*& Report YTDGJ_TOOL_FRM_10
*&---------------------------------------------------------------------*
*& 一种超时阻止装置
*&---------------------------------------------------------------------*
REPORT ytdgj_tool_frm_10.
CALL SCREEN 100.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  IF sy-ucomm = 'ON'.
    DATA: text TYPE string,
          time TYPE i.

    time = 0 .

    IF sy-langu = '1'.
      CONCATENATE '已阻止SAP超时关闭，请使用其他会话进行工作' '！' INTO text.
    ELSE.
      CONCATENATE 'Already stop SAP from timeout exit.Please use another session for working' '!' INTO text.
    ENDIF.

    DATA: gt_info TYPE TABLE OF uinfo2,
          gv_num  TYPE i.

    "获取当前用户的会话数
    CALL FUNCTION 'TH_LONG_USR_INFO'
      EXPORTING
        user      = sy-uname
      TABLES
        user_info = gt_info.

    DESCRIBE TABLE gt_info LINES gv_num.

    "对当前打开的会话数进行判断，如果只打开一个，那么在另外打开一个新的会话供用户使用
    IF gv_num = 1.
      CALL FUNCTION 'TH_CREATE_FOREIGN_MODE'
        EXPORTING
          client           = sy-mandt
          user             = sy-uname
        EXCEPTIONS
          user_not_found   = 1
          cant_create_mode = 2
          OTHERS           = 3.
      IF sy-subrc <> 0.
        MESSAGE '程序运行时出现错误！' TYPE 'E'.
      ENDIF.
    ENDIF.

    DO.
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = time
          text       = text
        EXCEPTIONS
          OTHERS     = 1.

      time = time + 1.
      IF time = 101.
        time = 0.
      ENDIF.

      WAIT UP TO 10 SECONDS.
    ENDDO.

  ENDIF.
ENDMODULE.