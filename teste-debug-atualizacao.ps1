# Script para debugar problema de atualização de transação
Write-Host "=== Debug: Atualização de Transação ===" -ForegroundColor Green

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
    Write-Host "User ID: $userId" -ForegroundColor Gray
} else {
    Write-Host "❌ Erro no login" -ForegroundColor Red
    exit 1
}

# 2. Buscar contas
Write-Host "`n2. Buscando contas..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$accountsResponse = Invoke-RestMethod -Uri "http://localhost:3000/account" -Method GET -Headers $headers

if ($accountsResponse.result -and $accountsResponse.result.length -gt 0) {
    $accountId = $accountsResponse.result[0].id
    Write-Host "✅ Conta encontrada: $accountId" -ForegroundColor Green
} else {
    Write-Host "❌ Nenhuma conta encontrada" -ForegroundColor Red
    exit 1
}

# 3. Criar transação para teste
Write-Host "`n3. Criando transação para teste..." -ForegroundColor Yellow
$transactionBody = @{
    accountId = $accountId
    description = "Transação para debug"
    amount = 1000
    type = "income"
    category = "Debug"
    notes = "Transação criada para debug"
    tags = @("debug", "teste")
} | ConvertTo-Json -Depth 3

try {
    $transactionResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction" -Method POST -Headers $headers -Body $transactionBody
    
    $transactionId = $transactionResponse.result.id
    Write-Host "✅ Transação criada: $transactionId" -ForegroundColor Green
    Write-Host "Description: $($transactionResponse.result.description)" -ForegroundColor Gray
    Write-Host "Amount: $($transactionResponse.result.amount)" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Erro ao criar transação:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# 4. Buscar transação para verificar
Write-Host "`n4. Verificando transação criada..." -ForegroundColor Yellow
try {
    $getResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction/$transactionId" -Method GET -Headers $headers
    
    Write-Host "✅ Transação encontrada:" -ForegroundColor Green
    Write-Host "ID: $($getResponse.result.transaction.id)" -ForegroundColor Gray
    Write-Host "Description: $($getResponse.result.transaction.description)" -ForegroundColor Gray
    Write-Host "Amount: $($getResponse.result.transaction.amount)" -ForegroundColor Gray
    Write-Host "Type: $($getResponse.result.transaction.type)" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Erro ao buscar transação:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# 5. Tentar atualizar transação
Write-Host "`n5. Tentando atualizar transação..." -ForegroundColor Yellow
$updateBody = @{
    description = "Transação atualizada via debug"
    amount = 1500
    category = "Debug Atualizado"
    notes = "Atualização realizada via debug"
    tags = @("debug", "atualizado", "sucesso")
} | ConvertTo-Json -Depth 3

Write-Host "Body da atualização:" -ForegroundColor Cyan
Write-Host $updateBody -ForegroundColor Gray

try {
    $updateResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction/$transactionId" -Method PUT -Headers $headers -Body $updateBody
    
    Write-Host "✅ Transação atualizada com sucesso!" -ForegroundColor Green
    Write-Host "ID: $($updateResponse.result.id)" -ForegroundColor Gray
    Write-Host "Description: $($updateResponse.result.description)" -ForegroundColor Gray
    Write-Host "Amount: $($updateResponse.result.amount)" -ForegroundColor Gray
    Write-Host "Category: $($updateResponse.result.category)" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Erro na atualização:" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error Body:" -ForegroundColor Red
        Write-Host $errorBody -ForegroundColor Red
    }
}

# 6. Verificar transação após atualização
Write-Host "`n6. Verificando transação após atualização..." -ForegroundColor Yellow
try {
    $finalResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction/$transactionId" -Method GET -Headers $headers
    
    Write-Host "✅ Transação final:" -ForegroundColor Green
    Write-Host "Description: $($finalResponse.result.transaction.description)" -ForegroundColor Gray
    Write-Host "Amount: $($finalResponse.result.transaction.amount)" -ForegroundColor Gray
    Write-Host "Category: $($finalResponse.result.transaction.category)" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Erro ao verificar transação final:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n=== Debug Concluído ===" -ForegroundColor Green 