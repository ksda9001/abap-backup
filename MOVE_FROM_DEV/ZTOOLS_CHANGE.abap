REPORT ZTOOLS_CHANGE.
DATA: BEGIN OF ITAB OCCURS 0,
LINE(200),
END OF ITAB.
PARAMETERS PROGNAME(120) TYPE C.
READ REPORT PROGNAME INTO ITAB.
EDITOR-CALL FOR ITAB.
INSERT REPORT PROGNAME FROM ITAB.