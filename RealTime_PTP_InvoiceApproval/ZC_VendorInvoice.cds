@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Invoice - Projection View'
@Metadata.allowExtensions: true
define root view entity ZC_VendorInvoice
  as projection on ZI_VendorInvoice
{
  key InvoiceUUID,
  InvoiceID,
  VendorID,
  CompanyCode,
  TotalAmount,
  Currency,
  ApprovalStatus,
  
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,

  /* Associations */
  _InvoiceItem : redirected to composition child ZC_VendorInvoiceItem
}
