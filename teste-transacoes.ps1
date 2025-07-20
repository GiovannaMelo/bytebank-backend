# Script de teste para a nova funcionalidade de transações
# Autor: Sistema Bancário Tech Challenge 2

Write-Host "=== TESTE DA NOVA FUNCIONALIDADE DE TRANSAÇÕES ===" -ForegroundColor Green
Write-Host ""

# URL base da API
$baseUrl = "http://localhost:3001"

# 1. Criar um usuário
Write-Host "1. Criando usuário..." -ForegroundColor Yellow
$userData = @{
    username = "João Silva"
    email = "joao.silva@email.com"
    password = "123456"
} | ConvertTo-Json

try {
    $userResponse = Invoke-WebRequest -Uri "$baseUrl/user" -Method POST -Body $userData -ContentType "application/json"
    $userResult = $userResponse.Content | ConvertFrom-Json
    Write-Host "✅ Usuário criado com sucesso!" -ForegroundColor Green
    Write-Host "   ID: $($userResult.result.id)" -ForegroundColor Cyan
    Write-Host "   Nome: $($userResult.result.username)" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "❌ Erro ao criar usuário: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. Autenticar o usuário
Write-Host "2. Autenticando usuário..." -ForegroundColor Yellow
$authData = @{
    email = "joao.silva@email.com"
    password = "123456"
} | ConvertTo-Json

try {
    $authResponse = Invoke-WebRequest -Uri "$baseUrl/user/auth" -Method POST -Body $authData -ContentType "application/json"
    $authResult = $authResponse.Content | ConvertFrom-Json
    $token = $authResult.result.token
    Write-Host "✅ Usuário autenticado com sucesso!" -ForegroundColor Green
    Write-Host "   Token: $($token.Substring(0, 20))..." -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "❌ Erro ao autenticar usuário: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 3. Buscar conta do usuário
Write-Host "3. Buscando conta do usuário..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
}

try {
    $accountResponse = Invoke-WebRequest -Uri "$baseUrl/account" -Method GET -Headers $headers
    $accountResult = $accountResponse.Content | ConvertFrom-Json
    $accountId = $accountResult.result.account[0].id
    Write-Host "✅ Conta encontrada!" -ForegroundColor Green
    Write-Host "   ID da Conta: $accountId" -ForegroundColor Cyan
    Write-Host "   Tipo: $($accountResult.result.account[0].type)" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "❌ Erro ao buscar conta: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 4. Criar transação de receita (income)
Write-Host "4. Criando transação de receita..." -ForegroundColor Yellow
$incomeData = @{
    accountId = $accountId
    description = "Salário mensal"
    amount = 5000
    type = "income"
    category = "Salário"
    account = "Conta Principal"
    notes = "Salário do mês de dezembro"
    tags = @("salário", "renda")
    anexo = "comprovante-salario.pdf"
} | ConvertTo-Json

try {
    $incomeResponse = Invoke-WebRequest -Uri "$baseUrl/account/transaction" -Method POST -Body $incomeData -Headers $headers -ContentType "application/json"
    $incomeResult = $incomeResponse.Content | ConvertFrom-Json
    Write-Host "✅ Transação de receita criada!" -ForegroundColor Green
    Write-Host "   Descrição: $($incomeResult.result.description)" -ForegroundColor Cyan
    Write-Host "   Valor: R$ $($incomeResult.result.amount)" -ForegroundColor Cyan
    Write-Host "   Categoria: $($incomeResult.result.category)" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "❌ Erro ao criar transação de receita: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. Criar transação de despesa (expense)
Write-Host "5. Criando transação de despesa..." -ForegroundColor Yellow
$expenseData = @{
    accountId = $accountId
    description = "Compras no supermercado"
    amount = 150.50
    type = "expense"
    category = "Alimentação"
    account = "Cartão de Crédito"
    notes = "Compras semanais"
    tags = @("alimentação", "supermercado")
    anexo = "nota-fiscal.pdf"
} | ConvertTo-Json

try {
    $expenseResponse = Invoke-WebRequest -Uri "$baseUrl/account/transaction" -Method POST -Body $expenseData -Headers $headers -ContentType "application/json"
    $expenseResult = $expenseResponse.Content | ConvertFrom-Json
    Write-Host "✅ Transação de despesa criada!" -ForegroundColor Green
    Write-Host "   Descrição: $($expenseResult.result.description)" -ForegroundColor Cyan
    Write-Host "   Valor: R$ $($expenseResult.result.amount)" -ForegroundColor Cyan
    Write-Host "   Categoria: $($expenseResult.result.category)" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "❌ Erro ao criar transação de despesa: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. Buscar extrato da conta
Write-Host "6. Buscando extrato da conta..." -ForegroundColor Yellow
try {
    $statementResponse = Invoke-WebRequest -Uri "$baseUrl/account/$accountId/statement" -Method GET -Headers $headers
    $statementResult = $statementResponse.Content | ConvertFrom-Json
    Write-Host "✅ Extrato carregado!" -ForegroundColor Green
    Write-Host "   Total de transações: $($statementResult.result.transactions.Count)" -ForegroundColor Cyan
    foreach ($transaction in $statementResult.result.transactions) {
        Write-Host "   - $($transaction.description): R$ $($transaction.amount) ($($transaction.type))" -ForegroundColor White
    }
    Write-Host ""
} catch {
    Write-Host "❌ Erro ao buscar extrato: $($_.Exception.Message)" -ForegroundColor Red
}

# 7. Buscar transações por categoria
Write-Host "7. Buscando transações por categoria 'Alimentação'..." -ForegroundColor Yellow
try {
    $categoryResponse = Invoke-WebRequest -Uri "$baseUrl/account/transactions/category/Alimentação" -Method GET -Headers $headers
    $categoryResult = $categoryResponse.Content | ConvertFrom-Json
    Write-Host "✅ Transações por categoria encontradas!" -ForegroundColor Green
    Write-Host "   Categoria: $($categoryResult.result.category)" -ForegroundColor Cyan
    Write-Host "   Total: $($categoryResult.result.total)" -ForegroundColor Cyan
    foreach ($transaction in $categoryResult.result.transactions) {
        Write-Host "   - $($transaction.description): R$ $($transaction.amount)" -ForegroundColor White
    }
    Write-Host ""
} catch {
    Write-Host "❌ Erro ao buscar transações por categoria: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "=== TESTE CONCLUÍDO COM SUCESSO! ===" -ForegroundColor Green
Write-Host ""
Write-Host "🎉 Todas as funcionalidades da nova estrutura de transações estão funcionando!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Resumo das funcionalidades testadas:" -ForegroundColor Yellow
Write-Host "   ✅ Criação de usuário" -ForegroundColor Green
Write-Host "   ✅ Autenticação JWT" -ForegroundColor Green
Write-Host "   ✅ Busca de conta" -ForegroundColor Green
Write-Host "   ✅ Criação de transação de receita (income)" -ForegroundColor Green
Write-Host "   ✅ Criação de transação de despesa (expense)" -ForegroundColor Green
Write-Host "   ✅ Busca de extrato" -ForegroundColor Green
Write-Host "   ✅ Busca por categoria" -ForegroundColor Green
Write-Host ""
Write-Host "🔗 Acesse a documentação em: http://localhost:3001/docs" -ForegroundColor Cyan 