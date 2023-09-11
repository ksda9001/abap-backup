****** COMMAND OF COLLECT ******
*** 30082023 ***

REPORT Collect.
DATA: BEGIN OF w_test.
key TYPE string, "用于统计V1 V2数量
v1 TYPE i,
v2 TYPE i,
END OF w_test.

DATA: t_data like w_test occurs 0 with header line, "定义数据内表
t_data_1 like w_test occurs 0 with header line,
t_test like w_test occurs 0 with header line.

DO 8 times.
IF SY-INDEX < 3.
    t_data-KEY = 'A'.
    T_DATA-V1 = SY-INDEX.
    T_DATA-V2 = SY-INDEX + 1.
ELSEIF SY-INDEX < 6.
    T_DATA-KEY = 'B'.
    T_DATA-V1 = SY-INDEX.
    T_DATA-V2 = SY-INDEX + 1.
ELSE.
    T_DATA-KEY = 'C'.
    T_DATA-V1 = SY-INDEX - 1.
    T_DATA-V2 = SY-INDEX - 2.
ENDIF.
APPEND T_DATA.
ENDDO.

t_data_1[] = t_data[].

LOOP AT t_data.
    Collect t_data into t_test. "按关键列统计值
ENDLOOP.

***处理内表
LOOP AT T_DATA.
    Collect T_DATA INTO t_test.
ENDLOOP.

***打印输出内容
WRITE: SY-ULINE.
WRITE: '内表数据'.
LOOP AT T_DATA.
    WRITE: / '',T_DATA-KEY,T_DATA-V1,T_DATA-V2.
ENDLOOP.
WRITE: SY-ULINE.

WRITE: SY-ULINE.
WRITE: 'COLLECT后的数据'.
LOOP AT t_test.
    WRITE: / '',t_test-KEY,t_test-V1,t_test-V2.
ENDLOOP.
WRITE: SY-ULINE.