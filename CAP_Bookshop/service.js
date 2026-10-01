module.exports = (srv) => {

    const { Books, Orders } = srv.entities;

    // Custom handler for submitOrder action
    srv.on('submitOrder', async (req) => {
        const { book, amount } = req.data;
        
        const tx = cds.transaction(req);
        
        // Check if book exists and has enough stock
        const bookRecord = await tx.run(
            SELECT.one.from(Books).where({ ID: book })
        );

        if (!bookRecord) {
            return req.error(404, `Book with ID ${book} not found`);
        }
        
        if (bookRecord.stock < amount) {
            return req.error(400, `Not enough stock for book ${book}`);
        }

        // Deduct stock
        await tx.run(
            UPDATE(Books)
            .set({ stock: { '-=': amount } })
            .where({ ID: book })
        );

        // Create the order
        const newOrder = {
            ID: cds.utils.uuid(),
            book_ID: book,
            amount: amount,
            status: 'P' // Pending
        };

        await tx.run(INSERT.into(Orders).entries(newOrder));

        return newOrder;
    });

    // Add some custom validation before creating an order
    srv.before('CREATE', 'Orders', async (req) => {
        const order = req.data;
        if (!order.amount || order.amount <= 0) {
            req.error(400, "Order amount must be greater than zero.");
        }
    });

}
