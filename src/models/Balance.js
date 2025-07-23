class Balance {
    constructor({
        _id,
        userId,
        accountId,
        currentBalance,
        lastCalculatedAt,
        lastTransactionId
    }) {
        this.id = _id
        this.userId = userId
        this.accountId = accountId
        this.currentBalance = currentBalance || 0
        this.lastCalculatedAt = lastCalculatedAt || new Date()
        this.lastTransactionId = lastTransactionId
    }

    isValid() {
        return this.userId && this.accountId
    }

    updateBalance(newBalance, transactionId) {
        this.currentBalance = newBalance
        this.lastCalculatedAt = new Date()
        this.lastTransactionId = transactionId
    }
}

module.exports = Balance 