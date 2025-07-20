const { Router } = require('express')
const DashboardController = require('./controller/Dashboard')

const dashboardController = new DashboardController({})
const router = Router()

/**
 * @swagger
 * /dashboard/summary:
 *   get:
 *     summary: Obtém resumo geral da conta para dashboard
 *     tags: [Dashboard]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Resumo da conta carregado com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 result:
 *                   type: object
 *                   properties:
 *                     totalIncome:
 *                       type: number
 *                       description: Total de receitas
 *                     totalExpense:
 *                       type: number
 *                       description: Total de despesas
 *                     balance:
 *                       type: number
 *                       description: Saldo atual
 *                     transactionCount:
 *                       type: integer
 *                       description: Total de transações
 *                     monthlyData:
 *                       type: array
 *                       description: Dados mensais dos últimos 6 meses
 *                     categoryBreakdown:
 *                       type: array
 *                       description: Breakdown por categoria
 */
router.get('/summary', dashboardController.getAccountSummary.bind(dashboardController))

/**
 * @swagger
 * /dashboard/balance-evolution:
 *   get:
 *     summary: Obtém evolução do saldo para gráfico de linha
 *     tags: [Dashboard]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: months
 *         required: false
 *         description: Numero de meses para analisar (padrao 6)
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 12
 *           default: 6
 *     responses:
 *       200:
 *         description: Evolução do saldo carregada com sucesso
 */
router.get('/balance-evolution', dashboardController.getBalanceEvolution.bind(dashboardController))

/**
 * @swagger
 * /dashboard/top-expense-categories:
 *   get:
 *     summary: Obtém top categorias de gastos
 *     tags: [Dashboard]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: limit
 *         required: false
 *         description: Numero de categorias para retornar (padrao 5)
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 20
 *           default: 5
 *     responses:
 *       200:
 *         description: Top categorias carregadas com sucesso
 */
router.get('/top-expense-categories', dashboardController.getTopExpenseCategories.bind(dashboardController))

/**
 * @swagger
 * /dashboard/recent-transactions:
 *   get:
 *     summary: Obtém transações recentes
 *     tags: [Dashboard]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: limit
 *         required: false
 *         description: Numero de transações para retornar (padrao 10)
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 50
 *           default: 10
 *     responses:
 *       200:
 *         description: Transações recentes carregadas com sucesso
 */
router.get('/recent-transactions', dashboardController.getRecentTransactions.bind(dashboardController))

/**
 * @swagger
 * /dashboard/period-stats:
 *   get:
 *     summary: Obtém estatísticas por período
 *     tags: [Dashboard]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: period
 *         required: false
 *         description: Periodo para analisar
 *         schema:
 *           type: string
 *           enum: [month, quarter, year]
 *           default: month
 *     responses:
 *       200:
 *         description: Estatísticas do período carregadas com sucesso
 */
router.get('/period-stats', dashboardController.getPeriodStats.bind(dashboardController))

module.exports = router 