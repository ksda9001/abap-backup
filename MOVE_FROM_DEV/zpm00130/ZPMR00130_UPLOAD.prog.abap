FORM frm_upload_data.
  DATA: ls_data TYPE truxs_t_text_data,
    ls_path TYPE rlgrap-filename.

  ls_path = p_path.

    "文档上传
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
    i_line_header = 'X'
    i_tab_raw_data = ls_data
    i_filename = ls_path
    TABLES
    i_tab_converted_data = gt_data
    EXCEPTIONS
    conversion_failed = 1
    OTHERS = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.

FORM frm_trans.
  IF p_sel1 = 'X'.
    REFRESH gt_alv_data.
    LOOP AT gt_data ASSIGNING <fs>.
      IF sy-tabix > 2.
        IF <fs>-c2 IS NOT INITIAL.
          CLEAR gs_alv_data.
          gs_alv_data-xxx = <fs>-c1.
          gs_alv_data-xxx = <fs>-c2.
          gs_alv_data-xxx = <fs>-c3.
          gs_alv_data-xxx = <fs>-c4.
          gs_alv_data-xxx = <fs>-c5.
          gs_alv_data-xxx = <fs>-c6.
          gs_alv_data-xxx = <fs>-c7.
          gs_alv_data-xxx = <fs>-c8.

          PERFORM check USING gs_alv_data.
          gs_alv_data-msg = gs_datac-msg.
          APPEND gs_alv_data TO gt_alv_data.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ELSEIF p_sel2 = 'X'.
    REFRESH gt_alv_data2.
    LOOP AT gt_data ASSIGNING <fs>.
      IF sy-tabix > 2.
        IF <fs>-c2 IS NOT INITIAL.
          CLEAR gs_alv_data2.
          gs_alv_data2-xxx = <fs>-c1.
          gs_alv_data2-xxx = <fs>-c2.
          gs_alv_data2-xxx = <fs>-c3.
          gs_alv_data2-xxx = <fs>-c4.
          gs_alv_data2-xxx = <fs>-c5.
          gs_alv_data2-xxx = <fs>-c6.
          gs_alv_data2-xxx = <fs>-c7.
          gs_alv_data2-xxx = <fs>-c8.
        
          PERFORM check2 USING gs_alv_data2.
          gs_alv_data2-msg = gs_datac2-msg.
          APPEND gs_alv_data2 TO gt_alv_data2.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.

FORM frm_browser_file.
  DATA: lt_rc TYPE i,
lv_init_path TYPE string,
wa_file_name TYPE file_table,
lt_file_name TYPE filetable.

"获取桌面路径
  CLEAR lv_init_path.
  CALL METHOD cl_gui_frontend_services=>getj_desktop_directory
    CHANGING
    destktop_directory = lv_init_path
    EXCEPTIONS
    cntl_error = 1
    error_no_gui = 2
    not_supported_by_gui = 3
    OTHERS = 4.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  CALL FUNCTION cl_gui_frontend_services=>file_open_dialog
    EXPORTING
    window_title = '上传文件'
    default_filename = '*.xlsx'
    file_filter = '所有文件(*.*)|*.*|Microsoft Excel文件 (*.xlsx)|*.xlsx'
    initial_directory = lv_init_path
    CHANGING
    file_table = lt_file_name
    rc = rc
    EXCEPTIONS
    file_open_dialog_failed = 1
    cntl_error = 2
    error_no_gui = 3
    not_supported_by_gui = 4
    OTHERS = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  READ TABLE lt_file_name INDEX 1 INTO wa_file_name.
  MOVE wa_file_name TO p_path.

ENDFORM.