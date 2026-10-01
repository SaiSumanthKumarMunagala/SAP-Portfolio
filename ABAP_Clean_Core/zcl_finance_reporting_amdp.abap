CLASS zcl_finance_reporting_amdp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.

    TYPES: BEGIN OF ty_finance_summary,
             company_code  TYPE bukrs,
             fiscal_year   TYPE gjahr,
             total_revenue TYPE p LENGTH 15 DECIMALS 2,
             currency      TYPE waers,
           END OF ty_finance_summary,
           tt_finance_summary TYPE STANDARD TABLE OF ty_finance_summary WITH EMPTY KEY.

    CLASS-METHODS get_revenue_summary
      IMPORTING
        VALUE(iv_company_code) TYPE bukrs
        VALUE(iv_fiscal_year)  TYPE gjahr
      EXPORTING
        VALUE(et_summary)      TYPE tt_finance_summary.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_finance_reporting_amdp IMPLEMENTATION.

  METHOD get_revenue_summary BY DATABASE PROCEDURE FOR HDB
                             LANGUAGE SQLSCRIPT
                             OPTIONS READ-ONLY
                             USING bkpf bseg.
    -- AMDP Implementation for HANA DB pushing down the calculation to DB level
    et_summary =
      SELECT h.bukrs AS company_code,
             h.gjahr AS fiscal_year,
             SUM( i.wrbtr ) AS total_revenue,
             h.waers AS currency
        FROM bkpf AS h
        INNER JOIN bseg AS i
          ON  h.bukrs = i.bukrs
          AND h.belnr = i.belnr
          AND h.gjahr = i.gjahr
        WHERE h.bukrs = :iv_company_code
          AND h.gjahr = :iv_fiscal_year
          AND i.shkzg = 'H' -- Credit items for revenue (simplified)
          AND i.koart = 'S' -- GL Account
        GROUP BY h.bukrs, h.gjahr, h.waers;

  ENDMETHOD.

ENDCLASS.
