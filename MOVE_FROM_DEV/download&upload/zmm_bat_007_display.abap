FORM FRM_DISPLAY.
    perform FRM_LAYOUT.
    perform FRM_FIELDCAT.
    perform FRM_OUTPUT.
ENDFORM.

FORM FRM_LAYOUT.
    gs_layout-zebra = 'X'.
    gs_layout-cwidth_opt = 'X'.
    gs_layout-box_fname = 'CHECK'.
    gs_layout-sel_mode = 'A'.
ENDFORM.

DEFINE INIT_FIELDCAT.
    CLEAR GS_FIELDCAT.
    
END-OF-DEFINITION.

FORM FRM_FIELDCAT.

ENDFORM.

FORM FRM_OUTPUT.

ENDFORM.