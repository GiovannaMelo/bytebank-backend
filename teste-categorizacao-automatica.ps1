# Script para testar categorização automática
Write-Host "=== Teste: Categorização Automática ===" -ForegroundColor Green

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

# 3. Testar sugestões de categoria
Write-Host "`n3. Testando sugestões de categoria..." -ForegroundColor Yellow

$testCases = @(
    @{ description = "Salário mensal"; type = "income" },
    @{ description = "Conta de luz"; type = "expense" },
    @{ description = "Supermercado Extra"; type = "expense" },
    @{ description = "Uber para trabalho"; type = "expense" },
    @{ description = "Consulta médica"; type = "expense" },
    @{ description = "Mensalidade faculdade"; type = "expense" },
    @{ description = "Cinema com amigos"; type = "expense" },
    @{ description = "Roupa nova"; type = "expense" },
    @{ description = "Geladeira nova"; type = "expense" },
    @{ description = "Investimento em ações"; type = "income" }
)

foreach ($test in $testCases) {
    Write-Host "`nTestando: '$($test.description)' ($($test.type))" -ForegroundColor Cyan
    
    try {
        $suggestionsResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/category-suggestions?description=$($test.description)&type=$($test.type)" -Method GET -Headers $headers
        
        Write-Host "✅ Categoria detectada: $($suggestionsResponse.result.detectedCategory)" -ForegroundColor Green
        Write-Host "   Sugestões: $($suggestionsResponse.result.suggestions -join ', ')" -ForegroundColor Gray
        
    } catch {
        Write-Host "❌ Erro ao obter sugestões: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 4. Testar criação de transações com categorização automática
Write-Host "`n4. Testando criação com categorização automática..." -ForegroundColor Yellow

$transactionsToCreate = @(
    @{ description = "Salário da empresa"; amount = 5000; type = "income" },
    @{ description = "Conta de água"; amount = 80; type = "expense" },
    @{ description = "Compras no supermercado"; amount = 250; type = "expense" },
    @{ description = "Uber para shopping"; amount = 25; type = "expense" },
    @{ description = "Consulta no dentista"; amount = 150; type = "expense" },
    @{ description = "Mensalidade curso de inglês"; amount = 200; type = "expense" },
    @{ description = "Ingresso cinema"; amount = 30; type = "expense" },
    @{ description = "Camisa nova"; amount = 80; type = "expense" },
    @{ description = "Geladeira Samsung"; amount = 2500; type = "expense" },
    @{ description = "Dividendos ações"; amount = 500; type = "income" }
)

foreach ($transaction in $transactionsToCreate) {
    Write-Host "`nCriando: '$($transaction.description)' - R$ $($transaction.amount)" -ForegroundColor Cyan
    
    $createBody = @{
        accountId = $accountId
        description = $transaction.description
        amount = $transaction.amount
        type = $transaction.type
    } | ConvertTo-Json
    
    try {
        $createResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction" -Method POST -Headers $headers -Body $createBody
        
        Write-Host "✅ Transação criada!" -ForegroundColor Green
        Write-Host "   Categoria: $($createResponse.result.category)" -ForegroundColor Gray
        Write-Host "   ID: $($createResponse.result.id)" -ForegroundColor Gray
        
    } catch {
        Write-Host "❌ Erro ao criar transação: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 5. Testar atualização com nova descrição
Write-Host "`n5. Testando atualização com nova descrição..." -ForegroundColor Yellow

try {
    # Buscar uma transação para atualizar
    $transactionsResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/$accountId/statement?limit=1" -Method GET -Headers $headers
    
    if ($transactionsResponse.result.transactions.length -gt 0) {
        $transactionToUpdate = $transactionsResponse.result.transactions[0]
        $transactionId = $transactionToUpdate.id
        
        Write-Host "Atualizando transação: $($transactionToUpdate.description)" -ForegroundColor Cyan
        Write-Host "Categoria atual: $($transactionToUpdate.category)" -ForegroundColor Gray
        
        $updateBody = @{
            description = "Nova descrição: Uber para aeroporto"
        } | ConvertTo-Json
        
        $updateResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction/$transactionId" -Method PUT -Headers $headers -Body $updateBody
        
        Write-Host "✅ Transação atualizada!" -ForegroundColor Green
        Write-Host "   Nova descrição: $($updateResponse.result.description)" -ForegroundColor Gray
        Write-Host "   Nova categoria: $($updateResponse.result.category)" -ForegroundColor Gray
        
    } else {
        Write-Host "❌ Nenhuma transação encontrada para atualizar" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Erro na atualização: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Teste de Categorização Concluído! ===" -ForegroundColor Green 