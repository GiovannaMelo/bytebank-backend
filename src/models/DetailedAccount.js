class DetailedAccount {
    constructor({
        _id, 
        userId, 
        date, 
        description, 
        amount, 
        type, 
        category, 
        account, 
        notes, 
        tags, 
        anexo,
        accountId,
        from,
        to,
        value
    }) {
        this.id = _id
        this.userId = userId
        this.date = date
        this.description = description
        this.amount = amount
        this.type = type // 'income' | 'expense'
        this.category = category
        this.account = account
        this.notes = notes
        this.tags = tags || []
        this.anexo = anexo
        this.accountId = accountId
        this.from = from
        this.to = to
        this.value = value // mantido para compatibilidade
    }

    isValid() {
        return this.userId && this.amount && this.type && this.date
    }
}

module.exports = DetailedAccount