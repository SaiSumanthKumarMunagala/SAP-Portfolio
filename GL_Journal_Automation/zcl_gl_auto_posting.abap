CLASS zcl_gl_auto_posting DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_gl_entry,
             doc_date     TYPE bapiache09-doc_date,
             pstng_date   TYPE bapiache09-pstng_date,
             comp_code    TYPE bapiache09-comp_code,
             currency     TYPE bapiache09-currency,
             ref_doc_no   TYPE bapiache09-ref_doc_no,
             header_txt   TYPE bapiache09-header_txt,
             item_no      TYPE bapiacgl09-itemno_acc,
             gl_account   TYPE bapiacgl09-gl_account,
             amount       TYPE bapiaccr09-amt_doccur,
             cost_center  TYPE bapiacgl09-costcenter,
             item_text    TYPE bapiacgl09-item_text,
           END OF ty_gl_entry.
           
    TYPES tt_gl_entries TYPE STANDARD TABLE OF ty_gl_entry WITH DEFAULT KEY.

    METHODS post_journal_entries
      IMPORTING
        it_entries TYPE tt_gl_entries
      EXPORTING
        ev_obj_key TYPE bapiache09-obj_key
        et_return  TYPE bapiret2_tab.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS map_header
      IMPORTING
        is_entry         TYPE ty_gl_entry
      RETURNING
        VALUE(rs_header) TYPE bapiache09.
ENDCLASS.

CLASS zcl_gl_auto_posting IMPLEMENTATION.

  METHOD post_journal_entries.
    DATA: ls_documentheader TYPE bapiache09,
          lt_accountgl      TYPE TABLE OF bapiacgl09,
          ls_accountgl      TYPE bapiacgl09,
          lt_currencyamount TYPE TABLE OF bapiaccr09,
          ls_currencyamount TYPE bapiaccr09.

    " Clear returns
    CLEAR: ev_obj_key, et_return.

    " 1. Map Header Data (Taking from the first item assuming bulk items belong to same header)
    READ TABLE it_entries INTO DATA(ls_first) INDEX 1.
    IF sy-subrc = 0.
      ls_documentheader = map_header( ls_first ).
    ELSE.
      APPEND VALUE #( type = 'E' message = 'No data provided for posting' ) TO et_return.
      RETURN.
    ENDIF.

    " 2. Map Items and Currencies
    LOOP AT it_entries INTO DATA(ls_entry).
      " GL Account mapping
      CLEAR ls_accountgl.
      ls_accountgl-itemno_acc  = ls_entry-item_no.
      ls_accountgl-gl_account  = ls_entry-gl_account.
      ls_accountgl-costcenter  = ls_entry-cost_center.
      ls_accountgl-item_text   = ls_entry-item_text.
      ls_accountgl-doc_type    = 'SA'. " GL Account Document
      APPEND ls_accountgl TO lt_accountgl.

      " Currency mapping
      CLEAR ls_currencyamount.
      ls_currencyamount-itemno_acc = ls_entry-item_no.
      ls_currencyamount-currency   = ls_entry-currency.
      ls_currencyamount-amt_doccur = ls_entry-amount.
      APPEND ls_currencyamount TO lt_currencyamount.
    ENDLOOP.

    " 3. Call BAPI to check and post
    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
      EXPORTING
        documentheader = ls_documentheader
      IMPORTING
        obj_key        = ev_obj_key
      TABLES
        accountgl      = lt_accountgl
        currencyamount = lt_currencyamount
        return         = et_return.

    " 4. Auto-commit if no errors
    READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
    IF sy-subrc <> 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      CLEAR ev_obj_key. " Clear key if failed
    ENDIF.

  ENDMETHOD.

  METHOD map_header.
    rs_header-username   = sy-uname.
    rs_header-header_txt = is_entry-header_txt.
    rs_header-comp_code  = is_entry-comp_code.
    rs_header-doc_date   = is_entry-doc_date.
    rs_header-pstng_date = is_entry-pstng_date.
    rs_header-doc_type   = 'SA'.
    rs_header-ref_doc_no = is_entry-ref_doc_no.
  ENDMETHOD.

ENDCLASS.
