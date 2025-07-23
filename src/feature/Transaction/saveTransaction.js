const DetailedAccountModel = require("../../models/DetailedAccount")

const saveTransaction = async ({
    transaction, repository, isUpdate = false
}) => {
  // Converter para o formato esperado pelo MongoDB
  const transactionData = {
    userId: transaction.userId,
    date: transaction.date,
    description: transaction.description,
    amount: transaction.amount,
    type: transaction.type, // 'income' ou 'expense'
    category: transaction.category,
    account: transaction.account,
    anexo: transaction.anexo,
    accountId: transaction.accountId,
    // Campos mantidos para compatibilidade
    from: transaction.from,
    to: transaction.to,
    value: transaction.amount // Usar amount como value para compatibilidade
  }
  
  let resultado
  if (isUpdate) {
    console.log('Atualizando transação - ID:', transaction.id)
    console.log('Atualizando transação - Dados:', transactionData)
    try {
      resultado = await repository.update(transaction.id, transactionData)
      console.log('Resultado da atualização:', resultado)
    } catch (error) {
      console.error('Erro no repository.update:', error)
      throw error
    }
  } else {
    resultado = await repository.create(transactionData)
  }
  
  if (!resultado) {
    throw new Error('Erro ao salvar transação: resultado é null')
  }
  
  try {
    return new DetailedAccountModel(resultado.toJSON())
  } catch (error) {
    console.error('Erro ao criar DetailedAccountModel:', error)
    console.error('Resultado que causou erro:', resultado)
    throw new Error(`Erro ao processar resultado: ${error.message}`)
  }
}

module.exports = saveTransaction