CLASS zcl_gl_auto_posting_api DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_gl_auto_posting_api IMPLEMENTATION.

  METHOD if_http_extension~handle_request.
    " Real-time endpoint to accept JSON payload from BTP/3rd Party Systems
    " and automatically post it to the General Ledger.

    DATA: lv_request_body TYPE string,
          lt_gl_entries   TYPE zcl_gl_auto_posting=>tt_gl_entries,
          lo_gl_poster    TYPE REF TO zcl_gl_auto_posting,
          lv_obj_key      TYPE bapiache09-obj_key,
          lt_return       TYPE bapiret2_tab.

    " 1. Get JSON payload from HTTP Request
    lv_request_body = server->request->get_cdata( ).

    " 2. Deserialize JSON into ABAP internal table (using standard UI2 JSON class)
    /ui2/cl_json=>deserialize(
      EXPORTING
        json = lv_request_body
      CHANGING
        data = lt_gl_entries
    ).

    IF lt_gl_entries IS INITIAL.
      server->response->set_cdata( '{"error": "Invalid or empty JSON payload"}' ).
      server->response->set_status( code = 400 reason = 'Bad Request' ).
      RETURN.
    ENDIF.

    " 3. Trigger the Automated GL Posting
    CREATE OBJECT lo_gl_poster.
    
    lo_gl_poster->post_journal_entries(
      EXPORTING
        it_entries = lt_gl_entries
      IMPORTING
        ev_obj_key = lv_obj_key
        et_return  = lt_return
    ).

    " 4. Format and Return Response
    READ TABLE lt_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
    IF sy-subrc = 0.
      " Errors occurred
      DATA(lv_error_json) = /ui2/cl_json=>serialize( data = lt_return ).
      server->response->set_cdata( lv_error_json ).
      server->response->set_status( code = 500 reason = 'Internal Server Error' ).
    ELSE.
      " Success
      server->response->set_cdata( |\{"success": true, "document_number": "{ lv_obj_key }"\}| ).
      server->response->set_status( code = 200 reason = 'OK' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
