# Script para testar correção do ID na atualização
Write-Host "=== Teste: Correção do ID na Atualização ===" -ForegroundColor Green

# 1. Login
Write-Host "`n1. Login..." -ForegroundColor Yellow
$loginResponse = Invoke-RestMethod -Uri "http://localhost:3000/user/auth" -Method POST -ContentType "application/json" -Body '{
    "email": "teste@gmail.com",
    "password": "testes"
}'

$token = $loginResponse.result.token
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# 2. Buscar contas
Write-Host "`n2. Buscando contas..." -ForegroundColor Yellow
$accountsResponse = Invoke-RestMethod -Uri "http://localhost:3000/account" -Method GET -Headers $headers
$accountId = $accountsResponse.result[0].id

# 3. Criar transação
Write-Host "`n3. Criando transação..." -ForegroundColor Yellow
$createBody = @{
    accountId = $accountId
    description = "Teste correção ID"
    amount = 100
    type = "income"
    category = "Teste"
} | ConvertTo-Json

$createResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction" -Method POST -Headers $headers -Body $createBody
$transactionId = $createResponse.result.id

Write-Host "✅ Transação criada: $transactionId" -ForegroundColor Green
Write-Host "Description: $($createResponse.result.description)" -ForegroundColor Gray
Write-Host "Amount: $($createResponse.result.amount)" -ForegroundColor Gray

# 4. Verificar transação criada
Write-Host "`n4. Verificando transação..." -ForegroundColor Yellow
$getResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction/$transactionId" -Method GET -Headers $headers
Write-Host "✅ Transação encontrada: $($getResponse.result.transaction.id)" -ForegroundColor Green

# 5. Atualizar transação
Write-Host "`n5. Atualizando transação..." -ForegroundColor Yellow
$updateBody = @{
    description = "Teste corrigido com sucesso"
    amount = 250
    category = "Teste Corrigido"
    notes = "ID corrigido funcionando"
} | ConvertTo-Json

Write-Host "Body da atualização:" -ForegroundColor Cyan
Write-Host $updateBody -ForegroundColor Gray

try {
    $updateResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction/$transactionId" -Method PUT -Headers $headers -Body $updateBody
    
    Write-Host "✅ Transação atualizada com sucesso!" -ForegroundColor Green
    Write-Host "ID: $($updateResponse.result.id)" -ForegroundColor Gray
    Write-Host "Description: $($updateResponse.result.description)" -ForegroundColor Gray
    Write-Host "Amount: $($updateResponse.result.amount)" -ForegroundColor Gray
    Write-Host "Category: $($updateResponse.result.category)" -ForegroundColor Gray
    Write-Host "Notes: $($updateResponse.result.notes)" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Erro na atualização:" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Detalhes: $errorBody" -ForegroundColor Red
    }
}

# 6. Verificar transação final
Write-Host "`n6. Verificando transação final..." -ForegroundColor Yellow
$finalResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction/$transactionId" -Method GET -Headers $headers

Write-Host "✅ Transação final:" -ForegroundColor Green
Write-Host "Description: $($finalResponse.result.transaction.description)" -ForegroundColor Gray
Write-Host "Amount: $($finalResponse.result.transaction.amount)" -ForegroundColor Gray
Write-Host "Category: $($finalResponse.result.transaction.category)" -ForegroundColor Gray
Write-Host "Notes: $($finalResponse.result.transaction.notes)" -ForegroundColor Gray

Write-Host "`n=== Teste Concluído com Sucesso! ===" -ForegroundColor Green 