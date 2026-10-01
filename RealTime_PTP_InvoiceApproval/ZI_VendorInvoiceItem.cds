@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Vendor Invoice Item - Interface View'
define view entity ZI_VendorInvoiceItem
  as select from zinv_item_db as InvoiceItem
  association to parent ZI_VendorInvoice as _Invoice on $projection.InvoiceUUID = _Invoice.InvoiceUUID
{
  key item_uuid       as ItemUUID,
  inv_uuid            as InvoiceUUID,
  item_number         as ItemNumber,
  material            as Material,
  quantity            as Quantity,
  @Semantics.amount.currencyCode: 'Currency'
  unit_price          as UnitPrice,
  currency            as Currency,

  _Invoice
}
