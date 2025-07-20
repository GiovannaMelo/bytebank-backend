# Script para testar atualização de transação com validação corrigida
Write-Host "=== Teste de Atualização de Transação (Validação Corrigida) ===" -ForegroundColor Green

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

# 3. Criar transação para testar atualização
Write-Host "`n3. Criando transação para teste..." -ForegroundColor Yellow
$transactionBody = @{
    accountId = $accountId
    description = "Transação original para teste"
    amount = 1000
    type = "income"
    category = "Teste"
    notes = "Transação criada para teste de atualização"
    tags = @("teste", "original")
} | ConvertTo-Json -Depth 3

try {
    $transactionResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction" -Method POST -Headers $headers -Body $transactionBody
    
    $transactionId = $transactionResponse.result.id
    Write-Host "✅ Transação criada com sucesso!" -ForegroundColor Green
    Write-Host "Transaction ID: $transactionId" -ForegroundColor Gray
    Write-Host "Description: $($transactionResponse.result.description)" -ForegroundColor Gray
    Write-Host "Amount: $($transactionResponse.result.amount)" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Erro ao criar transação:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# 4. Atualizar transação (sem accountId no body)
Write-Host "`n4. Atualizando transação..." -ForegroundColor Yellow
$updateBody = @{
    description = "Transação atualizada com sucesso"
    amount = 1500
    category = "Teste Atualizado"
    notes = "Transação atualizada para teste"
    tags = @("teste", "atualizado", "sucesso")
} | ConvertTo-Json -Depth 3

Write-Host "Body da atualização:" -ForegroundColor Cyan
Write-Host $updateBody -ForegroundColor Gray

try {
    $updateResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction/$transactionId" -Method PUT -Headers $headers -Body $updateBody
    
    Write-Host "✅ Transação atualizada com sucesso!" -ForegroundColor Green
    Write-Host "Transaction ID: $($updateResponse.result.id)" -ForegroundColor Gray
    Write-Host "Description: $($updateResponse.result.description)" -ForegroundColor Gray
    Write-Host "Amount: $($updateResponse.result.amount)" -ForegroundColor Gray
    Write-Host "Category: $($updateResponse.result.category)" -ForegroundColor Gray
    Write-Host "Notes: $($updateResponse.result.notes)" -ForegroundColor Gray
    Write-Host "Tags: $($updateResponse.result.tags -join ', ')" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Erro ao atualizar transação:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Detalhes do erro:" -ForegroundColor Red
        Write-Host $errorBody -ForegroundColor Red
    }
}

# 5. Verificar transação atualizada
Write-Host "`n5. Verificando transação atualizada..." -ForegroundColor Yellow
try {
    $getResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction/$transactionId" -Method GET -Headers $headers
    
    Write-Host "✅ Transação verificada com sucesso!" -ForegroundColor Green
    Write-Host "Description: $($getResponse.result.transaction.description)" -ForegroundColor Gray
    Write-Host "Amount: $($getResponse.result.transaction.amount)" -ForegroundColor Gray
    Write-Host "Category: $($getResponse.result.transaction.category)" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Erro ao verificar transação:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# 6. Testar atualização parcial (apenas alguns campos)
Write-Host "`n6. Testando atualização parcial..." -ForegroundColor Yellow
$partialUpdateBody = @{
    amount = 2000
    notes = "Atualização parcial realizada"
} | ConvertTo-Json -Depth 3

Write-Host "Body da atualização parcial:" -ForegroundColor Cyan
Write-Host $partialUpdateBody -ForegroundColor Gray

try {
    $partialResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction/$transactionId" -Method PUT -Headers $headers -Body $partialUpdateBody
    
    Write-Host "✅ Atualização parcial realizada com sucesso!" -ForegroundColor Green
    Write-Host "Amount: $($partialResponse.result.amount)" -ForegroundColor Gray
    Write-Host "Notes: $($partialResponse.result.notes)" -ForegroundColor Gray
    Write-Host "Description: $($partialResponse.result.description)" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Erro na atualização parcial:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n=== Teste Concluído ===" -ForegroundColor Green 