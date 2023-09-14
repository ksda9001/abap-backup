REPORT ztest_alv_download.

DATA:git_vbap TYPE STANDARD TABLE OF vbap.
DATA:git_fcat   TYPE lvc_t_fcat,
     gwa_layout TYPE lvc_s_layo.
DATA: l_path     TYPE string,
      l_filename TYPE string.

START-OF-SELECTION.

  SELECT *
    INTO TABLE git_vbap
    FROM vbap
    UP TO 100 ROWS.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'VBAP'
    CHANGING
      ct_fieldcat            = git_fcat "生成下载excel文件的头--reptext字段
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  gwa_layout-zebra = 'X'.
  gwa_layout-sel_mode = 'A'.
  gwa_layout-cwidth_opt = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'FRM_STATUS_SET'
      i_callback_user_command  = 'FRM_USER_COMMAND'
      is_layout_lvc            = gwa_layout
      it_fieldcat_lvc          = git_fcat
    TABLES
      t_outtab                 = git_vbap[]
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

FORM frm_status_set  USING rt_extab  TYPE slis_t_extab.
  SET PF-STATUS 'S0001'.
ENDFORM.                    "frm_status_set
FORM frm_user_command USING r_ucomm TYPE sy-ucomm
                            rs_selfield TYPE slis_selfield.
* Local Variable Declare
  DATA: l_filename TYPE string.

  IF r_ucomm = 'DOWN'.
*   get file name
    PERFORM frm_get_directory CHANGING l_filename.
*   download
    PERFORM export_to_excel USING l_filename.
  ENDIF.

ENDFORM.
FORM frm_get_directory  CHANGING c_filename TYPE string.

  DATA : l_title    TYPE string,
         l_filename TYPE string,                         "file name
         l_path     TYPE string VALUE 'C:\TEMP',         "path
         l_fullpath TYPE string,                         "full path
         l_result   TYPE i.                              "result return

  l_title = 'Save as...'.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title         = l_title
      default_extension    = 'XLSX'
      default_file_name    = 'Download.XLSX'
*     with_encoding        =
*     file_filter          =
      initial_directory    = l_path
      prompt_on_overwrite  = 'X'
    CHANGING
      filename             = l_filename
      path                 = l_path
      fullpath             = l_fullpath
      user_action          = l_result
*     file_encoding        =
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    c_filename     = l_filename.  "l_path.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EXPORT_TO_EXCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_FILENAME  text
*----------------------------------------------------------------------*
FORM export_to_excel  USING i_filename.

  DATA: l_length     TYPE i,
        l_xml_stream TYPE xml_rawdata,
        l_flavour    TYPE string,
        l_version    TYPE string.

  DATA: lr_alv_new_data TYPE REF TO data,
        lr_result_data  TYPE REF TO cl_salv_ex_result_data_table.

  DATA: ls_xml_choice TYPE if_salv_bs_xml=>s_type_xml_choice,
        xml           TYPE xstring.

  GET REFERENCE OF git_vbap INTO lr_alv_new_data.

  lr_result_data = cl_salv_ex_util=>factory_result_data_table(
*        t_selected_rows             = lt_lvc_row
*        t_selected_columns          = lt_sel_cols
*        t_selected_cells            = lt_sel_cells
      r_data                      = lr_alv_new_data
*      s_layout                    = lr_grid->m_cl_variant->ms_layout
      t_fieldcatalog              = git_fcat
*      t_sort                      = lr_grid->m_cl_variant->mt_sort
*      t_filter                    = lr_grid->m_cl_variant->mt_filter
*      t_hyperlinks                = lr_grid->mt_hyperlinks
*        s_current_cell              = ls_cur_cell
*        hyperlink_entry_column      = ls_hyper_entry
*        dropdown_entry_column       = ls_dropdown_entry
*        r_top_of_list               = lr_top_of_list
*        r_end_of_list               = lr_end_of_list
*        t_dropdown_values           = lt_drdn
       ).

  CASE cl_salv_bs_a_xml_base=>get_version( ).
    WHEN if_salv_bs_xml=>version_25.
      l_version = if_salv_bs_xml=>version_25.
    WHEN if_salv_bs_xml=>version_26.
      l_version = if_salv_bs_xml=>version_26. " = 2.6
  ENDCASE.

  l_flavour = if_salv_bs_c_tt=>c_tt_xml_flavour_export. "Flavor for Complete ALV XML

  CALL METHOD cl_salv_bs_tt_util=>if_salv_bs_tt_util~transform
    EXPORTING
      xml_type      = if_salv_bs_xml=>c_type_xlsx  "XLSX
      xml_version   = l_version
      r_result_data = lr_result_data
      xml_flavour   = l_flavour
      gui_type      = if_salv_bs_xml=>c_gui_type_gui  "Y6DK066330
    IMPORTING
      xml           = xml.

  IF NOT i_filename IS INITIAL.
    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = xml
      IMPORTING
        output_length = l_length
      TABLES
        binary_tab    = l_xml_stream.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        bin_filesize = l_length
        filetype     = 'BIN'
        filename     = i_filename
      CHANGING
        data_tab     = l_xml_stream
      EXCEPTIONS
        OTHERS       = 1.
    IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

ENDFORM.