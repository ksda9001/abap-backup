*&---------------------------------------------------------------------*
*& 包含               YTDGJ_TOOL_FRM_11_TOP
*&---------------------------------------------------------------------*
DATA: lr_struc   TYPE REF TO cl_abap_structdescr,
      lr_data    TYPE REF TO cl_abap_datadescr,
      lr_table   TYPE REF TO cl_abap_tabledescr,
      dyn_table  TYPE REF TO data,
      dyn_table2 TYPE REF TO data,
      dyn_wa     TYPE REF TO data.

DATA: init,
      container TYPE REF TO cl_gui_custom_container,
      editor    TYPE REF TO cl_gui_textedit.

DATA: m1(256)   TYPE c OCCURS 0,
      line(256) TYPE c.

DATA: BEGIN OF stmp OCCURS 0,
        i_tip1(300),
      END OF stmp.

DATA: l_tabname TYPE tabname.

TYPES: line_type TYPE c LENGTH 300.
DATA: column_syntax TYPE TABLE OF line_type,
      cond_syntax   TYPE TABLE OF line_type.

FIELD-SYMBOLS: <fs_line_type> TYPE line_type,
               <dyn_table>    TYPE STANDARD TABLE,
               <dyn_table2>   TYPE STANDARD TABLE,
               <dyn>          TYPE any,
               <fs_alv>       TYPE any.

DATA: gt_fieldcat TYPE lvc_t_fcat,
      gs_fieldcat TYPE lvc_s_fcat,
      gs_layout   TYPE lvc_s_layo.

DATA: ok_code TYPE sy-ucomm,
      save_ok TYPE sy-ucomm.

FIELD-SYMBOLS <dyn_field> TYPE any.

DATA: r_tabdescr TYPE REF TO cl_abap_structdescr,
      wa_field   TYPE dfies,
      t_dfies    TYPE ddfields.
TYPES: zcodst TYPE char300.