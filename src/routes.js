const { Router } = require('express')
const AccountController = require('./controller/Account')
const { validate, transactionSchema, transactionUpdateSchema, accountSchema } = require('./middleware/validation')
const { upload } = require('./utils/fileHandler')
const accountController = new AccountController({})
const router = Router()

/**
 * @swagger
 * /account:
 *   get:
 *     summary: Busca contas
 *     tags: [Contas]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de contas encontradas
 */
router.get('/account', accountController.find.bind(accountController))

/**
 * @swagger
 * /account:
 *   post:
 *     summary: Cria uma nova conta
 *     tags: [Contas]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - type
 *             properties:
 *               type:
 *                 type: string
 *                 enum: [Debit, Credit, Savings, Investment]
 *                 description: Tipo da conta
 *               name:
 *                 type: string
 *                 minLength: 3
 *                 maxLength: 50
 *                 description: Nome da conta (opcional)
 *               description:
 *                 type: string
 *                 maxLength: 200
 *                 description: Descrição da conta (opcional)
 *               initialBalance:
 *                 type: number
 *                 default: 0
 *                 description: Saldo inicial da conta (opcional)
 *     responses:
 *       201:
 *         description: Conta criada com sucesso
 *       400:
 *         description: Dados inválidos
 */
router.post('/account', validate(accountSchema), accountController.createAccount.bind(accountController))

/**
 * @swagger
 * /account/transaction:
 *   post:
 *     summary: Cria uma nova transação
 *     tags: [Transações]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - accountId
 *               - description
 *               - amount
 *               - type
 *             properties:
 *               accountId:
 *                 type: string
 *                 description: ID da conta
 *               description:
 *                 type: string
 *                 description: Descrição da transação
 *               amount:
 *                 type: number
 *                 description: Valor da transação
 *               type:
 *                 type: string
 *                 enum: [income, expense]
 *                 description: Tipo da transação (receita ou despesa)
 *               category:
 *                 type: string
 *                 description: Categoria da transação
 *               account:
 *                 type: string
 *                 description: Nome da conta
 *               notes:
 *                 type: string
 *                 description: Observações adicionais
 *               tags:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: Tags para categorização
 *               anexo:
 *                 type: string
 *                 description: Anexo da transação
 *     responses:
 *       201:
 *         description: Transação criada com sucesso
 *       400:
 *         description: Dados inválidos
 */
router.post('/account/transaction', validate(transactionSchema), accountController.createTransaction.bind(accountController))

/**
 * @swagger
 * /account/{accountId}/statement:
 *   get:
 *     summary: Obtém extrato da conta com paginação
 *     tags: [Extratos]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: accountId
 *         required: true
 *         description: ID da conta
 *         schema:
 *           type: string
 *       - in: query
 *         name: page
 *         required: false
 *         description: Numero da pagina (padrao 1)
 *         schema:
 *           type: integer
 *           minimum: 1
 *           default: 1
 *       - in: query
 *         name: limit
 *         required: false
 *         description: Itens por pagina (padrao 10, maximo 100)
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 100
 *           default: 10
 *       - in: query
 *         name: sort
 *         required: false
 *         description: Campo para ordenação
 *         schema:
 *           type: string
 *           enum: [date, amount, description, type, category]
 *           default: date
 *       - in: query
 *         name: order
 *         required: false
 *         description: Ordem da ordenação
 *         schema:
 *           type: string
 *           enum: [asc, desc]
 *           default: desc
 *     responses:
 *       200:
 *         description: Extrato encontrado com paginação
 *       400:
 *         description: Parâmetros de paginação inválidos
 *       401:
 *         description: Token inválido
 */
router.get('/account/:accountId/statement', accountController.getStatment.bind(accountController))

/**
 * @swagger
 * /account/transactions/category/{category}:
 *   get:
 *     summary: Busca transações por categoria com paginação
 *     tags: [Transações]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: category
 *         required: true
 *         description: Categoria das transações
 *         schema:
 *           type: string
 *       - in: query
 *         name: page
 *         required: false
 *         description: Numero da pagina (padrao 1)
 *         schema:
 *           type: integer
 *           minimum: 1
 *           default: 1
 *       - in: query
 *         name: limit
 *         required: false
 *         description: Itens por pagina (padrao 10, maximo 100)
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 100
 *           default: 10
 *       - in: query
 *         name: sort
 *         required: false
 *         description: Campo para ordenação
 *         schema:
 *           type: string
 *           enum: [date, amount, description, type, category]
 *           default: date
 *       - in: query
 *         name: order
 *         required: false
 *         description: Ordem da ordenação
 *         schema:
 *           type: string
 *           enum: [asc, desc]
 *           default: desc
 *     responses:
 *       200:
 *         description: Transações encontradas com paginação
 *       400:
 *         description: Parâmetros de paginação inválidos
 *       404:
 *         description: Nenhuma transação encontrada
 */
router.get('/account/transactions/category/:category', accountController.getTransactionsByCategory.bind(accountController))

/**
 * @swagger
 * /account/transaction/{transactionId}:
 *   get:
 *     summary: Obtém uma transação específica por ID
 *     tags: [Transações]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: transactionId
 *         required: true
 *         description: ID da transação
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Transação encontrada com sucesso
 *       404:
 *         description: Transação não encontrada
 */
router.get('/account/transaction/:transactionId', accountController.getTransactionById.bind(accountController))

/**
 * @swagger
 * /account/transaction/{transactionId}:
 *   put:
 *     summary: Atualiza uma transação existente
 *     tags: [Transações]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: transactionId
 *         required: true
 *         description: ID da transação
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               description:
 *                 type: string
 *                 description: Descrição da transação
 *               amount:
 *                 type: number
 *                 description: Valor da transação
 *               type:
 *                 type: string
 *                 enum: [income, expense]
 *                 description: Tipo da transação (receita ou despesa)
 *               category:
 *                 type: string
 *                 description: Categoria da transação
 *               account:
 *                 type: string
 *                 description: Nome da conta
 *               notes:
 *                 type: string
 *                 description: Observações adicionais
 *               tags:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: Tags para categorização
 *               anexo:
 *                 type: string
 *                 description: Anexo da transação
 *     responses:
 *       200:
 *         description: Transação atualizada com sucesso
 *       400:
 *         description: Dados inválidos
 *       404:
 *         description: Transação não encontrada
 */
router.put('/account/transaction/:transactionId', validate(transactionUpdateSchema), accountController.updateTransaction.bind(accountController))

/**
 * @swagger
 * /account/transaction/{transactionId}:
 *   delete:
 *     summary: Exclui uma transação
 *     tags: [Transações]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: transactionId
 *         required: true
 *         description: ID da transação
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Transação excluída com sucesso
 *       404:
 *         description: Transação não encontrada
 */
router.delete('/account/transaction/:transactionId', accountController.deleteTransaction.bind(accountController))

/**
 * @swagger
 * /account/category-suggestions:
 *   get:
 *     summary: Obtém sugestões de categoria baseadas na descrição
 *     tags: [Transações]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: description
 *         required: true
 *         description: Descrição da transação
 *         schema:
 *           type: string
 *       - in: query
 *         name: type
 *         required: false
 *         description: Tipo da transação
 *         schema:
 *           type: string
 *           enum: [income, expense]
 *           default: expense
 *     responses:
 *       200:
 *         description: Sugestões obtidas com sucesso
 *       400:
 *         description: Descrição não fornecida
 */
router.get('/account/category-suggestions', accountController.getCategorySuggestions.bind(accountController))

/**
 * @swagger
 * /account/transaction/{transactionId}/attachment:
 *   post:
 *     summary: Faz upload de anexo para uma transação
 *     tags: [Transações]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: transactionId
 *         required: true
 *         description: ID da transação
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *                 description: Arquivo para upload (JPEG, PNG, GIF, PDF, TXT - máx 5MB)
 *     responses:
 *       200:
 *         description: Anexo enviado com sucesso
 *       400:
 *         description: Nenhum arquivo enviado
 *       404:
 *         description: Transação não encontrada
 */
router.post('/account/transaction/:transactionId/attachment', 
  upload.single('file'),
  accountController.uploadAttachment.bind(accountController))

/**
 * @swagger
 * /account/transaction/attachment/{filename}:
 *   get:
 *     summary: Obtém um anexo de transação
 *     tags: [Transações]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: filename
 *         required: true
 *         description: Nome do arquivo
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Arquivo retornado com sucesso
 *         content:
 *           image/*:
 *             schema:
 *               type: string
 *               format: binary
 *           application/pdf:
 *             schema:
 *               type: string
 *               format: binary
 *           text/plain:
 *             schema:
 *               type: string
 *       404:
 *         description: Arquivo não encontrado
 */
router.get('/account/transaction/attachment/:filename', 
  accountController.getAttachment.bind(accountController))

/**
 * @swagger
 * /account/transaction/{transactionId}/attachment:
 *   delete:
 *     summary: Remove anexo de uma transação
 *     tags: [Transações]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: transactionId
 *         required: true
 *         description: ID da transação
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Anexo removido com sucesso
 *       400:
 *         description: Transação não possui anexo
 *       404:
 *         description: Transação não encontrada
 */
router.delete('/account/transaction/:transactionId/attachment', 
  accountController.removeAttachment.bind(accountController))

module.exports = router
