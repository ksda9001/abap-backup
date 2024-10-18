TABLES: mara,
    zmmt_mat.

DATA: gt_data2 TYPE TABLE OF zmmr810log,
    gs_data2 TYPE zmm810log.

FIELD-SYMBOLS <fs_data2> TYPE zmm810log.

DATA: stmp_total TYPE string.

DATA: gt_fieldcat TYPE lvc_t_fcat,
gs_fieldcat TYPE lvc_s_fcat,
gs_layout TYPE lvc_s_layo.

FIELD-SYMBOLS <fs_fieldcat> TYPE lvc_s_fcat.

TYPES: BEGIN OF ty_data.
TYPES: check.
INCLUDE STRUCTURE zmmt00810.
TYPES: END OF ty_data.

DATA: gt_data TYPE TABLE OF ty_data,
gt_data0 TYPE SORTED TABLE OF ty_data WITH NON-UNIQUE KEY matnr,
gs_data TYPE ty_data,
gs_save TYPE zmmt00810.

FIELD-SYMBOLS <fs> TYPE ty_data.

DATA: lt_events TYPE slis_t_event,
ls_events TYPE slis_alv_event,
gr_grid TYPE REF TO cl_gui_alv_grid,
gs_stbl TYPE lvc_s_stbl.
