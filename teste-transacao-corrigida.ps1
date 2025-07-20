# Script para testar criação de transação com validação corrigida
Write-Host "=== Teste de Criação de Transação (Validação Corrigida) ===" -ForegroundColor Green

# 1. Fazer login para obter token
Write-Host "`n1. Fazendo login..." -ForegroundColor Yellow
$loginResponse = Invoke-RestMethod -Uri "http://localhost:3000/user/auth" -Method POST -ContentType "application/json" -Body '{
    "email": "teste@gmail.com",
    "password": "testes"
}'

if ($loginResponse.result.token) {
    $token = $loginResponse.result.token
    $userId = $loginResponse.result.id
    Write-Host "✅ Login realizado com sucesso" -ForegroundColor Green
    Write-Host "Token: $($token.Substring(0, 20))..." -ForegroundColor Gray
    Write-Host "User ID: $userId" -ForegroundColor Gray
} else {
    Write-Host "❌ Erro no login" -ForegroundColor Red
    exit 1
}

# 2. Buscar contas para obter accountId
Write-Host "`n2. Buscando contas..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$accountsResponse = Invoke-RestMethod -Uri "http://localhost:3000/account" -Method GET -Headers $headers

if ($accountsResponse.result -and $accountsResponse.result.length -gt 0) {
    $accountId = $accountsResponse.result[0].id
    Write-Host "✅ Conta encontrada" -ForegroundColor Green
    Write-Host "Account ID: $accountId" -ForegroundColor Gray
} else {
    Write-Host "❌ Nenhuma conta encontrada" -ForegroundColor Red
    exit 1
}

# 3. Criar transação (sem userId no body)
Write-Host "`n3. Criando transação..." -ForegroundColor Yellow
$transactionBody = @{
    accountId = $accountId
    description = "Salário mensal"
    amount = 5000
    type = "income"
    category = "Salário"
    account = "Conta Principal"
    notes = "Salário do mês de dezembro"
    tags = @("salário", "renda")
    anexo = "comprovante.pdf"
} | ConvertTo-Json -Depth 3

Write-Host "Body da transação:" -ForegroundColor Cyan
Write-Host $transactionBody -ForegroundColor Gray

try {
    $transactionResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction" -Method POST -Headers $headers -Body $transactionBody
    
    Write-Host "✅ Transação criada com sucesso!" -ForegroundColor Green
    Write-Host "Transaction ID: $($transactionResponse.result.id)" -ForegroundColor Gray
    Write-Host "Amount: $($transactionResponse.result.amount)" -ForegroundColor Gray
    Write-Host "Type: $($transactionResponse.result.type)" -ForegroundColor Gray
    Write-Host "User ID: $($transactionResponse.result.userId)" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Erro ao criar transação:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Detalhes do erro:" -ForegroundColor Red
        Write-Host $errorBody -ForegroundColor Red
    }
}

# 4. Criar transação de despesa
Write-Host "`n4. Criando transação de despesa..." -ForegroundColor Yellow
$expenseBody = @{
    accountId = $accountId
    description = "Compras no supermercado"
    amount = 150.50
    type = "expense"
    category = "Alimentação"
    account = "Conta Principal"
    notes = "Compras semanais"
    tags = @("alimentação", "supermercado")
} | ConvertTo-Json -Depth 3

try {
    $expenseResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction" -Method POST -Headers $headers -Body $expenseBody
    
    Write-Host "✅ Transação de despesa criada com sucesso!" -ForegroundColor Green
    Write-Host "Transaction ID: $($expenseResponse.result.id)" -ForegroundColor Gray
    Write-Host "Amount: $($expenseResponse.result.amount)" -ForegroundColor Gray
    Write-Host "Type: $($expenseResponse.result.type)" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Erro ao criar transação de despesa:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n=== Teste Concluído ===" -ForegroundColor Green 