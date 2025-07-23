# Teste de Transação sem AccountId e Sistema de Saldo em Background
# Autor: Assistente
# Data: $(Get-Date)

Write-Host "🧪 TESTE: Transação sem AccountId e Sistema de Saldo em Background" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan

# Configurações
$baseUrl = "http://localhost:3001"
$token = ""

# Função para fazer requisições autenticadas
function Invoke-AuthenticatedRequest {
    param(
        [string]$Uri,
        [string]$Method = "GET",
        [object]$Body = $null
    )
    
    $headers = @{
        "Content-Type" = "application/json"
    }
    
    if ($token) {
        $headers["Authorization"] = "Bearer $token"
    }
    
    $params = @{
        Uri = $Uri
        Method = $Method
        Headers = $headers
    }
    
    if ($Body) {
        $params.Body = $Body | ConvertTo-Json -Depth 10
    }
    
    try {
        $response = Invoke-RestMethod @params
        return $response
    } catch {
        Write-Host "❌ Erro na requisição: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Resposta do servidor: $responseBody" -ForegroundColor Red
        }
        return $null
    }
}

# 1. Login para obter token
function Test-Login {
    Write-Host "🔐 Testando Login..." -ForegroundColor Yellow
    
    $loginData = @{
        email = "teste@fiap.com.br"
        password = "123456"
    }
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/auth/login" -Method "POST" -Body $loginData
    
    if ($response) {
        $script:token = $response.result.token
        Write-Host "✅ Login realizado com sucesso" -ForegroundColor Green
        Write-Host "   Token: $($token.Substring(0, 20))..." -ForegroundColor White
    } else {
        Write-Host "❌ Falha no login" -ForegroundColor Red
        exit 1
    }
}

# 2. Criar uma conta
function Test-CreateAccount {
    Write-Host "🏦 Testando Criação de Conta..." -ForegroundColor Yellow
    
    $accountData = @{
        type = "Debit"
        name = "Conta Teste Saldo"
        description = "Conta para teste do sistema de saldo"
        initialBalance = 1000
    }
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account" -Method "POST" -Body $accountData
    
    if ($response) {
        Write-Host "✅ Conta criada com sucesso" -ForegroundColor Green
        Write-Host "   ID: $($response.result.id)" -ForegroundColor White
        Write-Host "   Nome: $($response.result.name)" -ForegroundColor White
        Write-Host "   Saldo inicial: R$ $($response.result.initialBalance)" -ForegroundColor White
        return $response.result.id
    } else {
        Write-Host "❌ Falha ao criar conta" -ForegroundColor Red
        return $null
    }
}

# 3. Criar transação sem accountId
function Test-CreateTransactionWithoutAccountId {
    param([string]$accountId)
    
    Write-Host "💳 Testando Criação de Transação sem AccountId..." -ForegroundColor Yellow
    
    $transactionData = @{
        description = "Teste de transação sem accountId"
        amount = 150.50
        type = "expense"
        category = "Alimentação"
        account = "Conta Teste"
        date = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    }
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/transaction" -Method "POST" -Body $transactionData
    
    if ($response) {
        Write-Host "✅ Transação criada com sucesso" -ForegroundColor Green
        Write-Host "   ID: $($response.result.id)" -ForegroundColor White
        Write-Host "   Descrição: $($response.result.description)" -ForegroundColor White
        Write-Host "   Valor: R$ $($response.result.amount)" -ForegroundColor White
        Write-Host "   Tipo: $($response.result.type)" -ForegroundColor White
        Write-Host "   AccountId: $($response.result.accountId)" -ForegroundColor White
        return $response.result.id
    } else {
        Write-Host "❌ Falha ao criar transação" -ForegroundColor Red
        return $null
    }
}

# 4. Verificar saldo da conta
function Test-CheckBalance {
    param([string]$accountId)
    
    Write-Host "💰 Testando Verificação de Saldo..." -ForegroundColor Yellow
    
    Start-Sleep -Seconds 2  # Aguardar cálculo em background
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/balance/$accountId"
    
    if ($response) {
        Write-Host "✅ Saldo obtido com sucesso" -ForegroundColor Green
        Write-Host "   Saldo atual: R$ $($response.result.currentBalance)" -ForegroundColor White
        Write-Host "   Último cálculo: $($response.result.lastCalculatedAt)" -ForegroundColor White
        Write-Host "   Última transação: $($response.result.lastTransactionId)" -ForegroundColor White
    } else {
        Write-Host "❌ Falha ao obter saldo" -ForegroundColor Red
    }
}

# 5. Recalcular saldos
function Test-RecalculateBalances {
    Write-Host "🔄 Testando Recálculo de Saldos..." -ForegroundColor Yellow
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/balance/recalculate" -Method "POST"
    
    if ($response) {
        Write-Host "✅ Recálculo iniciado com sucesso" -ForegroundColor Green
        Write-Host "   Status: $($response.result.status)" -ForegroundColor White
        Write-Host "   Mensagem: $($response.result.message)" -ForegroundColor White
    } else {
        Write-Host "❌ Falha ao iniciar recálculo" -ForegroundColor Red
    }
}

# 6. Listar transações
function Test-ListTransactions {
    Write-Host "📋 Testando Listagem de Transações..." -ForegroundColor Yellow
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/transaction"
    
    if ($response) {
        Write-Host "✅ Transações listadas com sucesso" -ForegroundColor Green
        Write-Host "   Total de transações: $($response.result.transactions.Count)" -ForegroundColor White
        
        foreach ($transaction in $response.result.transactions) {
            Write-Host "   - $($transaction.description): R$ $($transaction.amount) ($($transaction.type))" -ForegroundColor White
            Write-Host "     AccountId: $($transaction.accountId)" -ForegroundColor Gray
        }
    } else {
        Write-Host "❌ Falha ao listar transações" -ForegroundColor Red
    }
}

# Executar testes
try {
    Test-Login
    $accountId = Test-CreateAccount
    
    if ($accountId) {
        Test-CreateTransactionWithoutAccountId -accountId $accountId
        Test-CheckBalance -accountId $accountId
        Test-RecalculateBalances
        Start-Sleep -Seconds 3  # Aguardar processamento
        Test-CheckBalance -accountId $accountId
        Test-ListTransactions
    }
    
    Write-Host "`n🎉 Todos os testes concluídos!" -ForegroundColor Green
    Write-Host "=" * 80 -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Erro durante os testes: $($_.Exception.Message)" -ForegroundColor Red
} 