*&---------------------------------------------------------------------*
*& Report  ZLEARNING12_OLE_FIST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZLEARNING12_OLE_FIST.
INCLUDE OLE2INCL.
*&---------------------------------------------------------------------*
*&内表和工作区声明
*&---------------------------------------------------------------------*
DATA: it_data TYPE TABLE OF MAKT WITH HEADER LINE, "
      wa_data LIKE LINE OF it_data.                   "

DATA: workbook TYPE OLE2_OBJECT,  
      excel TYPE ole2_object,
      sheet TYPE ole2_object,
      cell TYPE ole2_object.
DATA: fname LIKE rlgrap-filename.
DATA: index TYPE i.

TABLES: MAKT.
*&---------------------------------------------------------------------*
*&选择屏幕的定义
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blk0 WITH FRAME TITLE text-001.
SELECT-OPTIONS: S_MATNR FOR MAKT-MATNR. "
SELECT-OPTIONS: S_SPRAS FOR MAKT-SPRAS . "

SELECTION-SCREEN END OF BLOCK blk0.

*&---------------------------------------------------------------------*
*&INITIALIZATION
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&选择屏幕事件
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&START-OF-SELECTION 程序开始
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM temp_excel_get USING 'ZOLE3011' ."从服务器下载模板
*   下载完模板后，打开模板文件，填入数据
  PERFORM frm_excel_open.

*  &---------------------------------------------------------------------*
*取数放到it_data
  PERFORM frm_get_data.

*将取出的数放入excel
  LOOP AT it_data INTO wa_data.
    index = sy-tabix + 2."从第三行开始写入数据
*
    PERFORM excel_row_insert USING sheet index 1.
    PERFORM fill_range USING index 1 wa_data-MANDT.
    PERFORM fill_range USING index 2 wa_data-MATNR.
    PERFORM fill_range USING index 3 wa_data-SPRAS.
    PERFORM fill_range USING index 4 wa_data-MAKTX.
    PERFORM fill_range USING index 5 wa_data-MAKTG.
  ENDLOOP.


*设置EXCEL中所插入的数据行边框线格式为黑色有边框

*  bod = tab.
*  CONDENSE bod NO-GAPS.
*  CONCATENATE 'A6:F' bod INTO bod.
*
*  PERFORM borderrange USING excel bod.

  PERFORM sub_excel_save."保存excel数据

*  PERFORM frm_data_display.
**&---------------------------------------------------------------------*
**& END-OF-SELECTION 程序结束
**&---------------------------------------------------------------------*
*
*&---------------------------------------------------------------------*
*&子程序部分
*&---------------------------------------------------------------------*




*下载EXCEL模板FORM
*----------------------------------------------------------------------*
*      -->VALUE(templat)    上传的excel模板名
*      <--VALUE(ls_destination)    返回excel文件模板对象
*      
*----------------------------------------------------------------------*
FORM  temp_excel_get USING template TYPE any.
  DATA:  lo_objdata LIKE wwwdatatab,
         lo_mime LIKE w3mime,
         lc_filename  TYPE string VALUE 'ole',"默认名
         lc_fullpath  TYPE string ,  "C:\Users\yang\Desktop\文件名
         lc_path      TYPE  string , "C:\Users\yang\Desktop\   不包括文件名
         ls_destination LIKE rlgrap-filename,
         ls_objnam TYPE string,
         li_rc LIKE sy-subrc,
         ls_errtxt TYPE string.
  DATA:p_objid TYPE wwwdatatab-objid,
       p_dest LIKE sapb-sappfad.
*  p_objid = 'ZOLE3011'. "此处为EXCEL模板名称
   p_objid = template.
  CONCATENATE lc_filename '_' SY-DATUM '_' SY-UZEIT 
              INTO lc_filename.  "给模板命名
  CALL METHOD cl_gui_frontend_services=>file_save_dialog "调用保存对话框
    EXPORTING
      default_extension    = 'XLS'
      default_file_name    = lc_filename
    CHANGING
      filename             = lc_filename
      path                 = lc_path
      fullpath             = lc_fullpath
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  IF lc_fullpath = ''.
    MESSAGE  '不能打开excel' TYPE 'E'.
  ENDIF.
  IF sy-subrc = 0.
    p_dest = lc_fullpath.
*    concatenate p_objid '.XLS' into ls_objnam.
    CONDENSE ls_objnam NO-GAPS.
    SELECT SINGLE relid objid FROM wwwdata INTO CORRESPONDING FIELDS OF lo_objdata
           WHERE srtf2 = 0 AND relid = 'MI' AND objid = p_objid.

*检查表wwwdata中是否存在所指定的模板文件
    IF sy-subrc NE 0 OR lo_objdata-objid EQ space."如果不存在，则给出错误提示
      CONCATENATE '模板文件' ls_objnam '不存在' INTO ls_errtxt.
      MESSAGE ls_errtxt TYPE 'I'.
    ENDIF.
    ls_destination = p_dest. "保存路径

*如果存在，调用DOWNLOAD_WEB_OBJECT 函数下载模板到路径下
    CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
      EXPORTING
        key         = lo_objdata
        destination = ls_destination
      IMPORTING
        rc          = li_rc.
    IF li_rc NE 0.
      CONCATENATE '模板文件：' ls_objnam '下载失败' INTO ls_errtxt.
      MESSAGE ls_errtxt TYPE 'E'.
    ENDIF.
      fname = ls_destination.  "fname 全局
  ENDIF.
ENDFORM.                    "fm_excel



*&---------------------------------------------------------------------*
*&      Form  FRM_EXCEL_OPEN
*&---------------------------------------------------------------------*
*       打开excel
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FRM_EXCEL_OPEN .
  CLEAR: workbook,excel,sheet,cell,index.
  CREATE OBJECT excel 'EXCEL.APPLICATION'.  "Create EXCEL OBJECT
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.
  SET PROPERTY OF excel 'Visible' = 1.  "1/0 是否立即显示EXCEL

  CALL METHOD OF
      excel
      'Workbooks' = workbook.

  CALL METHOD OF
      workbook
      'Open'

    EXPORTING
      #1       = fname."打开上面下载路径下的excel文件

  CALL METHOD OF
      excel 'Sheets' = sheet
    EXPORTING
      #1       = 1.

  CALL METHOD OF
      sheet 'Select'.

  CALL METHOD OF sheet 'ACTIVATE'. "sheet 激活

*  SET PROPERTY OF sheet 'NAME' = sheetname. "设定sheet名称
  SET PROPERTY OF sheet 'NAME' = 'SHEET1'.

ENDFORM.                    " FRM_EXCEL_OPEN




*&---------------------------------------------------------------------*
*& 向excel中的指定行插入N行
*&---------------------------------------------------------------------*
FORM excel_row_insert USING lcobj_sheet
                            lc_row
                            lc_count.
  DATA lc_range TYPE ole2_object.
  DATA h_borders  TYPE ole2_object.
  DO lc_count TIMES.
    CALL METHOD OF
        lcobj_sheet
        'Rows'      = lc_range
      EXPORTING
        #1          = 6.
    CALL METHOD OF lc_range 'Copy'.  "COPY第6行插入一个新行
    CALL METHOD OF
        lcobj_sheet
        'Rows'      = lc_range
      EXPORTING
        #1          = lc_row.
    CALL METHOD OF
        lc_range
        'Insert'.
    CALL METHOD OF lc_range 'ClearContents'. "是否需要清空Cell
  ENDDO.
ENDFORM.                    "excel_row_insert

*&---------------------------------------------------------------------*
*&      Form  fill_range
*&---------------------------------------------------------------------*
*       text  填充EXCEL 单元格
*----------------------------------------------------------------------*
*      -->VALUE(F_ROW)    text
*      -->VALUE(F_COL)    text
*      -->VALUE(F_VALUE)  text
*----------------------------------------------------------------------*
FORM fill_range USING value(f_row)
                      value(f_col)
                      value(f_value).
  DATA:
    row TYPE i,
    col TYPE i.
  row = f_row.
  col = f_col.
  CALL METHOD OF
      excel
      'CELLS' = cell
    EXPORTING
      #1      = row
      #2      = col.
  SET PROPERTY OF cell 'VALUE' = f_value.
ENDFORM.                    "fill_range

*&---------------------------------------------------------------------*
*&      Form  borderrange
*&---------------------------------------------------------------------*
*       text：设置EXCEL中所插入的数据行边框线格式

*----------------------------------------------------------------------*
*      -->LCOBJ_EXCEL  text
*      -->RANGE        text
*----------------------------------------------------------------------*
FORM borderrange USING lcobj_excel
                       range .
  DATA: lc_cell TYPE ole2_object ,
        lc_borders TYPE ole2_object .
  CALL METHOD OF
      lcobj_excel
      'RANGE'     = lc_cell
    EXPORTING
      #1          = range.
  DO 4 TIMES .
    CALL METHOD OF
        lc_cell
        'BORDERS' = lc_borders
      EXPORTING
        #1        = sy-index.
    SET PROPERTY OF lc_borders 'LineStyle' = '1'.
    SET PROPERTY OF lc_borders 'WEIGHT' = 2.                "4=max
    SET PROPERTY OF lc_borders 'ColorIndex' = '1'.
  ENDDO.
  FREE OBJECT lc_borders.
  FREE OBJECT lc_cell.
ENDFORM.                    "borderrange
*&---------------------------------------------------------------------*
*&      Form  FRM_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FRM_GET_DATA .
  CLEAR: it_data, wa_data.
  SELECT *
    FROM MAKT UP TO 5 ROWS
    INTO CORRESPONDING FIELDS OF TABLE it_data
    WHERE MAKT~MATNR IN s_matnr
    AND MAKT~spras IN S_SPRAS.
ENDFORM.                    " FRM_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  sub_excel_save
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM sub_excel_save.
  GET PROPERTY OF excel 'ActiveSheet' = sheet. "获取活动SHEET
  FREE OBJECT sheet.
  FREE OBJECT workbook.

  GET PROPERTY OF excel 'ActiveWorkbook' = workbook.
  CALL METHOD OF
      workbook
      'SAVE'.

  SET PROPERTY OF excel 'Visible' = 1.  "是否显示EXCEL 此处显示不退出

* SET PROPERTY OF excel 'Visible' = 1.

*  CALL METHOD OF workbook 'CLOSE'.
*  CALL METHOD OF excel 'QUIT'. 注释部分为不显示直接退出

  FREE OBJECT sheet.
  FREE OBJECT workbook.
  FREE OBJECT excel.
ENDFORM.                    "save_book