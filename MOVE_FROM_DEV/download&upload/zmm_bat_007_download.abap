"获取下载路径
FORM frm_get_fullpath CHANGING pv_fullpath TYPE string
pv_path TYPE string
pv_name TYPE string.

DATA: lv_init_path TYPE string,
lv_init_fname type string,
lv_path type string,
lv_fullpath type string.

"方便i18n
concatenate text-003 '_' SY-DATUM '.xlsx' into lv_init_fname.

"获取桌面路径
CALL METHOD cl_gui_frontend_services=>get_desktop_directory
CHANGINGb
desktop_directory = lv_init_path "写入桌面路径
EXCEPTIONS
cntl_error = 1
error_no_gui = 2
not_supported_by_gui = 3
OTHERS = 4.
IF sy-subrc <> 0.
    EXIT.
ENDIF.

"配置保存位置
CALL METHOD cl_gui_frontend_services=>file_save_dialog
EXPORTING
default_file_name = lv_init_fname
initial_directory = lv_init_path
prompt_on_overwrite = 'X'
CHANGING
FILENAME = lv_fullname
path = lv_path
fullpath = lv_fullpath
EXCEPTIONS
cntl_error = 1
error_no_gui = 2
not_supported_by_gui = 3
OTHERS = 4.
IF sy-SUBRC = 0.
    pv_fullpath = lv_fullpath.
    pv_path = lv_path.
ENDIF.
ENDFORM.

FORM frm_down USING pr_filename.
DATA: lv_objdata like wwwdatatab,
lv_mime like w3mime,
lv_destination like RLGRAP-FILENAME,
lv_objnam like string,
lv_rc like sy-subrc,
lv_errtxt type string.

DATA: lv_filename type string,
lv_result,
lv_subrc type sy-subrc.

DATA: lv_objid TYPE wwwdatatab-objid.

lv_objid = 'xxxxxxxx' "此处配置在SWM0

"查找文件是否存在
SELECT SINGLE relid objid
FROM wwwdata
INTO CORRESPONDING FIELDS OF lv_objdata
WHERE SRTF2 = 0
AND RELID = 'MI'
AND OBJID = LV_OBJID.

"判断模板不存在则报错
IF SY-SUBRC NE 0 OR lv_objdata-OBJID EQ SPACE.
    concatenate '模板文件：' LV_OBJID '不存在，请用TCODE：SMW0进行加载'
    into lv_errtxt.
    MESSAGE e000(SU) WITH LV_ERRTXT.
ENDIF.

lv_filename = pr_filename.

"判断本地地址是否已经存在此文件
CALL METHOD cl_gui_frontend_services=>FILE_EXIST
EXPORTING
FILE = lv_filename
RECEIVING
RESULT = lv_result
EXCEPTIONS
cntl_error = 1
error_no_gui = 2
WRONG_PARAMETER = 3
not_supported_by_gui = 4
OTHERS = 5.

IF lv_result EQ 'X'.
    CALL METHOD cl_gui_frontend_services=>FILE_DELETE
    EXPORTING
    FILENAME = lv_filename
    CHANGING
    RC = lv_subrc
    EXCEPTIONS
    FILE_DELETE_FAILED = 1
    cntl_error = 2
    error_no_gui = 3
    FILE_NOT_FOUND = 4
    ACCESS_DENIED = 5
    UNKNOWN_ERROR = 6
    not_supported_by_gui = 7
    WRONG_PARAMETER = 8
    OTHERS = 9.

    IF lv_subrc <> 0.
        concatenate '同名EXCEL文件已打开' '请关闭EXCEL后重试'
        into lv_errtxt
        MESSAGE e000(su) with lv_errtxt.
    ENDIF.
ENDIF.

lv_destination = pr_filename.

call FUNCTION 'DOWNLOAD_WEB_OBJECT'
EXPORTING
key = lv_objdata
destination = lv_destination
importing
rc = lv_rc.
IF lv_rc NE 0.
    concatenate '模板文件：''下载失败'
    into LV_ERRTXT.
ENDIF.
ENDFORM.