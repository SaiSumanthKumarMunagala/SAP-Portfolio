CLASS zcl_exchange_rate_fetcher DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS fetch_latest_rates
      RETURNING
        VALUE(rv_json_response) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_exchange_rate_fetcher IMPLEMENTATION.

  METHOD fetch_latest_rates.
    " Real-time integration with BTP CPI / Apigee API Gateway
    " Fetching Exchange Rates from external system to update SAP
    
    DATA: lo_http_client TYPE REF TO if_http_client,
          lv_url         TYPE string VALUE 'https://api.gateway.com/cpi/v1/exchange-rates',
          lv_http_code   TYPE i.

    cl_http_client=>create_by_url(
      EXPORTING
        url                = lv_url
      IMPORTING
        client             = lo_http_client
      EXCEPTIONS
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
        OTHERS             = 4 ).

    IF sy-subrc = 0.
      " Set headers for Apigee / BTP CPI authentication
      lo_http_client->request->set_header_field( name  = 'APIKey'
                                                 value = 'your_apigee_api_key_here' ).
      
      lo_http_client->request->set_method( 'GET' ).

      " Send request
      lo_http_client->send(
        EXCEPTIONS
          http_communication_failure = 1
          http_invalid_state         = 2 ).
          
      " Receive response
      lo_http_client->receive(
        EXCEPTIONS
          http_communication_failure = 1
          http_invalid_state         = 2
          http_processing_failed     = 3 ).

      lo_http_client->response->get_status( IMPORTING code = lv_http_code ).

      IF lv_http_code = 200.
        rv_json_response = lo_http_client->response->get_cdata( ).
        " Here you would parse the JSON using /ui2/cl_json and update TCURR
      ELSE.
        rv_json_response = |Error fetching rates. HTTP Code: { lv_http_code }|.
      ENDIF.
      
      lo_http_client->close( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
