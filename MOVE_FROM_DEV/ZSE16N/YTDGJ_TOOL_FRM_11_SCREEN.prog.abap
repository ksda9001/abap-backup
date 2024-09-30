*&---------------------------------------------------------------------*
*& 包含               YTDGJ_TOOL_FRM_11_SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS p_name TYPE rsrd1-tbma_val OBLIGATORY.
PARAMETERS p_line TYPE char10.
PARAMETERS p_colsy1 TYPE char15.
PARAMETERS p_colsy2 TYPE char15.
PARAMETERS p_colsy3 TYPE char15.
PARAMETERS p_colsy4 TYPE char15.
PARAMETERS p_codst TYPE zcodst.
PARAMETERS p_type AS LISTBOX VISIBLE LENGTH 12 OBLIGATORY DEFAULT '1'.
SELECTION-SCREEN END OF BLOCK b1.