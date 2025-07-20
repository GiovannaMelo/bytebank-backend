const TransactionDTO = require('../models/DetailedAccount')
const { detectCategory, suggestCategories } = require('../utils/categoryDetector')
const { 
  upload, 
  saveFileInfo, 
  fileExists, 
  deleteFile, 
  getFileInfo, 
  generateFileUrl 
} = require('../utils/fileHandler')


class AccountController {
  constructor(di = {}) {
    this.di = Object.assign({
      userRepository: require('../infra/mongoose/repository/userRepository'),
      accountRepository: require('../infra/mongoose/repository/accountRepository'),
      cardRepository: require('../infra/mongoose/repository/cardRepository'),
      transactionRepository: require('../infra/mongoose/repository/detailedAccountRepository'),

      saveCard: require('../feature/Card/saveCard'),
      salvarUsuario: require('../feature/User/salvarUsuario'),
      saveAccount: require('../feature/Account/saveAccount'),
      getUser: require('../feature/User/getUser'),
      getAccount: require('../feature/Account/getAccount'),
      saveTransaction: require('../feature/Transaction/saveTransaction'),
      getTransaction: require('../feature/Transaction/getTransaction'),
      getCard: require('../feature/Card/getCard'),
    }, di)
  }

  async find(req, res, next) {
    try {
      const { accountRepository, getAccount, getCard, getTransaction, transactionRepository, cardRepository } = this.di

      const userId = req.user.id
      const account = await getAccount({ repository: accountRepository, filter: { userId } })
      
      if (!account || account.length === 0) {
        return res.status(404).json({
          message: 'Conta não encontrada'
        })
      }

      const transactions = await getTransaction({ filter: { accountId: account[0].id }, repository: transactionRepository })
      const cards = await getCard({ filter: { accountId: account[0].id }, repository: cardRepository })
    
      res.status(200).json({
        message: 'Conta carregada com sucesso',
        result: {
          account,
          transactions,
          cards,
        }
      })
    } catch (error) {
      next(error)
    }
  }

  async createTransaction(req, res, next) {
    try {
      const { saveTransaction, transactionRepository } = this.di
      const { 
        accountId, 
        description, 
        amount, 
        type, 
        category, 
        account, 
        notes, 
        tags, 
        anexo,
        from,
        to,
        value
      } = req.body

      // Usar o userId do token de autenticação
      const userId = req.user.id

      // Detectar categoria automaticamente se não fornecida
      const detectedCategory = category || detectCategory(description, type)
      const categorySuggestions = suggestCategories(description, type)
      
      console.log('Categoria detectada:', detectedCategory)
      console.log('Sugestões de categoria:', categorySuggestions)
      
      const transactionDTO = new TransactionDTO({ 
        accountId, 
        userId,
        description, 
        amount, 
        type, 
        category: detectedCategory, 
        account, 
        notes, 
        tags, 
        anexo,
        from,
        to,
        value,
        date: new Date() 
      })

      if (!transactionDTO.isValid()) {
        return res.status(400).json({
          message: 'Dados da transação inválidos'
        })
      }

      const transaction = await saveTransaction({ transaction: transactionDTO, repository: transactionRepository })
      
      res.status(201).json({
        message: 'Transação criada com sucesso',
        result: transaction
      })
    } catch (error) {
      next(error)
    }
  }

  async getStatment(req, res, next) {
    try {
      const { getTransaction, transactionRepository } = this.di

      const { accountId } = req.params
      const { page = 1, limit = 10, sort = 'date', order = 'desc' } = req.query

      // Converter para números
      const pageNumber = parseInt(page)
      const limitNumber = parseInt(limit)
      const skip = (pageNumber - 1) * limitNumber

      // Validar parâmetros
      if (pageNumber < 1 || limitNumber < 1 || limitNumber > 100) {
        return res.status(400).json({
          message: 'Parâmetros de paginação inválidos. page >= 1, limit >= 1 e <= 100'
        })
      }

      // Validar ordenação
      const validSortFields = ['date', 'amount', 'description', 'type', 'category']
      const validOrderValues = ['asc', 'desc']
      
      if (!validSortFields.includes(sort)) {
        return res.status(400).json({
          message: `Campo de ordenação inválido. Campos válidos: ${validSortFields.join(', ')}`
        })
      }

      if (!validOrderValues.includes(order)) {
        return res.status(400).json({
          message: 'Ordem inválida. Use "asc" ou "desc"'
        })
      }

      // Buscar transações com paginação
      const transactions = await getTransaction({ 
        filter: { accountId }, 
        repository: transactionRepository,
        pagination: {
          skip,
          limit: limitNumber,
          sort: { [sort]: order === 'desc' ? -1 : 1 }
        }
      })

      // Buscar total de transações para calcular páginas
      const totalTransactions = await getTransaction({ 
        filter: { accountId }, 
        repository: transactionRepository,
        count: true
      })

      const totalPages = Math.ceil(totalTransactions / limitNumber)
      const hasNextPage = pageNumber < totalPages
      const hasPrevPage = pageNumber > 1

      res.status(200).json({
        message: 'Extrato carregado com sucesso',
        result: {
          transactions,
          pagination: {
            currentPage: pageNumber,
            totalPages,
            totalItems: totalTransactions,
            itemsPerPage: limitNumber,
            hasNextPage,
            hasPrevPage,
            nextPage: hasNextPage ? pageNumber + 1 : null,
            prevPage: hasPrevPage ? pageNumber - 1 : null
          },
          filters: {
            sort,
            order
          }
        }
      })
    } catch (error) {
      next(error)
    }
  }

  async getTransactionsByCategory(req, res, next) {
    try {
      const { getTransaction, transactionRepository } = this.di
      const { category } = req.params
      const { page = 1, limit = 10, sort = 'date', order = 'desc' } = req.query
      const userId = req.user.id

      // Converter para números
      const pageNumber = parseInt(page)
      const limitNumber = parseInt(limit)
      const skip = (pageNumber - 1) * limitNumber

      // Validar parâmetros
      if (pageNumber < 1 || limitNumber < 1 || limitNumber > 100) {
        return res.status(400).json({
          message: 'Parâmetros de paginação inválidos. page >= 1, limit >= 1 e <= 100'
        })
      }

      // Validar ordenação
      const validSortFields = ['date', 'amount', 'description', 'type', 'category']
      const validOrderValues = ['asc', 'desc']
      
      if (!validSortFields.includes(sort)) {
        return res.status(400).json({
          message: `Campo de ordenação inválido. Campos válidos: ${validSortFields.join(', ')}`
        })
      }

      if (!validOrderValues.includes(order)) {
        return res.status(400).json({
          message: 'Ordem inválida. Use "asc" ou "desc"'
        })
      }

      // Buscar transações com paginação
      const transactions = await getTransaction({ 
        filter: { category, userId }, 
        repository: transactionRepository,
        pagination: {
          skip,
          limit: limitNumber,
          sort: { [sort]: order === 'desc' ? -1 : 1 }
        }
      })

      // Buscar total de transações para calcular páginas
      const totalTransactions = await getTransaction({ 
        filter: { category, userId }, 
        repository: transactionRepository,
        count: true
      })

      if (totalTransactions === 0) {
        return res.status(404).json({
          message: 'Nenhuma transação encontrada para esta categoria'
        })
      }

      const totalPages = Math.ceil(totalTransactions / limitNumber)
      const hasNextPage = pageNumber < totalPages
      const hasPrevPage = pageNumber > 1

      res.status(200).json({
        message: 'Transações encontradas com sucesso',
        result: {
          category,
          transactions,
          pagination: {
            currentPage: pageNumber,
            totalPages,
            totalItems: totalTransactions,
            itemsPerPage: limitNumber,
            hasNextPage,
            hasPrevPage,
            nextPage: hasNextPage ? pageNumber + 1 : null,
            prevPage: hasPrevPage ? pageNumber - 1 : null
          },
          filters: {
            sort,
            order
          }
        }
      })
    } catch (error) {
      next(error)
    }
  }

  async getTransactionById(req, res, next) {
    try {
      const { getTransaction, transactionRepository } = this.di
      const { transactionId } = req.params
      const userId = req.user.id

      const transaction = await getTransaction({ 
        filter: { _id: transactionId, userId }, 
        repository: transactionRepository 
      })

      if (!transaction || transaction.length === 0) {
        return res.status(404).json({
          message: 'Transação não encontrada',
          result: null
        })
      }

      res.status(200).json({
        message: 'Transação carregada com sucesso',
        result: {
          transaction: transaction[0]
        }
      })
    } catch (error) {
      next(error)
    }
  }

  async updateTransaction(req, res, next) {
    try {
      const { saveTransaction, getTransaction, transactionRepository } = this.di
      const { transactionId } = req.params
      const userId = req.user.id
      const updateData = req.body

      // Verificar se a transação existe e pertence ao usuário
      console.log('Buscando transação existente:', { transactionId, userId })
      const existingTransaction = await getTransaction({ 
        filter: { _id: transactionId, userId }, 
        repository: transactionRepository 
      })
      console.log('Transação encontrada:', existingTransaction)

      if (!existingTransaction || existingTransaction.length === 0) {
        return res.status(404).json({
          message: 'Transação não encontrada',
          result: null
        })
      }

      const currentTransaction = existingTransaction[0]
      console.log('Transação atual para atualização:', currentTransaction)

      // Detectar categoria automaticamente se a descrição foi alterada
      const newDescription = updateData.description || currentTransaction.description
      const newType = updateData.type || currentTransaction.type
      const detectedCategory = updateData.category || detectCategory(newDescription, newType)
      const categorySuggestions = suggestCategories(newDescription, newType)
      
      console.log('Categoria detectada na atualização:', detectedCategory)
      console.log('Sugestões de categoria:', categorySuggestions)
      
      // Criar DTO com dados atualizados
      console.log('Criando DTO com ID:', transactionId)
      const transactionDTO = new TransactionDTO({
        _id: transactionId, // ✅ Usar _id em vez de id
        userId: currentTransaction.userId,
        accountId: updateData.accountId || currentTransaction.accountId,
        description: newDescription,
        amount: updateData.amount || currentTransaction.amount,
        type: newType,
        category: detectedCategory,
        account: updateData.account || currentTransaction.account,
        notes: updateData.notes !== undefined ? updateData.notes : currentTransaction.notes,
        tags: updateData.tags || currentTransaction.tags,
        anexo: updateData.anexo !== undefined ? updateData.anexo : currentTransaction.anexo,
        from: updateData.from !== undefined ? updateData.from : currentTransaction.from,
        to: updateData.to !== undefined ? updateData.to : currentTransaction.to,
        value: updateData.value !== undefined ? updateData.value : currentTransaction.value,
        date: currentTransaction.date // Manter a data original
      })

      if (!transactionDTO.isValid()) {
        return res.status(400).json({
          message: 'Dados da transação inválidos'
        })
      }

      // Atualizar a transação
      console.log('Iniciando atualização da transação:', transactionId)
      const updatedTransaction = await saveTransaction({ 
        transaction: transactionDTO, 
        repository: transactionRepository,
        isUpdate: true
      })

      if (!updatedTransaction) {
        return res.status(500).json({
          message: 'Erro ao atualizar transação',
          result: null
        })
      }

      res.status(200).json({
        message: 'Transação atualizada com sucesso',
        result: updatedTransaction
      })
    } catch (error) {
      console.error('Erro na atualização de transação:', error)
      next(error)
    }
  }

  async deleteTransaction(req, res, next) {
    try {
      const { getTransaction, transactionRepository } = this.di
      const { transactionId } = req.params
      const userId = req.user.id

      // Verificar se a transação existe e pertence ao usuário
      const existingTransaction = await getTransaction({ 
        filter: { _id: transactionId, userId }, 
        repository: transactionRepository 
      })

      if (!existingTransaction || existingTransaction.length === 0) {
        return res.status(404).json({
          message: 'Transação não encontrada',
          result: null
        })
      }

      // Excluir a transação
      const deletedTransaction = await transactionRepository.deleteById(transactionId)

      if (!deletedTransaction) {
        return res.status(500).json({
          message: 'Erro ao excluir transação',
          result: null
        })
      }

      res.status(200).json({
        message: 'Transação excluída com sucesso',
        result: {
          deletedTransaction: existingTransaction[0]
        }
      })
    } catch (error) {
      next(error)
    }
  }

  // Endpoint para obter sugestões de categoria
  async getCategorySuggestions(req, res, next) {
    try {
      const { description, type = 'expense' } = req.query
      
      if (!description) {
        return res.status(400).json({
          message: 'Descrição é obrigatória',
          result: null
        })
      }
      
      const suggestions = suggestCategories(description, type)
      const detectedCategory = detectCategory(description, type)
      
      res.status(200).json({
        message: 'Sugestões de categoria obtidas com sucesso',
        result: {
          detectedCategory,
          suggestions,
          description,
          type
        }
      })
    } catch (error) {
      next(error)
    }
  }

  // Upload de anexo para transação
  async uploadAttachment(req, res, next) {
    try {
      const { transactionId } = req.params
      const userId = req.user.id

      if (!req.file) {
        return res.status(400).json({
          message: 'Nenhum arquivo foi enviado',
          result: null
        })
      }

      // Verificar se a transação existe e pertence ao usuário
      const transaction = await getTransaction(transactionId, userId)
      if (!transaction) {
        // Deletar arquivo se transação não existir
        deleteFile(req.file.filename)
        return res.status(404).json({
          message: 'Transação não encontrada',
          result: null
        })
      }

      // Salvar informações do arquivo
      const fileInfo = saveFileInfo(req.file, transactionId)
      
      // Atualizar transação com informações do anexo
      const updateData = {
        anexo: {
          filename: fileInfo.filename,
          originalName: fileInfo.originalName,
          mimetype: fileInfo.mimetype,
          size: fileInfo.size,
          uploadDate: fileInfo.uploadDate
        }
      }

      const updatedTransaction = await saveTransaction(transaction, updateData, true)

      res.status(200).json({
        message: 'Anexo enviado com sucesso',
        result: {
          transaction: updatedTransaction,
          attachment: fileInfo
        }
      })
    } catch (error) {
      // Deletar arquivo em caso de erro
      if (req.file) {
        deleteFile(req.file.filename)
      }
      next(error)
    }
  }

  // Download/visualização de anexo
  async getAttachment(req, res, next) {
    try {
      const { filename } = req.params
      const userId = req.user.id

      // Verificar se arquivo existe
      if (!fileExists(filename)) {
        return res.status(404).json({
          message: 'Arquivo não encontrado',
          result: null
        })
      }

      // Obter informações do arquivo
      const fileInfo = getFileInfo(filename)
      if (!fileInfo) {
        return res.status(404).json({
          message: 'Arquivo não encontrado',
          result: null
        })
      }

      // Verificar se o usuário tem acesso à transação
      // (implementar lógica de verificação se necessário)

      // Servir o arquivo
      const filePath = require('path').join(require('../utils/fileHandler').UPLOAD_DIR, filename)
      
      res.setHeader('Content-Type', getMimeType(filename))
      res.setHeader('Content-Disposition', `inline; filename="${fileInfo.filename}"`)
      
      res.sendFile(filePath)
    } catch (error) {
      next(error)
    }
  }

  // Remover anexo
  async removeAttachment(req, res, next) {
    try {
      const { transactionId } = req.params
      const userId = req.user.id

      // Verificar se a transação existe e pertence ao usuário
      const transaction = await getTransaction(transactionId, userId)
      if (!transaction) {
        return res.status(404).json({
          message: 'Transação não encontrada',
          result: null
        })
      }

      // Verificar se tem anexo
      if (!transaction.anexo || !transaction.anexo.filename) {
        return res.status(400).json({
          message: 'Transação não possui anexo',
          result: null
        })
      }

      // Deletar arquivo físico
      const deleted = deleteFile(transaction.anexo.filename)
      if (!deleted) {
        console.warn('Arquivo físico não encontrado para deletar:', transaction.anexo.filename)
      }

      // Remover referência do anexo na transação
      const updateData = { anexo: null }
      const updatedTransaction = await saveTransaction(transaction, updateData, true)

      res.status(200).json({
        message: 'Anexo removido com sucesso',
        result: {
          transaction: updatedTransaction
        }
      })
    } catch (error) {
      next(error)
    }
  }

  // Função auxiliar para obter MIME type
  getMimeType(filename) {
    const ext = require('path').extname(filename).toLowerCase()
    const mimeTypes = {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.gif': 'image/gif',
      '.pdf': 'application/pdf',
      '.txt': 'text/plain'
    }
    return mimeTypes[ext] || 'application/octet-stream'
  }

  async createAccount(req, res, next) {
    try {
      const { accountRepository } = this.di
      const userId = req.user.id
      const { type, name, description, initialBalance = 0 } = req.body

      // Criar dados da conta
      const accountData = {
        type,
        userId,
        name: name || `${type} Account`,
        description: description || `Conta ${type}`,
        initialBalance
      }

      // Criar a conta
      const newAccount = await accountRepository.create(accountData)

      if (!newAccount) {
        return res.status(500).json({
          message: 'Erro ao criar conta',
          result: null
        })
      }

      // Se houver saldo inicial, criar uma transação de abertura
      if (initialBalance > 0) {
        const { saveTransaction, transactionRepository } = this.di
        const TransactionDTO = require('../models/DetailedAccount')
        
        const openingTransaction = new TransactionDTO({
          userId,
          accountId: newAccount._id,
          description: `Saldo inicial da conta ${name || type}`,
          amount: initialBalance,
          type: 'income',
          category: 'Saldo Inicial',
          account: name || type,
          notes: 'Transação de abertura de conta',
          tags: ['saldo-inicial', 'abertura'],
          date: new Date()
        })

        await saveTransaction({ 
          transaction: openingTransaction, 
          repository: transactionRepository 
        })
      }

      res.status(201).json({
        message: 'Conta criada com sucesso',
        result: {
          id: newAccount._id,
          type: newAccount.type,
          userId: newAccount.userId,
          name: newAccount.name,
          description: newAccount.description,
          initialBalance,
          createdAt: newAccount.createdAt
        }
      })
    } catch (error) {
      next(error)
    }
  }
}

module.exports = AccountController