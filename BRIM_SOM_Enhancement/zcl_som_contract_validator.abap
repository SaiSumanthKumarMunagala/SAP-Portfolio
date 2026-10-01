CLASS zcl_som_contract_validator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_crm_isx_order_check_badi .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_som_contract_validator IMPLEMENTATION.

  METHOD if_crm_isx_order_check_badi~check_document.
    " Real-time validation for BRIM Subscription Order Management (SOM)
    " Ensures that any Provider Contract created with a specific product has the correct discounting applied
    DATA: lt_items TYPE crmt_isx_order_item_t.

    " Read items from order
    lt_items = io_order->get_items( ).

    LOOP AT lt_items INTO DATA(ls_item).
      " Check if it's a subscription product
      IF ls_item-product_id = 'SUB_PREMIUM_VIDEO' AND ls_item-discount_percent > 50.
        " Throw error - discount exceeds threshold for Premium Video
        APPEND VALUE #( type       = 'E'
                        id         = 'ZBRIM_ERRORS'
                        number     = '001'
                        message_v1 = ls_item-product_id
                        message_v2 = ls_item-discount_percent
                      ) TO et_messages.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
