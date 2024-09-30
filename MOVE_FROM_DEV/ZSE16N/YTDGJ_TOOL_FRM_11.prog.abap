*&---------------------------------------------------------------------*
*& Report YTDGJ_TOOL_FRM_11
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ytdgj_tool_frm_11.
INCLUDE ytdgj_tool_frm_11_top.
INCLUDE ytdgj_tool_frm_11_screen.
INCLUDE ytdgj_tool_frm_11_form.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_type.
  PERFORM p_set_selection.

END-OF-SELECTION.
  PERFORM process.