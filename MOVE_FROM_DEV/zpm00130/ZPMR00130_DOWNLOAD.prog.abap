FORM frm_get_fullpath CHANGING pv_fullpath pv_path pv_name.
  DATA: lv_init_path TYPE string,
    lv_init_fname TYPE string,
    lv_path TYPE string,
    lv_fullname TYPE string.

  IF p_sel1 = 'X'.
    CONCATENATE TEXT-003 '.xlsx' INTO lv_init_fname.
  ELSEIF p_sel2 = 'X'.
    CONCATENATE TEXT-004 '.xlsx' INTO lv_init_fname.
  ENDIF.

  CLEAR lv_init_path.

  CALL METHOD cl_gui_frontend_services=>get_desktop_directory
    CHANGING
    desktop_directory = lv_init_path "写入桌面路径
    EXCEPTIONS
    cntl_error = 1
    error_no_gui = 2
    not_supported_by_gui = 3
    OTHERS = 4.
  IF sy_subrc <> 0.
    EXIT.
  ENDIF.

  CALL_METHOD cl_gui_frontend_services=>FILE_SAVE_DIALOG
  EXPORTING
  DEFAULT_FILE_NAME = LV_INITi_FNAME
  INITIAL_DIRECTORY = lv_init_path
  PROMPT_ON_OVERWRITE = 'X'
  CHANGING
  FILENAME = lv_fullname
  PATH = lv_path
  FULLPATH = LV_FULLPATH
  EXCEPTIONS
  cntl_error = 1
  error_no_gui = 2
  NOT_SUPPORTED_BY_GUI = 3
  others = 4.
  IF sy-subrc = 0.
    pv_fullpath = lv_fullpath.
    pv_path = lv_path.
  ENDIF.
ENDFORM.

FORM FRM_DOWN UDING PR_FILENAME.
DATA: lv_objdata LIKE wwwdatatab,
    lv_mine LIKE w3mime,
    lv_destination LIKE rlgrap-filename,
    lv_objnam TYPE string,
    lv_rc LIKE sy-subrc,
    lv_errtxt TYPE string.

DATA: lv_filename TYPE string,
    lv_result,
    lv_subrc TYPE sy-subrc.

DATA lv_objid TYPE wwwdatatab-objid.

IF p_sel1 = 'X'.
  LV_OBJID = 'XXXXXXX'
ELSEIF p_sel2 = 'X'.
  lv_objid = 'XXXXXXXXX'.
ENDIF.

"查找文件是否存在
SEKECT SINGLE RELID objid
FROM wwwdatatab
INTO CORRESPONDING FIELDS OF lv_objdata
WHERE SRTF2 = 0
AND RELID = 'MI'
AND OBJID = LV_OBJID.

"判断模板不存在则报错
IF sy-subrc NE 0 OR lv_objdata-objid EQ space.
  CONCATENATE '模板文件：' lv_objid '不存在，请用TCODE:SMW0进行加载'
    INTO lv_errtxt.
  MESSAGE e000(su) WITH lv_errtxt.

  lv_filename = pr_filename.

    "判断本地地址是否已经存在此文件
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIT
    EXPORTING
    FILE = LV_FILENAME
    RECEVING
    RESULT = lv_result
    EXCEPTIONS
    CNTL_ERROR = 1
    ERROR_NO_GUI = 2
    WRONG_PARAMETER = 3
    NOT_SUPPORTED_BY_GUI = 4
    OTHERS = 5.

  IF lv_result EQ 'X'.
    CALL METHOD cl-gui_frontend_services=>file_delete
        EXPORTING
        filename = lv_filename
        CHANGING
        rc = lv_subrc
        EXCEPTIONS
        file_delete_failed = 1
        cntl_error = 2
        error_no_gui = 3
        file_not_found = 4
        access_denied = 5
        unknown_error = 6
        not_supported_by_gui = 7
        wrong_parameter = 8
        OTHERS = 9.

    IF lv_subrc <> 0.
      CONCATENATE '同名EXCEL文件已打开' '请关闭EXCEL后重试'
            INTO lv_errtxt.
      MESSAGE e000(su) WITH lv_errtxt.
    ENDIF.
  ENDIF.

  lv_destination = pr_filename.

  CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
  EXPORTING
  key = lv_objdata
  destination = lv_destination
  IMPORTING
  rc = lv_rc.
  IF lv_rc NE 0.
    CONCATENATE '模板文件：' lv_objid '下载失败'
    INTO lv_errtxt.
  ENDIF.
ENDIF.
ENDFORM.