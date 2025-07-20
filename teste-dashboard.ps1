# Script para testar endpoints de Dashboard
# Execute: .\teste-dashboard.ps1

Write-Host "=== TESTE DOS ENDPOINTS DE DASHBOARD ===" -ForegroundColor Green
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

# 1. Resumo Geral da Conta
function Test-AccountSummary {
    Write-Host "📊 Testando Resumo Geral da Conta..." -ForegroundColor Cyan
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/dashboard/summary"
    
    if ($response) {
        Write-Host "✅ Resumo carregado com sucesso!" -ForegroundColor Green
        Write-Host "   Total de Receitas: R$ $($response.result.totalIncome)" -ForegroundColor White
        Write-Host "   Total de Despesas: R$ $($response.result.totalExpense)" -ForegroundColor White
        Write-Host "   Saldo: R$ $($response.result.balance)" -ForegroundColor White
        Write-Host "   Total de Transações: $($response.result.transactionCount)" -ForegroundColor White
        Write-Host "   Dados Mensais: $($response.result.monthlyData.Count) meses" -ForegroundColor White
        Write-Host "   Categorias: $($response.result.categoryBreakdown.Count) categorias" -ForegroundColor White
    }
    Write-Host ""
}

# 2. Evolução do Saldo
function Test-BalanceEvolution {
    Write-Host "📈 Testando Evolução do Saldo..." -ForegroundColor Cyan
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/dashboard/balance-evolution?months=6"
    
    if ($response) {
        Write-Host "✅ Evolução carregada com sucesso!" -ForegroundColor Green
        Write-Host "   Pontos de evolução: $($response.result.balanceEvolution.Count)" -ForegroundColor White
        Write-Host "   Dados mensais: $($response.result.monthlyBalance.Count) meses" -ForegroundColor White
        
        if ($response.result.balanceEvolution.Count -gt 0) {
            $lastBalance = $response.result.balanceEvolution[-1].balance
            Write-Host "   Saldo atual: R$ $lastBalance" -ForegroundColor White
        }
    }
    Write-Host ""
}

# 3. Top Categorias de Gastos
function Test-TopExpenseCategories {
    Write-Host "🏆 Testando Top Categorias de Gastos..." -ForegroundColor Cyan
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/dashboard/top-expense-categories?limit=5"
    
    if ($response) {
        Write-Host "✅ Top categorias carregadas com sucesso!" -ForegroundColor Green
        Write-Host "   Categorias encontradas: $($response.result.topCategories.Count)" -ForegroundColor White
        
        foreach ($category in $response.result.topCategories) {
            Write-Host "   • $($category.category): R$ $($category.total)" -ForegroundColor White
        }
    }
    Write-Host ""
}

# 4. Transações Recentes
function Test-RecentTransactions {
    Write-Host "🕒 Testando Transações Recentes..." -ForegroundColor Cyan
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/dashboard/recent-transactions?limit=5"
    
    if ($response) {
        Write-Host "✅ Transações recentes carregadas com sucesso!" -ForegroundColor Green
        Write-Host "   Transações encontradas: $($response.result.recentTransactions.Count)" -ForegroundColor White
        
        foreach ($transaction in $response.result.recentTransactions) {
            $type = if ($transaction.type -eq "income") { "📈" } else { "📉" }
            Write-Host "   $type $($transaction.description): R$ $($transaction.amount) ($($transaction.category))" -ForegroundColor White
        }
    }
    Write-Host ""
}

# 5. Estatísticas por Período
function Test-PeriodStats {
    Write-Host "📅 Testando Estatísticas por Período..." -ForegroundColor Cyan
    
    # Teste para mês atual
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/dashboard/period-stats?period=month"
    
    if ($response) {
        Write-Host "✅ Estatísticas do mês carregadas com sucesso!" -ForegroundColor Green
        Write-Host "   Receitas do mês: R$ $($response.result.periodStats.income)" -ForegroundColor White
        Write-Host "   Despesas do mês: R$ $($response.result.periodStats.expense)" -ForegroundColor White
        Write-Host "   Saldo do mês: R$ $($response.result.periodStats.balance)" -ForegroundColor White
        Write-Host "   Transações do mês: $($response.result.periodStats.transactionCount)" -ForegroundColor White
        Write-Host "   Média por transação: R$ $($response.result.periodStats.averageTransaction)" -ForegroundColor White
    }
    Write-Host ""
}

# 6. Teste de diferentes períodos
function Test-DifferentPeriods {
    Write-Host "📊 Testando Diferentes Períodos..." -ForegroundColor Cyan
    
    $periods = @("month", "quarter", "year")
    
    foreach ($period in $periods) {
        Write-Host "   Testando período: $period" -ForegroundColor Yellow
        $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/dashboard/period-stats?period=$period"
        
        if ($response) {
            Write-Host "   ✅ $period - Receitas: R$ $($response.result.periodStats.income), Despesas: R$ $($response.result.periodStats.expense)" -ForegroundColor Green
        }
    }
    Write-Host ""
}

# Execução dos testes
try {
    # Obter token de autenticação
    Get-AuthToken
    
    # Executar todos os testes
    Test-AccountSummary
    Test-BalanceEvolution
    Test-TopExpenseCategories
    Test-RecentTransactions
    Test-PeriodStats
    Test-DifferentPeriods
    
    Write-Host "🎉 Todos os testes de Dashboard foram executados com sucesso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Resumo dos endpoints testados:" -ForegroundColor Cyan
    Write-Host "   • GET /dashboard/summary - Resumo geral da conta" -ForegroundColor White
    Write-Host "   • GET /dashboard/balance-evolution - Evolução do saldo" -ForegroundColor White
    Write-Host "   • GET /dashboard/top-expense-categories - Top categorias de gastos" -ForegroundColor White
    Write-Host "   • GET /dashboard/recent-transactions - Transações recentes" -ForegroundColor White
    Write-Host "   • GET /dashboard/period-stats - Estatísticas por período" -ForegroundColor White
    Write-Host ""
    Write-Host "🌐 Acesse a documentação: http://localhost:3001/docs" -ForegroundColor Yellow
}
catch {
    Write-Host "❌ Erro durante a execução dos testes: $($_.Exception.Message)" -ForegroundColor Red
} 