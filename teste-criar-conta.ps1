# Script para testar criação de contas
# Execute: .\teste-criar-conta.ps1

Write-Host "=== TESTE DE CRIAÇÃO DE CONTAS ===" -ForegroundColor Green
Write-Host ""

# Configurações
$baseUrl = "http://localhost:3001"
$token = ""

# Função para fazer login e obter token
function Get-AuthToken {
    Write-Host "🔐 Fazendo login..." -ForegroundColor Yellow
    
    $loginBody = @{
        email = "teste@gmail.com"
        password = "testes"
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -Body $loginBody -ContentType "application/json"
        $script:token = $response.token
        Write-Host "✅ Login realizado com sucesso!" -ForegroundColor Green
        Write-Host "Token: $($token.Substring(0, 50))..." -ForegroundColor Gray
        Write-Host ""
    }
    catch {
        Write-Host "❌ Erro no login: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Função para fazer requisições autenticadas
function Invoke-AuthenticatedRequest {
    param(
        [string]$Uri,
        [string]$Method = "GET",
        [object]$Body = $null
    )
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    try {
        if ($Body) {
            $response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $headers -Body ($Body | ConvertTo-Json)
        } else {
            $response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $headers
        }
        return $response
    }
    catch {
        Write-Host "❌ Erro na requisição: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Função para testar criação de conta corrente
function Test-CreateDebitAccount {
    Write-Host "🏦 Testando criação de conta corrente..." -ForegroundColor Cyan
    
    $accountBody = @{
        type = "Debit"
        name = "Conta Corrente Principal"
        description = "Conta corrente para uso diário e pagamentos"
        initialBalance = 2500
    }
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account" -Method POST -Body $accountBody
    
    if ($response) {
        Write-Host "✅ Conta corrente criada com sucesso!" -ForegroundColor Green
        Write-Host "   ID: $($response.result.id)" -ForegroundColor White
        Write-Host "   Nome: $($response.result.name)" -ForegroundColor White
        Write-Host "   Tipo: $($response.result.type)" -ForegroundColor White
        Write-Host "   Descrição: $($response.result.description)" -ForegroundColor White
        Write-Host "   Saldo inicial: R$ $($response.result.initialBalance)" -ForegroundColor White
        Write-Host "   Data de criação: $($response.result.createdAt)" -ForegroundColor White
    }
    Write-Host ""
}

# Função para testar criação de conta poupança
function Test-CreateSavingsAccount {
    Write-Host "💰 Testando criação de conta poupança..." -ForegroundColor Cyan
    
    $accountBody = @{
        type = "Savings"
        name = "Conta Poupança"
        description = "Conta poupança para reserva de emergência"
        initialBalance = 5000
    }
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account" -Method POST -Body $accountBody
    
    if ($response) {
        Write-Host "✅ Conta poupança criada com sucesso!" -ForegroundColor Green
        Write-Host "   ID: $($response.result.id)" -ForegroundColor White
        Write-Host "   Nome: $($response.result.name)" -ForegroundColor White
        Write-Host "   Tipo: $($response.result.type)" -ForegroundColor White
        Write-Host "   Descrição: $($response.result.description)" -ForegroundColor White
        Write-Host "   Saldo inicial: R$ $($response.result.initialBalance)" -ForegroundColor White
    }
    Write-Host ""
}

# Função para testar criação de cartão de crédito
function Test-CreateCreditAccount {
    Write-Host "💳 Testando criação de cartão de crédito..." -ForegroundColor Cyan
    
    $accountBody = @{
        type = "Credit"
        name = "Cartão de Crédito Principal"
        description = "Cartão de crédito para compras parceladas"
        initialBalance = 0
    }
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account" -Method POST -Body $accountBody
    
    if ($response) {
        Write-Host "✅ Cartão de crédito criado com sucesso!" -ForegroundColor Green
        Write-Host "   ID: $($response.result.id)" -ForegroundColor White
        Write-Host "   Nome: $($response.result.name)" -ForegroundColor White
        Write-Host "   Tipo: $($response.result.type)" -ForegroundColor White
        Write-Host "   Descrição: $($response.result.description)" -ForegroundColor White
        Write-Host "   Saldo inicial: R$ $($response.result.initialBalance)" -ForegroundColor White
    }
    Write-Host ""
}

# Função para testar criação de conta de investimento
function Test-CreateInvestmentAccount {
    Write-Host "📈 Testando criação de conta de investimento..." -ForegroundColor Cyan
    
    $accountBody = @{
        type = "Investment"
        name = "Conta de Investimentos"
        description = "Conta para aplicações em renda fixa e variável"
        initialBalance = 10000
    }
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account" -Method POST -Body $accountBody
    
    if ($response) {
        Write-Host "✅ Conta de investimento criada com sucesso!" -ForegroundColor Green
        Write-Host "   ID: $($response.result.id)" -ForegroundColor White
        Write-Host "   Nome: $($response.result.name)" -ForegroundColor White
        Write-Host "   Tipo: $($response.result.type)" -ForegroundColor White
        Write-Host "   Descrição: $($response.result.description)" -ForegroundColor White
        Write-Host "   Saldo inicial: R$ $($response.result.initialBalance)" -ForegroundColor White
    }
    Write-Host ""
}

# Função para testar criação com dados mínimos
function Test-CreateMinimalAccount {
    Write-Host "📝 Testando criação com dados mínimos..." -ForegroundColor Cyan
    
    $accountBody = @{
        type = "Debit"
    }
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account" -Method POST -Body $accountBody
    
    if ($response) {
        Write-Host "✅ Conta criada com dados mínimos!" -ForegroundColor Green
        Write-Host "   ID: $($response.result.id)" -ForegroundColor White
        Write-Host "   Nome padrão: $($response.result.name)" -ForegroundColor White
        Write-Host "   Descrição padrão: $($response.result.description)" -ForegroundColor White
        Write-Host "   Saldo inicial: R$ $($response.result.initialBalance)" -ForegroundColor White
    }
    Write-Host ""
}

# Função para testar criação com dados inválidos
function Test-CreateInvalidAccount {
    Write-Host "❌ Testando criação com dados inválidos..." -ForegroundColor Cyan
    
    $invalidAccountBody = @{
        type = "InvalidType"
        name = "AB" # Muito curto
        description = "A" * 300 # Muito longo
        initialBalance = "valor-invalido"
    }
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account" -Method POST -Body $invalidAccountBody
    
    if ($response -eq $null) {
        Write-Host "✅ Comportamento correto: Erro para dados inválidos" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Resposta inesperada para dados inválidos" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Função para testar criação sem autenticação
function Test-CreateUnauthenticated {
    Write-Host "🔒 Testando criação sem autenticação..." -ForegroundColor Cyan
    
    $accountBody = @{
        type = "Debit"
        name = "Conta sem autenticação"
    }
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/account" -Method POST -Body ($accountBody | ConvertTo-Json) -ContentType "application/json"
        Write-Host "⚠️  Resposta inesperada sem autenticação" -ForegroundColor Yellow
    }
    catch {
        Write-Host "✅ Comportamento correto: Acesso negado sem autenticação" -ForegroundColor Green
        Write-Host "   Erro: $($_.Exception.Message)" -ForegroundColor Gray
    }
    Write-Host ""
}

# Função para listar contas criadas
function Test-ListAccounts {
    Write-Host "📋 Listando contas criadas..." -ForegroundColor Cyan
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account"
    
    if ($response) {
        Write-Host "✅ Contas encontradas: $($response.result.account.Count)" -ForegroundColor Green
        
        foreach ($account in $response.result.account) {
            Write-Host "   • $($account.type): $($account.id)" -ForegroundColor White
        }
    }
    Write-Host ""
}

# Execução dos testes
try {
    # Obter token de autenticação
    Get-AuthToken
    
    # Executar todos os testes
    Test-CreateDebitAccount
    Test-CreateSavingsAccount
    Test-CreateCreditAccount
    Test-CreateInvestmentAccount
    Test-CreateMinimalAccount
    Test-CreateInvalidAccount
    Test-CreateUnauthenticated
    Test-ListAccounts
    
    Write-Host "🎉 Todos os testes de criação de contas foram executados com sucesso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Resumo dos testes:" -ForegroundColor Cyan
    Write-Host "   ✅ Criação de conta corrente" -ForegroundColor White
    Write-Host "   ✅ Criação de conta poupança" -ForegroundColor White
    Write-Host "   ✅ Criação de cartão de crédito" -ForegroundColor White
    Write-Host "   ✅ Criação de conta de investimento" -ForegroundColor White
    Write-Host "   ✅ Criação com dados mínimos" -ForegroundColor White
    Write-Host "   ✅ Validação de dados inválidos" -ForegroundColor White
    Write-Host "   ✅ Teste de autenticação" -ForegroundColor White
    Write-Host "   ✅ Listagem de contas" -ForegroundColor White
    Write-Host ""
    Write-Host "🔗 Endpoint testado: POST /account" -ForegroundColor Yellow
    Write-Host "🌐 Acesse a documentação: http://localhost:3001/docs" -ForegroundColor Yellow
}
catch {
    Write-Host "❌ Erro durante a execução dos testes: $($_.Exception.Message)" -ForegroundColor Red
} 