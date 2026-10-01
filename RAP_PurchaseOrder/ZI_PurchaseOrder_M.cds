@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Purchase Order - Data Definition'
define root view entity ZI_PurchaseOrder_M
  as select from zpo_header_db as PurchaseOrder
  composition [0..*] of ZI_PurchaseOrderItem_M as _PurchaseOrderItem
{
  key po_uuid        as PoUUID,
  po_id              as PoID,
  description        as Description,
  overall_status     as OverallStatus,
  created_by         as CreatedBy,
  created_at         as CreatedAt,
  last_changed_by    as LastChangedBy,
  last_changed_at    as LastChangedAt,

  /* Associations */
  _PurchaseOrderItem
}
