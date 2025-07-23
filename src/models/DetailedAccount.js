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
        anexo,
        // accountId, // Comentado temporariamente - será desvinculado da transação
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
        this.anexo = anexo
        // this.accountId = accountId // Comentado temporariamente - será desvinculado da transação
        this.from = from
        this.to = to
        this.value = value // mantido para compatibilidade
    }

    isValid() {
        return this.userId && this.amount && this.type && this.date
    }
}

module.exports = DetailedAccount