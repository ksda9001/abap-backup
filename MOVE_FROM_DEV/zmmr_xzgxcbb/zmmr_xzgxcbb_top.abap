TABLES: ZMMT00040,
        MSEG,
        ZMMT00091,
        ZMMT_MAT,
        LFA1,
        MAKT,
        MARA.

TYPE-POOLS: SLIS.

DATA: LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE,
        WT_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
        LS_LAYOUT TYPE SLIS_LAYOUT_ALV.

DATA: I_DATA TYPE SY-DATUM.

TYPES: BEGIN OF TDATA,
    MATNR TYPE ZMMT00040-MATNR,
    MAKTX TYPE MAKT-MAKTX,
    ZSPECNAME TYPE ZMMT_MAT-ZSPECNAME,
    ZZGF TYPE ZMMT_MAT-ZZGF,
    ZMANUFACTURER TYPE ZMMT_MAT-ZMANUFACTURER,
    CHARG TYPE MSEG-CHARG,
    LGORT TYPE ZMMT00040-LGORT,
    ZHWDZ TYPE ZMMT00040-ZHWDZ,
    MEINS TYPE MARA-MEINS,
    ZHGZH TYPE ZMMT00093-ZHGZH,
    BWART TYPE MSEG-BWART,
    ZSQBM TYPE MSEG-ZSQBM,
    LIFNR TYPE MSEG-LIFNR,
    NAME1 TYPE LFA1-NAME1,
    EKGRP TYPE ZMMT00091-EKGRP,
    LGORT1 TYPE CHAR5,
    MENGE TYPE ZMMT00040-MENGE,
    DMBTR TYPE MSEG-DMBTR,
    CPUDT_MKPT TYPE MSEG-CPUDT_MKPT,
    ZRKSL TYPE MSEG-MENGE,
    ZRKJE TYPE MSEG-DMBTR,
    MRFMG TYPE MSEG-MENGE,
    ZCKJE TYPE MSEG-DMBTR,
    END OF TDATA.

DATA: GT_DATA TYPE TABLE OF TDATA WITH HEADER LINE.

RANGES R_BWART FOR MSEG-BWART.

TYPES: BEGIN OF TDATA2,
        MATNR TYPE MSEG-MATNR,
        CHARG TYPE MSEG-CHARG,
        DMBTR TYPE MSEG-DMBTR,
        BWART TYPE MSEG-BWART,
        MENGE TYPE MSEG-MENGE,
        ZHGZH TYPE ZMMT00091-ZHGZH,
        END OF TDATA2.

DATA: LT_DATA TYPE TABLE OF TDATA2 WITH HEADER LINE.