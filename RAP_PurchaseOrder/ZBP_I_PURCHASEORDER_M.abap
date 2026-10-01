CLASS zbp_i_purchaseorder_m DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zi_purchaseorder_m.
ENDCLASS.

CLASS zbp_i_purchaseorder_m IMPLEMENTATION.
ENDCLASS.

CLASS lhc_PurchaseOrder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR PurchaseOrder RESULT result.

    METHODS approveOrder FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseOrder~approveOrder RESULT result.

    METHODS rejectOrder FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseOrder~rejectOrder RESULT result.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR PurchaseOrder~validateStatus.
ENDCLASS.

CLASS lhc_PurchaseOrder IMPLEMENTATION.

  METHOD get_instance_authorizations.
    " Authorization logic here
  ENDMETHOD.

  METHOD approveOrder.
    MODIFY ENTITIES OF zi_purchaseorder_m IN LOCAL MODE
      ENTITY PurchaseOrder
         UPDATE
           FIELDS ( OverallStatus )
           WITH VALUE #( FOR key IN keys ( %tky = key-%tky OverallStatus = 'A' ) )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF zi_purchaseorder_m IN LOCAL MODE
      ENTITY PurchaseOrder
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(purchase_orders).

    result = VALUE #( FOR po IN purchase_orders ( %tky = po-%tky %param = po ) ).
  ENDMETHOD.

  METHOD rejectOrder.
    MODIFY ENTITIES OF zi_purchaseorder_m IN LOCAL MODE
      ENTITY PurchaseOrder
         UPDATE
           FIELDS ( OverallStatus )
           WITH VALUE #( FOR key IN keys ( %tky = key-%tky OverallStatus = 'R' ) )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF zi_purchaseorder_m IN LOCAL MODE
      ENTITY PurchaseOrder
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(purchase_orders).

    result = VALUE #( FOR po IN purchase_orders ( %tky = po-%tky %param = po ) ).
  ENDMETHOD.

  METHOD validateStatus.
    READ ENTITIES OF zi_purchaseorder_m IN LOCAL MODE
      ENTITY PurchaseOrder
        FIELDS ( OverallStatus ) WITH CORRESPONDING #( keys )
      RESULT DATA(purchase_orders).

    LOOP AT purchase_orders INTO DATA(po).
      IF po-OverallStatus IS INITIAL.
        APPEND VALUE #( %tky = po-%tky ) TO failed-purchaseorder.
        APPEND VALUE #( %tky = po-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Status cannot be empty' )
                      ) TO reported-purchaseorder.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
