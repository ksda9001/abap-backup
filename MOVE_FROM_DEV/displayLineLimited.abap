CONTROLS: TC001 TYPE TABLEVIEW USING SCREEN 0400.

MODULE TC001_CHANGE_TC_ATTR OUTPUT.
DESCRIBE TABLE GIT_ITEMS LINES TC001-LINES.
TC001-LINES = 100. "限制100行输出
ENDMODULE.