FUNCTION zfm_http_send_data.
*用于外部接口连接

*本地接口
*IMPORTING
*VALUE(I_INPUT) TYPE STRING
*REFERENCE(I_ZJKBM) TYPE ZJKBM
*REFERENCE(I_SYS) TYPE ZSYS
*EXPORTING
*VALUE(RETURN) TYPE BAPIRET2
*VALUE(LS_OUTPUT) TYPE STRING

DATA: LO_HTTP_CLIENT TYPE REF TO IF_HTTP_CLIENT,
LV_SERVICE TYPE STRING,
LV_RESULT TYPE STRING,
LO_IXML TYPE REF TO IF_IXML,
LO_STREAMFACTORY TYPE REF TO IF_IXML_STREAM_FACTORY,
LO_ISTREAM TYPE REF TO IF_IXML_ISTREAM,
LO_DOCUMENT TYPE REF TO IF_IXML_DOCUMENT,
LO_PARSER TYPE REF TO IF_IXML_PARSER.

DATA: L_DATA TYPE STRING,
L_TIME TYPE STRING.

DATA: P_CODE TYPE I,
P_REASON TYPE STRING,
I_SYSUBRC TYPE SY-SUBRC,
L_ERROR TYPE STRING.

DATA LS_TAB TYPE ZTAIPLOG.
DATA ZTREXJSON TYPE REF TO /UI2/CL_JSON.

SELECT SINGLE ZURL INTO LV_SERVICE FROM ZWMS_001 WHERE ZJKBM = I_ZJKBM
AND ZFLAG = 'X'.

TRY.
    CALL METHOD CL_SYSTEM_UUID => IF_SYSTEM_UUID_STATIC~CREATE_UUID_C32
    RECEIVING
    UUID = LS_TAB-UUID
    CATCH CX_UUID_ERROR.
ENDTRY.

IF LS_TAB-UUID IS NOT INITIAL.
    LS_TAB-ZSYS = I_SYS.
    LS_TAB-ZDATE = SY-DATUM.
    LS_TAB-TIME = SY-UZEIT.
    LS_TAB-I_TIP1 = I_INPUT.
ENDIF.

IF LV_SERVICE IS INITIAL.
    RETURN-TYPE = 'E'.
    RETURN-MESSAGE = '请启用接口并维护接口地址'.
    RETURN.
ENDIF.

*创建客户端请求
cl_http_client=>create_by_url(
EXPORTING
URL = LV_SERVICE
IMPORTING
CLIENT = LO_HTTP_CLIENT
EXCEPTIONS
ARGUMENT_NOT_FOUND = 1
PLUGIN_NOT_ACTIVE = 2
INTERNAL_ERROR = 3
OTHERS = 4
).
IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO WITH SY-MSGV1
    INTO RETURN-MESSAGE.
    RETURN-TYPE = 'E'.
    RETURN.
ENDIF.

LO_HTTP_CLIENT->PROPERTYTYPE_LOGON_POPUP = LO_HTTP_CLIENT->CO_DISABLED.
*设定传输请求内容及编码格式
CALL METHOD LO_HTTP_CLIENT->REQUEST->SET_HEADER_FIELD
EXPORTING
NAME = 'Content-Type'
value = 'application/JSON; charset = utf-8'.

*设置调用方法
CALL METHOD LO_HTTP_CLIENT->REQUEST->SET_METHOD('POST').
DATA LV_JSON TYPE STRING.
DATA LEN TYPE I.

LV_JSON = I_INPUT.
LEN = STRLEN( LV_JSON ).

*设置输入字符串
CALL METHOD LO_HTTP_CLIENT->REQUEST->SET_CDATA
EXPORTING
DATA = LV_JSON
OFFSET = 0
LENGTH = LEN.

*发送数据
LO_HTTP_CLIENT->SEND(
EXCEPTIONS
    HTTP_COMMUNICATION_FAILURE = 1
    HTTP_INVALID_STATE = 2
    HTTP_PROCESSING_FAILED = 3
    HTTP_INVALID_TIMEOUT = 4
    OTHERS = 5
).

IF SY-SUBRC NE 0.
*操作失败，获取失败原因
    LO_HTTP_CLIENT->GET_LAST_ERROR( IMPORTING MESSAGE = L_ERROR ).
    RETURN-MESSAGE = L_ERROR.
    RETURN-TYPE = 'E'.
    RETURN.
ENDIF.
*接收返回字符串
LO_HTTP_CLIENT->receive(
    EXCEPTIONS
    HTTP_COMMUNICATION_FAILURE = 1
    HTTP_INVALID_STATE = 2
    HTTP_PROCESSING_FAILED = 3
).
*提取返回字符串
IF sy-SUBRC EQ 0.
    CLEAR LV_RESULT.
    LV_RESULT = LO_HTTP_CLIENT->RESPONSE->GET_CDATA().
    CALL METHOD LO_HTTP_CLIENT->RESPONSE->GET_STATUS
    IMPORTING
    CODE = P_CODE
    REASON = P_REASON.
    "输出返回报文
    IF P_CODE NE '200'.
        RETURN-TYPE = 'E'.
        RETURN-MESSAGE = |错误码 ：{ p_code }, 错误原因：{ lv_result },请联系开发查看！|.
    ELSE.
        RETURN-TYPE = 'S'.
    ENDIF.
    LS_OUTPUT = LV_RESULT.
    LS_TAB-O_TIP2 = LV_RESULT.
*关闭服务
    IF LO_HTTP_CLIENT IS NOT INITIAL.
        LO_HTTP_CLIENT->CLOSE().
    ENDIF.
ELSE.
    CALL METHOD LO_HTTP_CLIENT->GET_LAST_ERROR
    IMPORTING
    CODE = L_SYSUBRC
    MESSAGE = L_ERROR.

    RETURN-TYPE = 'E'.
    RETURN-MESSAGE = |接口连接通讯错误：{l_error}|.
    RETURN.
ENDIF.
*记录日志
IF LS_TAB IS NOT INITIAL.
    MODIFY ZTAIPLOG FROM LS_TAB.
    IF SY-SUBRC = 0.
        COMMIT WORK AND WAIT.
    ELSE.
        ROLLBACK WORK.
    ENDIF.
ENDIF.
ENDFUNCTION.