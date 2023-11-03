REPORT zmm_bat_007.

include zmm_bat_007_top.
include zmm_bat_007_screen.
include zmm_bat_007_upload.
include zmm_bat_007_form.
include zmm_bat_007_display.

"控制选择面板 文件选择框的显隐
at selection-screen on value-request for p_path.
perform frm_browser_file.

at selection-screen output.
LOOP AT screen.
    IF screen-group1 = 'M1' OR screen-group1 = 'M2'.
        "下载/日志隐藏
        IF p_down = 'X'.
            screen-active = 0.
        ENDIF.
        "上传文件显示
        IF p_up = 'X' and screen-group1 = 'M2'.
            screen-active = 0.
        ENDIF.

        modify screen.
    ENDIF.
ENDLOOP.

start-of-selection.
"若选中下载
IF p_down = 'X'. "获取下载路径
    perform frm_get_fullpath CHANGING gv_fullpath gv_path gv_name.

    "路径为空则退出
    IF gv_fullpath IS INITIAL.
        MESSAGE '用户取消操作' TYPE 'S'.
        RETURN.
    ENDIF.

    "下载模板
    perform frm_down using gv_fullpath.
ENDIF.

"若选中上传
IF p_path is INITIAL and p_up = 'X'.
    MESSAGE '请选择导入文件' TYPE 'S' DISPLAY LIKE 'W'.
    STOP.
ENDIF.

IF P_UP = 'X' AND p_path IS NOT INITIAL.
    perform FRM_UPLOAD_DATA. "上传
    perform FRM_DISPLAY. "上传后显示
ENDIF.