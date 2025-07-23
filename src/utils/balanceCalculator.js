const BalanceRepository = require('../infra/mongoose/repository/balanceRepository')

class BalanceCalculator {
  constructor() {
    this.balanceRepository = new BalanceRepository()
    this.isProcessing = false
  }

  // Método para calcular saldo em background após uma transação
  async calculateBalanceAfterTransaction(userId, accountId, transactionId) {
    try {
      // Executar em background sem bloquear a resposta
      setImmediate(async () => {
        try {
          console.log(`🔄 Calculando saldo em background para usuário ${userId}, conta ${accountId}`)
          
          const { DetailedAccount } = require('../infra/mongoose/modelos')
          
          // Buscar todas as transações do usuário
          const transactions = await DetailedAccount.find({ userId })
          
          // Calcular saldo para a conta específica
          const balance = await this.balanceRepository.calculateBalanceFromTransactions(
            userId, 
            accountId, 
            transactions
          )
          
          // Atualizar o saldo
          await this.balanceRepository.updateBalance(userId, accountId, balance, transactionId)
          
          console.log(`✅ Saldo calculado com sucesso: R$ ${balance.toFixed(2)}`)
        } catch (error) {
          console.error('❌ Erro ao calcular saldo em background:', error)
        }
      })
    } catch (error) {
      console.error('Erro ao agendar cálculo de saldo:', error)
    }
  }

  // Método para recalcular todos os saldos de um usuário
  async recalculateAllBalances(userId) {
    if (this.isProcessing) {
      console.log('⚠️ Cálculo de saldo já está em andamento')
      return
    }

    this.isProcessing = true
    
    try {
      console.log(`🔄 Recalculando todos os saldos para usuário ${userId}`)
      
      await this.balanceRepository.recalculateAllBalances(userId)
      
      console.log(`✅ Todos os saldos recalculados com sucesso para usuário ${userId}`)
    } catch (error) {
      console.error('❌ Erro ao recalcular saldos:', error)
      throw error
    } finally {
      this.isProcessing = false
    }
  }

  // Método para obter saldo atual de uma conta
  async getCurrentBalance(userId, accountId) {
    try {
      const balance = await this.balanceRepository.findByUserAndAccount(userId, accountId)
      
      if (balance) {
        return {
          currentBalance: balance.currentBalance,
          lastCalculatedAt: balance.lastCalculatedAt,
          lastTransactionId: balance.lastTransactionId
        }
      }
      
      // Se não existe saldo calculado, calcular agora
      const { DetailedAccount } = require('../infra/mongoose/modelos')
      const transactions = await DetailedAccount.find({ userId })
      const calculatedBalance = await this.balanceRepository.calculateBalanceFromTransactions(
        userId, 
        accountId, 
        transactions
      )
      
      // Salvar o saldo calculado
      await this.balanceRepository.updateBalance(userId, accountId, calculatedBalance, null)
      
      return {
        currentBalance: calculatedBalance,
        lastCalculatedAt: new Date(),
        lastTransactionId: null
      }
    } catch (error) {
      console.error('Erro ao obter saldo atual:', error)
      throw error
    }
  }

  // Método para agendar recálculo periódico (pode ser chamado por um cron job)
  async schedulePeriodicRecalculation() {
    try {
      const { User } = require('../infra/mongoose/modelos')
      
      // Buscar todos os usuários
      const users = await User.find({})
      
      for (const user of users) {
        // Agendar recálculo para cada usuário
        setImmediate(async () => {
          try {
            await this.recalculateAllBalances(user._id)
          } catch (error) {
            console.error(`Erro ao recalcular saldos para usuário ${user._id}:`, error)
          }
        })
      }
      
      console.log(`📅 Agendado recálculo de saldos para ${users.length} usuários`)
    } catch (error) {
      console.error('Erro ao agendar recálculo periódico:', error)
    }
  }
}

module.exports = BalanceCalculator 