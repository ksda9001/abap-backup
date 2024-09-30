*&---------------------------------------------------------------------*
*& 包含               YTDGJ_TOOL_FRM_11_FORM
*&---------------------------------------------------------------------*
FORM process.
    l_tabname = p_name.
    lr_struc ?= cl_abap_typedescr=>describe_by_name( l_tabname ).
    lr_table ?= cl_abap_tabledescr=>create( p_line_type = lr_struc ).
  
    CALL METHOD cl_salv_data_descr=>read_structdescr
      EXPORTING
        r_structdescr = lr_struc
      RECEIVING
        t_dfies       = t_dfies.
  
    CREATE DATA dyn_wa TYPE HANDLE lr_struc.
    CREATE DATA dyn_table2 TYPE HANDLE lr_table.
  
    LOOP AT t_dfies INTO wa_field.
      CLEAR gs_fieldcat.
      MOVE-CORRESPONDING wa_field TO gs_fieldcat.
      IF gs_fieldcat-inttype = 'P'. "更正SAP类型为P时的长度BUG
        gs_fieldcat-intlen = '23'.
      ENDIF.
      APPEND gs_fieldcat TO gt_fieldcat.
    ENDLOOP.
  
    CLEAR gs_fieldcat.
    gs_fieldcat-fieldname = 'CHECK'.
    APPEND gs_fieldcat TO gt_fieldcat.
  
    CALL METHOD cl_alv_table_create=>create_dynamic_table
      EXPORTING
        it_fieldcatalog = gt_fieldcat
      IMPORTING
        ep_table        = dyn_table.
  
    ASSIGN dyn_table->* TO <dyn_table>.
    ASSIGN dyn_table2->* TO <dyn_table2>.
    ASSIGN dyn_wa->* TO <dyn>.
  
    CLEAR gs_fieldcat.
    REFRESH gt_fieldcat.
  
    gs_layout-zebra = 'X'.
    gs_layout-cwidth_opt = 'X'.
    gs_layout-box_fname = 'CHECK'.
    gs_layout-sel_mode = 'A'.
  
    IF p_colsy1 IS INITIAL AND p_colsy2 IS INITIAL AND p_colsy3 IS INITIAL AND p_colsy4 IS INITIAL.
      IF p_codst IS NOT INITIAL.
        REFRESH cond_syntax.
        APPEND p_codst TO cond_syntax.
  
        SELECT * INTO CORRESPONDING FIELDS OF TABLE <dyn_table>
          UP TO p_line ROWS
          FROM (l_tabname)
          WHERE (cond_syntax).
  
      ELSE.
  
        SELECT * INTO CORRESPONDING FIELDS OF TABLE <dyn_table>
          UP TO p_line ROWS
          FROM (l_tabname).
  
      ENDIF.
  
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
        EXPORTING
          i_grid_title             = '单元格双击查看详情'
          i_structure_name         = l_tabname
          is_layout_lvc            = gs_layout
          i_callback_program       = sy-repid
          i_callback_user_command  = 'ALV_COMMAND'
          i_callback_pf_status_set = 'ALV_STATUS'
        TABLES
          t_outtab                 = <dyn_table>
        EXCEPTIONS
          program_error            = 1
          OTHERS                   = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
  
    ELSE.
      REFRESH column_syntax.
      APPEND p_colsy1 TO column_syntax.
      APPEND p_colsy2 TO column_syntax.
      APPEND p_colsy3 TO column_syntax.
      APPEND p_colsy4 TO column_syntax.
  
      IF p_codst IS NOT INITIAL.
        REFRESH cond_syntax.
        APPEND p_codst TO cond_syntax.
        SELECT (column_syntax) INTO CORRESPONDING FIELDS OF TABLE <dyn_table>
          UP TO p_line ROWS
          FROM (l_tabname)
          WHERE (cond_syntax).
  
      ELSE.
  
        SELECT (column_syntax) INTO CORRESPONDING FIELDS OF TABLE <dyn_table>
          UP TO p_line ROWS
          FROM (l_tabname).
  
      ENDIF.
  
  
      REFRESH gt_fieldcat.
      DEFINE init_fieldcat.
        CLEAR gs_fieldcat.
        gs_fieldcat-fieldname = &1.
        gs_fieldcat-coltext = &1.
        APPEND gs_fieldcat TO gt_fieldcat.
      END-OF-DEFINITION.
  
      LOOP AT column_syntax ASSIGNING <fs_line_type>.
        IF <fs_line_type> IS NOT INITIAL.
          init_fieldcat <fs_line_type>.
        ENDIF.
      ENDLOOP.
  
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
        EXPORTING
          i_callback_program       = sy-repid
          i_callback_pf_status_set = 'ALV_STATUS'
          i_callback_user_command  = 'ALV_COMMAND'
          i_grid_title             = '双击查看详情'
          it_fieldcat_lvc          = gt_fieldcat
          is_layout_lvc            = gs_fieldcat
        TABLES
          t_outtab                 = <dyn_table>
        EXCEPTIONS
          program_error            = 1
          OTHERS                   = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ENDFORM.
  
  FORM alv_command USING pv_ucomm LIKE sy-ucomm
        rs_selfield TYPE slis_selfield.
  
    DATA lob_grid TYPE REF TO cl_gui_alv_grid.
  
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = lob_grid.
  
    CALL METHOD lob_grid->check_changed_data.
    rs_selfield-refresh = 'X'.
    rs_selfield-col_stable = 'X'.
    rs_selfield-row_stable = 'X'.
  
    CASE pv_ucomm.
      WHEN '&IC1'.
        IF rs_selfield-fieldname IS NOT INITIAL AND rs_selfield-tabindex IS NOT INITIAL.
          PERFORM data_edit USING rs_selfield-tabindex
                rs_selfield-fieldname pv_ucomm.
        ELSE.
          MESSAGE '请选中需要更改的单元格!' TYPE 'E'.
        ENDIF.
  
      WHEN '&ZEDIT'.
        IF rs_selfield-fieldname IS NOT INITIAL AND rs_selfield-tabindex IS NOT INITIAL..
          PERFORM data_edit USING rs_selfield-tabindex
                rs_selfield-fieldname pv_ucomm.
        ELSE.
          MESSAGE '请选中需要更改的单元格!' TYPE 'E'.
        ENDIF.
  
      WHEN '&ZSAVE'.
        LOOP AT <dyn_table> ASSIGNING <fs_alv> WHERE ('CHECK = "X"').
          MOVE-CORRESPONDING <fs_alv> TO <dyn>.
          MODIFY (l_tabname) FROM <dyn>.
        ENDLOOP.
  
        IF sy-subrc = 0.
          COMMIT WORK.
          MESSAGE '保存成功!' TYPE 'S'.
        ELSE.
          IF <dyn> IS INITIAL.
            MESSAGE '请至少选中一条数据!' TYPE 'S' DISPLAY LIKE 'E'.
          ELSE.
            MESSAGE '保存失败!' TYPE 'S' DISPLAY LIKE 'E'.
            ROLLBACK WORK.
          ENDIF.
        ENDIF.
  
      WHEN '&ZEDITA'.
        CALL METHOD lob_grid->get_frontend_layout
          IMPORTING
            es_layout = gs_layout.
  
        IF gs_layout-edit = 'X'.
          gs_layout-edit = ''.
        ELSE.
          gs_layout-edit = 'X'.
        ENDIF.
  
        CALL METHOD lob_grid->set_frontend_layout
          EXPORTING
            is_layout = gs_layout.
  
      WHEN '&ZADD'.
        CALL METHOD lob_grid->get_frontend_layout
          IMPORTING
            es_layout = gs_layout.
  
        IF gs_layout-edit = ''.
          gs_layout-edit = 'X'.
        ENDIF.
  
        CALL METHOD lob_grid->set_frontend_layout
          EXPORTING
            is_layout = gs_layout.
  
        PERFORM add_line USING rs_selfield-tabindex.
  
      WHEN '&ZDELETE'.
        PERFORM delete_line.
    ENDCASE.
  
  ENDFORM.
  
  FORM alv_status USING rt_extab TYPE slis_t_extab.
    SET PF-STATUS 'STATUS1'.
  ENDFORM.
  
  FORM data_edit USING p_rs_selfield_tabindex
        p_rs_selfield_fieldname pv_ucomm.
  
    DATA: lv_field TYPE char20,
          lv_stext TYPE string.
  
    READ TABLE <dyn_table> ASSIGNING FIELD-SYMBOL(<fs_alv>) INDEX p_rs_selfield_tabindex.
    IF sy-subrc = 0.
      ASSIGN COMPONENT p_rs_selfield_fieldname OF STRUCTURE <fs_alv> TO <dyn_field>.
      lv_stext = <dyn_field>.
  
      CASE pv_ucomm.
        WHEN '&IC1'.
          PERFORM display USING lv_stext.
        WHEN '&ZEDIT'.
          PERFORM edit USING lv_stext p_rs_selfield_tabindex
                p_rs_selfield_fieldname.
      ENDCASE.
    ENDIF.
  ENDFORM.
  
  FORM p_set_selection.
    TYPES: BEGIN OF ty,
             col1 TYPE char1,
             col2 TYPE char6,
           END OF ty.
  
    DATA stab TYPE TABLE OF ty.
    stab = VALUE #(
    ( col1 = '1' col2 = '文本')
    ( col1 = '2' col2 = 'JSON')
    ( col1 = '3' col2 = 'JSON增强')
    ( col1 = '4' col2 = 'XML')
    ( col1 = '5' col2 = '数据原格式')
    ).
  
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield         = 'COL1'
        dynpprog         = sy-repid
        dynpnr           = sy-dynnr
        dynprofield      = 'XOL1'
        value_org        = 'S'
        callback_program = sy-repid
      TABLES
        value_tab        = stab
      EXCEPTIONS
        parameter_error  = 1
        no_values_found  = 2
        OTHERS           = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDFORM.
  
  FORM display USING data_text TYPE string.
    CASE p_type.
      WHEN '1'.
        cl_demo_output=>new(
        )->begin_section(
        )->write_text( data_text
        )->end_section(
        )->display( ).
      WHEN '2'.
        cl_demo_output=>new(
        )->begin_section(
        )->write_json( data_text
        )->end_section(
        )->display( ).
      WHEN '3'.
        REFRESH stmp.
        SPLIT data_text AT ',' INTO TABLE stmp.
        DATA: stmp_total TYPE string.
        DESCRIBE TABLE stmp LINES stmp_total.
        LOOP AT stmp ASSIGNING FIELD-SYMBOL(<fs>).
          IF sy-tabix = stmp_total. "最后一行不执行
            EXIT.
          ENDIF.
          CONCATENATE <fs>-i_tip1 ',' INTO <fs>-i_tip1.
        ENDLOOP.
        CALL FUNCTION 'ADA_POPUP_WITH_TABLE'
          EXPORTING
            startpos_col = 1
            startpos_row = 1
          TABLES
            valuetab     = stmp[].
      WHEN '4'.
        cl_demo_output=>new(
        )->begin_section(
        )->write_xml( data_text
        )->end_section(
        )->display( ).
      WHEN '5'.
        cl_demo_output=>new(
        )->begin_section(
        )->write_data( data_text
        )->end_section(
        )->display( ).
    ENDCASE.
  ENDFORM.
  
  FORM edit USING data_text TYPE string
        p_rs_selfield_tabindex
    p_rs_selfield_fieldname.
  
    line = data_text.
    APPEND line TO m1.
  
    CALL SCREEN 100.
    IF sy-subrc = 0.
      REFRESH m1.
  
      CALL METHOD editor->get_text_as_r3table
        IMPORTING
          table = m1.
  
      "逐行输出
      DATA stext TYPE string.
      LOOP AT m1 INTO line.
        CONCATENATE stext line INTO stext.
      ENDLOOP.
  
      READ TABLE <dyn_table> ASSIGNING <fs_alv> INDEX p_rs_selfield_tabindex.
      IF sy-subrc = 0.
        ASSIGN COMPONENT p_rs_selfield_fieldname OF STRUCTURE <fs_alv> TO <dyn_field>.
        <dyn_field> = stext.
        MOVE-CORRESPONDING <fs_alv> TO <dyn>.
        MODIFY (l_tabname) FROM <dyn>.
        CLEAR <dyn>.
      ENDIF.
    ENDIF.
  ENDFORM.
  
  MODULE user_command_0100 INPUT.
    save_ok = ok_code.
    CLEAR ok_code.
    CASE save_ok.
      WHEN 'SAVE'.
        LEAVE TO SCREEN 0.
      WHEN 'EXIT'.
        sy-subrc = 4.
        LEAVE TO SCREEN 0.
    ENDCASE.
  ENDMODULE.
  
  MODULE status_0100 OUTPUT.
    SET PF-STATUS 'STATUS2'.
    IF init IS INITIAL.
      init = 'X'.
      CREATE OBJECT: container EXPORTING container_name = 'P1'.
  
      CREATE OBJECT editor
        EXPORTING
          parent                     = container
          wordwrap_mode              = cl_gui_textedit=>wordwrap_at_fixed_position
          wordwrap_position              = 256
          wordwrap_to_linebreak_mode = cl_gui_textedit=>true.
    ENDIF.
    CALL METHOD editor->set_text_as_r3table
      EXPORTING
        table = m1.
  ENDMODULE.
  
  FORM add_line USING p_rs_selfield_tabindex.
    INSERT INITIAL LINE INTO <dyn_table> INDEX p_rs_selfield_tabindex.
  ENDFORM.
  
  FORM delete_line.
    LOOP AT <dyn_table> ASSIGNING <fs_alv> WHERE ('CHECK = "X"').
      MOVE-CORRESPONDING <fs_alv> TO <dyn>.
      APPEND <dyn> TO <dyn_table2>.
    ENDLOOP.
    IF sy-subrc <> 0.
      MESSAGE '请至少选中一条数据!' TYPE 'E'.
    ENDIF.
    DELETE <dyn_table> WHERE ('CHECK = "X"').
    DELETE (l_tabname) FROM TABLE <dyn_table2>.
    REFRESH <dyn_table2>.
  
    COMMIT WORK.
  ENDFORM.