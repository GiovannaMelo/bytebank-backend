# Script simples para testar atualização de transação
Write-Host "=== Teste Simples: Atualização de Transação ===" -ForegroundColor Green

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

# 3. Criar transação simples
Write-Host "`n3. Criando transação..." -ForegroundColor Yellow
$createBody = @{
    accountId = $accountId
    description = "Teste simples"
    amount = 100
    type = "income"
} | ConvertTo-Json

$createResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction" -Method POST -Headers $headers -Body $createBody
$transactionId = $createResponse.result.id

Write-Host "Transação criada: $transactionId" -ForegroundColor Green

# 4. Atualizar transação
Write-Host "`n4. Atualizando transação..." -ForegroundColor Yellow
$updateBody = @{
    description = "Teste atualizado"
    amount = 200
} | ConvertTo-Json

Write-Host "Body: $updateBody" -ForegroundColor Cyan

try {
    $updateResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction/$transactionId" -Method PUT -Headers $headers -Body $updateBody
    Write-Host "✅ Sucesso!" -ForegroundColor Green
    Write-Host "Novo amount: $($updateResponse.result.amount)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Detalhes: $errorBody" -ForegroundColor Red
    }
}

Write-Host "`n=== Fim do Teste ===" -ForegroundColor Green 