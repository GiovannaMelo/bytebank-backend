class Card {
    constructor({
        _id,
        type,
        is_blocked = false,
        number,
        dueDate,
        functions,
        cvc,
        paymentDate,
        name,
        accountId,
    }) {
        this.id = _id
        this.accountId = accountId
        this.type = type
        this.is_blocked = is_blocked
        this.number = number
        this.dueDate = dueDate
        this.functions = functions
        this.cvc = cvc
        this.paymentDate = paymentDate
        this.name = name
    }
}

module.exports = Card