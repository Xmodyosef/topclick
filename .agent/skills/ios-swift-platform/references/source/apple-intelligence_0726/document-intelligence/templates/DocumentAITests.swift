import Testing
import Foundation

struct ReceiptValidationTests {
    let receipt = Receipt(merchant: "Corner Café", date: "2026-10-02",
                          items: [LineItem(name: "Latte", quantity: 1, price: 4.50),
                                  LineItem(name: "Bagel", quantity: 1, price: 3.25)],
                          tax: 0.62, total: 8.37, currency: "USD")

    @Test func consistentReceiptHasNoIssues() {
        var facts = Facts()
        facts.amounts = [(Decimal(string: "8.37")!, Locale.Currency("USD"))]
        #expect(validate(receipt, against: facts).isEmpty)
    }

    @Test func inventedTotalIsFlagged() {
        var facts = Facts()
        facts.amounts = [(Decimal(string: "9.99")!, Locale.Currency("USD"))]
        #expect(validate(receipt, against: facts).contains(.totalNotOnReceipt(8.37)))
    }
}

struct FakeReceiptExtractor: ReceiptExtractor {
    let result: Receipt
    func extract(_ doc: ScannedDocument) async throws -> Receipt { result }
}
