REPORT ZFST02.
INCLUDE ZFST02_TOP.
INCLUDE ZFST02_SCREEN.
INCLUDE ZFST02_FORM.
INCLUDE ZFST02_FRM_DISPLAY_DATAF01.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_SEASON.
PERFORM FRM_INIT_DATA.
PERFORM FRM_GET_DATA.

END-OF-SELECTION.
PERFORM FRM_DISPLAY_DATA.