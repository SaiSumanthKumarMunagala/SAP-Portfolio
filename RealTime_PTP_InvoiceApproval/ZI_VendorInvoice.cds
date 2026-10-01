@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Vendor Invoice - Interface View'
define root view entity ZI_VendorInvoice
  as select from zinv_header_db as Invoice
  composition [0..*] of ZI_VendorInvoiceItem as _InvoiceItem
{
  key inv_uuid        as InvoiceUUID,
  inv_id              as InvoiceID,
  vendor_id           as VendorID,
  company_code        as CompanyCode,
  @Semantics.amount.currencyCode: 'Currency'
  total_amount        as TotalAmount,
  currency            as Currency,
  approval_status     as ApprovalStatus,
  
  @Semantics.user.createdBy: true
  created_by          as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at          as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by     as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at     as LastChangedAt,

  _InvoiceItem
}
