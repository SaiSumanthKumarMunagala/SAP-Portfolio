using my.bookshop from '../db/schema';

service CatalogService {
    @readonly entity Books as projection on bookshop.Books;
    @readonly entity Authors as projection on bookshop.Authors;

    entity Orders as projection on bookshop.Orders;

    action submitOrder (book: Integer, amount: Integer) returns Orders;
}
