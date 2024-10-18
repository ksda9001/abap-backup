FORM save_data.
  IF gt_data IS NOT INITIAL.
    LOOP AT gt_data ASSIGNING <fs> WHERE check = 'X'.
      CLEAR gs_save.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
            EXPORTING
            input = <fs>-matnr
            IMPORTING
            output = <fs>-matnr
            EXCEPTIONS
            length_error = 1
            OTHERS = 2.

      MOVE-CORRESPONDING <fs> TO gs_save.
      MODIFY zmmt00810 FROM gs_save.
    ENDLOOP.
    IF sy-subrc = 0.
      MESSAGE '保存成功！' TYPE 'S'.
    ELSE.
      MESSAGE '请至少选中一条数据！' TYPE 'E'.
    ENDIF.
  ENDIF.
ENDFORM.

FORM auto_save_data.
  IF gt_data IS NOT INITIAL.
    LOOP AT gt_data ASSIGNING <fs>.
      CLEAR gs_save.
      MOVE-CORRESPONDING <fs> TO gs_save.
      MODIFY zmmt00810 FROM gs_save.
    ENDLOOP.
  ENDIF.
ENDFORM.

CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS:
    handle_data_changed FOR EVENT data_changed_finished OF cl_gui_alv_grid
    IMPORTING e_modified et_good_cells.
ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.
  METHOD handle_data_changed.
    PERFORM handle_data_changed USING et_good_cells.
    IF e_modified = 'X'.
      gs_stbl-row = 'X'.
      gs_stbl-col = 'X'.

      CALL METHOD gr_grid->refresh_table_display
            EXPORTING
            is_stable = gs_stbl.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

FORM frm_register_events USING e_grid TYPE slis_data_caller_exit.
  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
    e_grid = gr_grid.

  DATA: gr_event_handler TYPE REF TO lcl_event_handler.
  CREATE OBJECT gr_event_handler.

  CALL METHOD gr_grid->register_edit_event
    EXPORTING
    i_event_id = cl_gui_alv_grid=>mc_evt_enter
    EXCEPTIONS
    error = 1
    OTHERS = 2.

  SET HANDLER gr_event_handler->handle_data_changed FOR gr_grid.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.

FORM add_lines.
  INSERT INITIAL LINE INTO gt_data INDEX 1.
ENDFORM.

FORM handle_data_changed USING et_good_cells TYPE lvc_t_modi.
  FIELD-SYMBOLS <fs_cell> TYPE lvc_s_modi.
  DATA gsmat TYPE zmmt_mat.
  LOOP AT et_good_cells ASSIGNING <fs_cell>.
    IF <fs_cell>-fieldname = 'MATNR'.
      READ TABLE gt_data ASSIGNING <fs> INDEX <fs_cell>-row_id.
      IF sy-subrc = 0.
        CLEAR gs_save.

        SELECT SINGLE
            matnr
            maktx
            zspecname
            zquality
            zbh
            zzlwtlx
            zzlwtmc
            zwtgs
            zrwly
            charg
            zlbmc
            zdlmc
            zzlmc
            zcswthj
            zfxwthj
            zfxwtdw
            zwtzrdw
            zgysmc
            zsyb
            zqyxz
            zgysbm
            zgysjc
            zzlwtcgit
            zyy1
            zyy2
            zyy3
            zyy4
            zyy5
            zyy6
            zyy7
            zqt
            zbz
            FROM
            zmmt00810
            INTO CORRESPONDING FIELDS OF gs_save
            WHERE matnr = <fs_cell>-value.

        MOVE-CORRESPONDING gs_save TO <fs>.

        IF <fs>-maktx IS INITIAL.
          CLEAR gsmat.

          SELECT SINGLE
            a~matnr,
            b~maktx,
            b~zspecname,
            b~zquality,
            b~zlbmc,
            b~zdlmc,
            b~zzlmc
            INTO CORRESPONDING FIELDS OF @gsmat
            FROM mara AS a
            LEFT JOIN zmmt_mat AS b ON b~matnr = a~matnr
            WHERE a~matnr = @<fs_cell>-value.

          MOVE-CORRESPONDING gsmat TO <fs>.
            
        ENDIF.

        PERFORM auto_save_data.
        PERFORM append_line.

      ENDIF.
        
    ENDIF.
  ENDLOOP.

  PERFORM nctalog.
ENDFORM.

FORM append_line.
  APPEND INITIAL LINE TO gt_data.
ENDFORM.

FORM delete_line.
  DELETE gt_data WHERE (' CHECK = "X" ').
ENDFORM.

FORM upload_data.

ENDFORM.

FORM ncatalog.
  CALL METHOD gr_grid->get_frontend_fieldcatalog
    IMPORTING
    et_fieldcatalog = gt_fieldcat.

  LOOP AT gt_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).
    CASE <fs_fcat>-fieldname.
      WHEN 'CHECK'.
        <fs_fcat>-no_out = 'X'.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.
ENDFORM.