const { Balance } = require('../modelos')

class BalanceRepository {
  async create(balanceData) {
    try {
      const balance = new Balance(balanceData)
      return await balance.save()
    } catch (error) {
      console.error('Erro ao criar saldo:', error)
      throw error
    }
  }

  async findByUserAndAccount(userId, accountId) {
    try {
      return await Balance.findOne({ userId, accountId })
    } catch (error) {
      console.error('Erro ao buscar saldo:', error)
      throw error
    }
  }

  async updateBalance(userId, accountId, newBalance, transactionId) {
    try {
      const balance = await Balance.findOneAndUpdate(
        { userId, accountId },
        {
          currentBalance: newBalance,
          lastCalculatedAt: new Date(),
          lastTransactionId: transactionId
        },
        { new: true, upsert: true }
      )
      return balance
    } catch (error) {
      console.error('Erro ao atualizar saldo:', error)
      throw error
    }
  }

  async calculateBalanceFromTransactions(userId, accountId, transactions) {
    try {
      let balance = 0
      
      // Filtrar transações que ainda têm accountId (para compatibilidade)
      const accountTransactions = transactions.filter(t => 
        t.accountId && t.accountId.toString() === accountId.toString()
      )
      
      for (const transaction of accountTransactions) {
        if (transaction.type === 'income') {
          balance += transaction.amount
        } else if (transaction.type === 'expense') {
          balance -= transaction.amount
        }
      }
      
      return balance
    } catch (error) {
      console.error('Erro ao calcular saldo:', error)
      throw error
    }
  }

  async recalculateAllBalances(userId) {
    try {
      const { Account, DetailedAccount } = require('../modelos')
      
      // Buscar todas as contas do usuário
      const accounts = await Account.find({ userId })
      
      for (const account of accounts) {
        // Buscar todas as transações do usuário
        const transactions = await DetailedAccount.find({ userId })
        
        // Calcular saldo para esta conta
        const balance = await this.calculateBalanceFromTransactions(
          userId, 
          account._id, 
          transactions
        )
        
        // Atualizar ou criar registro de saldo
        await this.updateBalance(userId, account._id, balance, null)
      }
    } catch (error) {
      console.error('Erro ao recalcular saldos:', error)
      throw error
    }
  }
}

module.exports = BalanceRepository 