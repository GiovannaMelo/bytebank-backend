const TransactionDTO = require('../models/DetailedAccount')

class DashboardController {
  constructor(di = {}) {
    this.di = Object.assign({
      userRepository: require('../infra/mongoose/repository/userRepository'),
      accountRepository: require('../infra/mongoose/repository/accountRepository'),
      transactionRepository: require('../infra/mongoose/repository/detailedAccountRepository'),
      getTransaction: require('../feature/Transaction/getTransaction'),
    }, di)
  }

  // Resumo geral da conta
  async getAccountSummary(req, res, next) {
    try {
      const { getTransaction, transactionRepository } = this.di
      
      console.log('req.user:', req.user);
      console.log('req.headers:', req.headers);
      
      if (!req.user || !req.user.id) {
        return res.status(401).json({ 
          message: 'Usuário não autenticado',
          error: 'req.user ou req.user.id não encontrado'
        });
      }
      
      const userId = req.user.id

      // Buscar todas as transações do usuário
      const allTransactions = await getTransaction({ 
        filter: { userId }, 
        repository: transactionRepository 
      })

      if (!allTransactions || allTransactions.length === 0) {
        return res.status(200).json({
          message: 'Nenhuma transação encontrada',
          result: {
            totalIncome: 0,
            totalExpense: 0,
            balance: 0,
            transactionCount: 0,
            monthlyData: [],
            categoryBreakdown: []
          }
        })
      }

      // Calcular totais
      const totalIncome = allTransactions
        .filter(t => t.type === 'income')
        .reduce((sum, t) => sum + t.amount, 0)

      const totalExpense = allTransactions
        .filter(t => t.type === 'expense')
        .reduce((sum, t) => sum + t.amount, 0)

      const balance = totalIncome - totalExpense

      // Dados mensais dos últimos 6 meses
      const monthlyData = this.calculateMonthlyData(allTransactions)

      // Breakdown por categoria
      const categoryBreakdown = this.calculateCategoryBreakdown(allTransactions)

      res.status(200).json({
        message: 'Resumo da conta carregado com sucesso',
        result: {
          totalIncome,
          totalExpense,
          balance,
          transactionCount: allTransactions.length,
          monthlyData,
          categoryBreakdown
        }
      })
    } catch (error) {
      next(error)
    }
  }

  // Dados para gráfico de linha (evolução do saldo)
  async getBalanceEvolution(req, res, next) {
    try {
      const { getTransaction, transactionRepository } = this.di
      
      if (!req.user || !req.user.id) {
        return res.status(401).json({ 
          message: 'Usuário não autenticado',
          error: 'req.user ou req.user.id não encontrado'
        });
      }
      
      const userId = req.user.id
      const { months = 6 } = req.query

      const allTransactions = await getTransaction({ 
        filter: { userId }, 
        repository: transactionRepository 
      })

      if (!allTransactions || allTransactions.length === 0) {
        return res.status(200).json({
          message: 'Nenhuma transação encontrada',
          result: {
            balanceEvolution: [],
            monthlyBalance: []
          }
        })
      }

      const balanceEvolution = this.calculateBalanceEvolution(allTransactions, parseInt(months))
      const monthlyBalance = this.calculateMonthlyBalance(allTransactions, parseInt(months))

      res.status(200).json({
        message: 'Evolução do saldo carregada com sucesso',
        result: {
          balanceEvolution,
          monthlyBalance
        }
      })
    } catch (error) {
      next(error)
    }
  }

  // Top categorias de gastos
  async getTopExpenseCategories(req, res, next) {
    try {
      const { getTransaction, transactionRepository } = this.di
      
      if (!req.user || !req.user.id) {
        return res.status(401).json({ 
          message: 'Usuário não autenticado',
          error: 'req.user ou req.user.id não encontrado'
        });
      }
      
      const userId = req.user.id
      const { limit = 5 } = req.query

      const allTransactions = await getTransaction({ 
        filter: { userId }, 
        repository: transactionRepository 
      })

      if (!allTransactions || allTransactions.length === 0) {
        return res.status(200).json({
          message: 'Nenhuma transação encontrada',
          result: {
            topCategories: []
          }
        })
      }

      const expenseTransactions = allTransactions.filter(t => t.type === 'expense')
      const topCategories = this.calculateTopCategories(expenseTransactions, parseInt(limit))

      res.status(200).json({
        message: 'Top categorias carregadas com sucesso',
        result: {
          topCategories
        }
      })
    } catch (error) {
      next(error)
    }
  }

  // Transações recentes
  async getRecentTransactions(req, res, next) {
    try {
      const { getTransaction, transactionRepository } = this.di
      
      if (!req.user || !req.user.id) {
        return res.status(401).json({ 
          message: 'Usuário não autenticado',
          error: 'req.user ou req.user.id não encontrado'
        });
      }
      
      const userId = req.user.id
      const { limit = 10 } = req.query

      const recentTransactions = await getTransaction({ 
        filter: { userId }, 
        repository: transactionRepository,
        pagination: {
          skip: 0,
          limit: parseInt(limit),
          sort: { date: -1 }
        }
      })

      res.status(200).json({
        message: 'Transações recentes carregadas com sucesso',
        result: {
          recentTransactions
        }
      })
    } catch (error) {
      next(error)
    }
  }

  // Estatísticas por período
  async getPeriodStats(req, res, next) {
    try {
      const { getTransaction, transactionRepository } = this.di
      
      if (!req.user || !req.user.id) {
        return res.status(401).json({ 
          message: 'Usuário não autenticado',
          error: 'req.user ou req.user.id não encontrado'
        });
      }
      
      const userId = req.user.id
      const { period = 'month' } = req.query // month, quarter, year

      const allTransactions = await getTransaction({ 
        filter: { userId }, 
        repository: transactionRepository 
      })

      if (!allTransactions || allTransactions.length === 0) {
        return res.status(200).json({
          message: 'Nenhuma transação encontrada',
          result: {
            periodStats: {
              income: 0,
              expense: 0,
              balance: 0,
              transactionCount: 0,
              averageTransaction: 0
            }
          }
        })
      }

      const periodStats = this.calculatePeriodStats(allTransactions, period)

      res.status(200).json({
        message: 'Estatísticas do período carregadas com sucesso',
        result: {
          periodStats
        }
      })
    } catch (error) {
      next(error)
    }
  }

  // Métodos auxiliares
  calculateMonthlyData(transactions) {
    const monthlyData = {}
    
    transactions.forEach(transaction => {
      const date = new Date(transaction.date)
      const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`
      
      if (!monthlyData[monthKey]) {
        monthlyData[monthKey] = { income: 0, expense: 0, count: 0 }
      }
      
      if (transaction.type === 'income') {
        monthlyData[monthKey].income += transaction.amount
      } else {
        monthlyData[monthKey].expense += transaction.amount
      }
      
      monthlyData[monthKey].count++
    })

    return Object.entries(monthlyData)
      .map(([month, data]) => ({
        month,
        income: data.income,
        expense: data.expense,
        balance: data.income - data.expense,
        count: data.count
      }))
      .sort((a, b) => a.month.localeCompare(b.month))
      .slice(-6) // Últimos 6 meses
  }

  calculateCategoryBreakdown(transactions) {
    const categoryData = {}
    
    transactions.forEach(transaction => {
      const category = transaction.category || 'Sem categoria'
      
      if (!categoryData[category]) {
        categoryData[category] = { income: 0, expense: 0, count: 0 }
      }
      
      if (transaction.type === 'income') {
        categoryData[category].income += transaction.amount
      } else {
        categoryData[category].expense += transaction.amount
      }
      
      categoryData[category].count++
    })

    return Object.entries(categoryData)
      .map(([category, data]) => ({
        category,
        income: data.income,
        expense: data.expense,
        total: data.income + data.expense,
        count: data.count
      }))
      .sort((a, b) => b.total - a.total)
  }

  calculateBalanceEvolution(transactions, months) {
    const sortedTransactions = transactions
      .sort((a, b) => new Date(a.date) - new Date(b.date))

    let balance = 0
    const evolution = []

    sortedTransactions.forEach(transaction => {
      if (transaction.type === 'income') {
        balance += transaction.amount
      } else {
        balance -= transaction.amount
      }

      evolution.push({
        date: transaction.date,
        balance,
        transactionId: transaction.id,
        description: transaction.description
      })
    })

    return evolution.slice(-months * 30) // Últimos X meses (aproximadamente)
  }

  calculateMonthlyBalance(transactions, months) {
    const monthlyBalance = {}
    
    transactions.forEach(transaction => {
      const date = new Date(transaction.date)
      const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`
      
      if (!monthlyBalance[monthKey]) {
        monthlyBalance[monthKey] = 0
      }
      
      if (transaction.type === 'income') {
        monthlyBalance[monthKey] += transaction.amount
      } else {
        monthlyBalance[monthKey] -= transaction.amount
      }
    })

    return Object.entries(monthlyBalance)
      .map(([month, balance]) => ({ month, balance }))
      .sort((a, b) => a.month.localeCompare(b.month))
      .slice(-months)
  }

  calculateTopCategories(expenseTransactions, limit) {
    const categoryTotals = {}
    
    expenseTransactions.forEach(transaction => {
      const category = transaction.category || 'Sem categoria'
      categoryTotals[category] = (categoryTotals[category] || 0) + transaction.amount
    })

    return Object.entries(categoryTotals)
      .map(([category, total]) => ({ category, total }))
      .sort((a, b) => b.total - a.total)
      .slice(0, limit)
  }

  calculatePeriodStats(transactions, period) {
    const now = new Date()
    let startDate

    switch (period) {
      case 'month':
        startDate = new Date(now.getFullYear(), now.getMonth(), 1)
        break
      case 'quarter':
        const quarter = Math.floor(now.getMonth() / 3)
        startDate = new Date(now.getFullYear(), quarter * 3, 1)
        break
      case 'year':
        startDate = new Date(now.getFullYear(), 0, 1)
        break
      default:
        startDate = new Date(now.getFullYear(), now.getMonth(), 1)
    }

    const periodTransactions = transactions.filter(t => 
      new Date(t.date) >= startDate
    )

    const income = periodTransactions
      .filter(t => t.type === 'income')
      .reduce((sum, t) => sum + t.amount, 0)

    const expense = periodTransactions
      .filter(t => t.type === 'expense')
      .reduce((sum, t) => sum + t.amount, 0)

    const balance = income - expense
    const transactionCount = periodTransactions.length
    const averageTransaction = transactionCount > 0 ? (income + expense) / transactionCount : 0

    return {
      income,
      expense,
      balance,
      transactionCount,
      averageTransaction
    }
  }
}

module.exports = DashboardController 