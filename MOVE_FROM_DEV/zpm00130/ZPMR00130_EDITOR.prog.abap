FORM edit USING data_text TYPE string p_rs_selfield_tabindex
p_rs_selfield_fieldname.

  REFRESH m1.
  line = data_text.
  APPEND line TO m1.

  CALL SCREEN 100.
  IF sy-subrc = 0.
    CALL METHOD editor->get_text_as_r3table
    IMPORTING
    table = m1.

    DATA stext TYPE string.

    LOOP AT m1 INTO line.
      CONCATENATE stext line INTO stext.
    ENDLOOP.

    IF p_sel1 = 'X'.
      READ TABLE gt_alv_data ASSIGNING <fs_data> INDEX p_rs_selfield_tabiondex.
      IF sy-subrc = 0.
        ASSIGN COMPONENT p_rs_selfieldname OF STRUCTURE <fs_data> TO <dyn_field>.
        <dyn_field> = strxt.
      ENDIF.

    ELSEIF p_sel2 = 'X'.
      READ TABLE gt_alv_data2 ASSIGNING <fs_data2> INDEX p_rs_selfield_tabindex.
      IF sy-subrc = 0.
        ASSIGN COMPONENT p_rs_selfield_fieldname OF STRUCTURE <fs_data2> TO <dyn_field>.
        <dyn_field> = stext.
      ENDIF.

    ENDIF.
  ENDIF.

ENDFORM.

MODULE status_0100 OUTPUT.
SET PF-STATUS 'STATUS2'.
IF INIT IS INITIAL.
  INIT = 'X'.
  CREATE OBJECT: CONTAINER EXPORTING CONTAINER_NAME = 'P1'.
  CREATE OBJECT editor
  EXPORTING
  PARENT = CONTAINER
  WORDWRAP_MODE = CL_GUI_TEXTEDIT=>WORDWRAP_AT_FIXED_POSITION
  WORDWRAP_POSITION = 256
  WRODWRAP_TO_LINEBREAK_MODE = CL_GUI_TEXTEDIT=>TRUE.
ENDIF.
CALL METHOD EDITOR->SET_TEXT_AS_R3TABLE
EXPORTING
TABLE = M1.
ENDMODULE.

MODULE USER_COMMAND_0100 INPUT.
SAVE_OK = OK_CODE.
CLEAR OK_CODE.
CASE SAVE_OK.
  WHEN 'SAVE'.
    LEAVE TO SCREEN 0.
  WHEN 'EXIT'.
  SY-SUBRC = 4. 
  LEAVE TO SCREEN 0.
ENDCASE.
ENDMODULE.