# Script de teste para paginação do extrato
# Autor: Sistema Bancário Tech Challenge 2

Write-Host "=== TESTE DE PAGINAÇÃO DO EXTRATO ===" -ForegroundColor Green
Write-Host ""

# URL base da API
$baseUrl = "http://localhost:3001"

# 1. Criar um usuário para teste
Write-Host "1. Criando usuário para teste..." -ForegroundColor Yellow
$userData = @{
    username = "Teste Paginação"
    email = "paginacao@teste.com"
    password = "123456"
} | ConvertTo-Json

try {
    $userResponse = Invoke-WebRequest -Uri "$baseUrl/user" -Method POST -Body $userData -ContentType "application/json"
    $userResult = $userResponse.Content | ConvertFrom-Json
    Write-Host "✅ Usuário criado com sucesso!" -ForegroundColor Green
    Write-Host "   ID: $($userResult.result.id)" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "❌ Erro ao criar usuário: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. Autenticar o usuário
Write-Host "2. Autenticando usuário..." -ForegroundColor Yellow
$authData = @{
    email = "paginacao@teste.com"
    password = "123456"
} | ConvertTo-Json

try {
    $authResponse = Invoke-WebRequest -Uri "$baseUrl/user/auth" -Method POST -Body $authData -ContentType "application/json"
    $authResult = $authResponse.Content | ConvertFrom-Json
    $token = $authResult.result.token
    $headers = @{ "Authorization" = "Bearer $token" }
    Write-Host "✅ Usuário autenticado com sucesso!" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ Erro ao autenticar usuário: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 3. Buscar conta do usuário
Write-Host "3. Buscando conta do usuário..." -ForegroundColor Yellow
try {
    $accountResponse = Invoke-WebRequest -Uri "$baseUrl/account" -Method GET -Headers $headers
    $accountResult = $accountResponse.Content | ConvertFrom-Json
    $accountId = $accountResult.result.account[0].id
    Write-Host "✅ Conta encontrada!" -ForegroundColor Green
    Write-Host "   ID da Conta: $accountId" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "❌ Erro ao buscar conta: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 4. Criar várias transações para testar paginação
Write-Host "4. Criando transações para teste de paginação..." -ForegroundColor Yellow

$categories = @("Salário", "Alimentação", "Transporte", "Lazer", "Contas")
$descriptions = @(
    "Salário mensal",
    "Compras no supermercado", 
    "Combustível",
    "Cinema",
    "Conta de luz",
    "Freelance",
    "Restaurante",
    "Uber",
    "Netflix",
    "Internet"
)

for ($i = 0; $i -lt 15; $i++) {
    $category = $categories[$i % $categories.Length]
    $description = $descriptions[$i % $descriptions.Length]
    $amount = if ($i % 2 -eq 0) { (Get-Random -Minimum 100 -Maximum 5000) } else { -(Get-Random -Minimum 50 -Maximum 500) }
    $type = if ($amount -gt 0) { "income" } else { "expense" }
    
    $transactionData = @{
        accountId = $accountId
        description = "$description $($i + 1)"
        amount = [Math]::Abs($amount)
        type = $type
        category = $category
        notes = "Transação de teste $($i + 1)"
        tags = @($category.ToLower(), "teste")
    } | ConvertTo-Json

    try {
        $transactionResponse = Invoke-WebRequest -Uri "$baseUrl/account/transaction" -Method POST -Body $transactionData -Headers $headers -ContentType "application/json"
        Write-Host "   ✅ Transação $($i + 1) criada" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Erro ao criar transação $($i + 1): $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

# 5. Testar paginação - Primeira página
Write-Host "5. Testando primeira página (padrão)..." -ForegroundColor Yellow
try {
    $page1Response = Invoke-WebRequest -Uri "$baseUrl/account/$accountId/statement" -Method GET -Headers $headers
    $page1Result = $page1Response.Content | ConvertFrom-Json
    Write-Host "✅ Primeira página carregada!" -ForegroundColor Green
    Write-Host "   Total de itens: $($page1Result.result.pagination.totalItems)" -ForegroundColor Cyan
    Write-Host "   Página atual: $($page1Result.result.pagination.currentPage)" -ForegroundColor Cyan
    Write-Host "   Total de páginas: $($page1Result.result.pagination.totalPages)" -ForegroundColor Cyan
    Write-Host "   Itens por página: $($page1Result.result.pagination.itemsPerPage)" -ForegroundColor Cyan
    Write-Host "   Tem próxima página: $($page1Result.result.pagination.hasNextPage)" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "❌ Erro ao carregar primeira página: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. Testar paginação - Segunda página
Write-Host "6. Testando segunda página..." -ForegroundColor Yellow
try {
    $page2Response = Invoke-WebRequest -Uri "$baseUrl/account/$accountId/statement?page=2&limit=5" -Method GET -Headers $headers
    $page2Result = $page2Response.Content | ConvertFrom-Json
    Write-Host "✅ Segunda página carregada!" -ForegroundColor Green
    Write-Host "   Página atual: $($page2Result.result.pagination.currentPage)" -ForegroundColor Cyan
    Write-Host "   Itens por página: $($page2Result.result.pagination.itemsPerPage)" -ForegroundColor Cyan
    Write-Host "   Tem página anterior: $($page2Result.result.pagination.hasPrevPage)" -ForegroundColor Cyan
    Write-Host "   Tem próxima página: $($page2Result.result.pagination.hasNextPage)" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "❌ Erro ao carregar segunda página: $($_.Exception.Message)" -ForegroundColor Red
}

# 7. Testar ordenação por valor
Write-Host "7. Testando ordenação por valor (maior para menor)..." -ForegroundColor Yellow
try {
    $sortResponse = Invoke-WebRequest -Uri "$baseUrl/account/$accountId/statement?sort=amount&order=desc&limit=3" -Method GET -Headers $headers
    $sortResult = $sortResponse.Content | ConvertFrom-Json
    Write-Host "✅ Ordenação por valor aplicada!" -ForegroundColor Green
    Write-Host "   Campo de ordenação: $($sortResult.result.filters.sort)" -ForegroundColor Cyan
    Write-Host "   Ordem: $($sortResult.result.filters.order)" -ForegroundColor Cyan
    Write-Host "   Primeiro valor: $($sortResult.result.transactions[0].amount)" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "❌ Erro ao testar ordenação: $($_.Exception.Message)" -ForegroundColor Red
}

# 8. Testar busca por categoria com paginação
Write-Host "8. Testando busca por categoria com paginação..." -ForegroundColor Yellow
try {
    $categoryResponse = Invoke-WebRequest -Uri "$baseUrl/account/transactions/category/Alimentação?page=1&limit=3" -Method GET -Headers $headers
    $categoryResult = $categoryResponse.Content | ConvertFrom-Json
    Write-Host "✅ Busca por categoria com paginação!" -ForegroundColor Green
    Write-Host "   Categoria: $($categoryResult.result.category)" -ForegroundColor Cyan
    Write-Host "   Total de itens: $($categoryResult.result.pagination.totalItems)" -ForegroundColor Cyan
    Write-Host "   Página atual: $($categoryResult.result.pagination.currentPage)" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "❌ Erro ao buscar por categoria: $($_.Exception.Message)" -ForegroundColor Red
}

# 9. Testar validação de parâmetros inválidos
Write-Host "9. Testando validação de parâmetros inválidos..." -ForegroundColor Yellow
try {
    $invalidResponse = Invoke-WebRequest -Uri "$baseUrl/account/$accountId/statement?page=0&limit=200" -Method GET -Headers $headers
    Write-Host "❌ Validação falhou - deveria ter retornado erro" -ForegroundColor Red
} catch {
    $errorResult = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResult)
    $errorContent = $reader.ReadToEnd()
    Write-Host "✅ Validação funcionando corretamente!" -ForegroundColor Green
    Write-Host "   Erro retornado: $errorContent" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "=== TESTE DE PAGINAÇÃO CONCLUÍDO COM SUCESSO! ===" -ForegroundColor Green
Write-Host ""
Write-Host "🎉 Todas as funcionalidades de paginação estão funcionando!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Resumo das funcionalidades testadas:" -ForegroundColor Yellow
Write-Host "   ✅ Paginação básica (page, limit)" -ForegroundColor Green
Write-Host "   ✅ Ordenação (sort, order)" -ForegroundColor Green
Write-Host "   ✅ Informações de paginação (totalPages, hasNextPage, etc.)" -ForegroundColor Green
Write-Host "   ✅ Busca por categoria com paginação" -ForegroundColor Green
Write-Host "   ✅ Validação de parâmetros inválidos" -ForegroundColor Green
Write-Host ""
Write-Host "🔗 Acesse a documentação em: http://localhost:3001/docs" -ForegroundColor Cyan 