FORM CREATE_FIELD TABLES T_FCAT TYPE SLIS_T_FIELDCAT_ALV
USING
    U_FIELDNAME
    U_SELTEXT_L
    U_OUTPUTLEN.

    WT_FIELDCAT-FIELDNAME = U_FIELDNAME.
    WT_FIELDCAT-SELTEXT_L = U_SELTEXT_L.
    WT_FIELDCAT-OUTPUTLEN = U_OUTPUTLEN.
    APPEND WT_FIELDCAT TO LT_FIELDCAT.
    CLEAR WT_FIELDCAT.
ENDFORM.

FORM FRM_DISPLAY_DATA.
    LS_LAYOUT-ZEBRA = 'X'.
    LS_LAYOUT-DETAIL_POPUP = 'X'.
    LS_LAYOUT-DETAIL_TITLEBAR = '详细信息'.
    LS_LAYOUT-F2CODE = '&ETA'.
    LS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

    PERFORM CREATE_FIELD TABLES LT_FIELDCAT
    USING:
    'BUKRS' '公司代码' '4',
    'ANLN1' '资产编号' '12',
    'TXT50' '资产名称' '25',
    'ANLKL' '资产分类' '8',
    'AFABE' '折旧范围' '2',
    'NDJAR' '现使用年度' '2',
    'NDURJ' '原折旧年代' '3',
    'ANLC' '当月资产原值' '14',
    'GJAHR' '折旧年度' '4',
    'PERAF' '折旧期间' '3',
    'KOSTL' '成本中心' '10',
    'KTEXT' '成本中心名称' '20',
    'HKONT' '折旧科目' '10',
    'TXT50II' '科目名称' '25',
    'NAFAZ' '正常折旧金额' '13',
    'SAFAG' '特别记账金额' '13',
    'AAFAG' '计划外折旧' '13',
    'DYZJJE' '当月折旧金额' '13',
    'YSSJDYZJJE' '原始数据当月折旧金额' '13',
    'CHAZHI' '当月折旧金额-原折旧年限当月折旧金额' '13'.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
    I_CALLBACK_pROGRAM = SY-REPID
    IT_FIELDCAT = LT_FIELDCAT[]
    
ENDFORM.