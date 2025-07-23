# Teste de Validação - AccountId Opcional
# Autor: Assistente
# Data: $(Get-Date)

Write-Host "🧪 TESTE: Validação AccountId Opcional" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

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
    } else {
        Write-Host "❌ Falha no login" -ForegroundColor Red
        exit 1
    }
}

# 2. Testar transação SEM accountId
function Test-TransactionWithoutAccountId {
    Write-Host "💳 Testando Transação SEM AccountId..." -ForegroundColor Yellow
    
    $transactionData = @{
        description = "Teste sem accountId"
        amount = 100.00
        type = "expense"
        category = "Teste"
        account = "Conta Teste"
        date = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    }
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/transaction" -Method "POST" -Body $transactionData
    
    if ($response) {
        Write-Host "✅ Transação criada SEM accountId com sucesso!" -ForegroundColor Green
        Write-Host "   ID: $($response.result.id)" -ForegroundColor White
        Write-Host "   Descrição: $($response.result.description)" -ForegroundColor White
        Write-Host "   AccountId: $($response.result.accountId)" -ForegroundColor White
        return $true
    } else {
        Write-Host "❌ Falha ao criar transação sem accountId" -ForegroundColor Red
        return $false
    }
}

# 3. Testar transação COM accountId (opcional)
function Test-TransactionWithAccountId {
    Write-Host "💳 Testando Transação COM AccountId (opcional)..." -ForegroundColor Yellow
    
    $transactionData = @{
        accountId = "507f1f77bcf86cd799439011" # ID fictício para teste
        description = "Teste com accountId"
        amount = 200.00
        type = "income"
        category = "Teste"
        account = "Conta Teste"
        date = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    }
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/transaction" -Method "POST" -Body $transactionData
    
    if ($response) {
        Write-Host "✅ Transação criada COM accountId com sucesso!" -ForegroundColor Green
        Write-Host "   ID: $($response.result.id)" -ForegroundColor White
        Write-Host "   AccountId: $($response.result.accountId)" -ForegroundColor White
        return $true
    } else {
        Write-Host "❌ Falha ao criar transação com accountId" -ForegroundColor Red
        return $false
    }
}

# 4. Testar transação com dados mínimos
function Test-TransactionMinimal {
    Write-Host "💳 Testando Transação com Dados Mínimos..." -ForegroundColor Yellow
    
    $transactionData = @{
        description = "Transação mínima"
        amount = 50.00
        type = "expense"
    }
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/transaction" -Method "POST" -Body $transactionData
    
    if ($response) {
        Write-Host "✅ Transação mínima criada com sucesso!" -ForegroundColor Green
        Write-Host "   ID: $($response.result.id)" -ForegroundColor White
        Write-Host "   AccountId: $($response.result.accountId)" -ForegroundColor White
        return $true
    } else {
        Write-Host "❌ Falha ao criar transação mínima" -ForegroundColor Red
        return $false
    }
}

# Executar testes
try {
    Test-Login
    
    $success1 = Test-TransactionWithoutAccountId
    $success2 = Test-TransactionWithAccountId
    $success3 = Test-TransactionMinimal
    
    Write-Host "`n📊 RESULTADOS DOS TESTES:" -ForegroundColor Cyan
    Write-Host "   Transação sem accountId: $(if($success1) {'✅ PASSOU'} else {'❌ FALHOU'})" -ForegroundColor $(if($success1) {'Green'} else {'Red'})
    Write-Host "   Transação com accountId: $(if($success2) {'✅ PASSOU'} else {'❌ FALHOU'})" -ForegroundColor $(if($success2) {'Green'} else {'Red'})
    Write-Host "   Transação mínima: $(if($success3) {'✅ PASSOU'} else {'❌ FALHOU'})" -ForegroundColor $(if($success3) {'Green'} else {'Red'})
    
    if ($success1 -and $success2 -and $success3) {
        Write-Host "`n🎉 TODOS OS TESTES PASSARAM! AccountId agora é opcional!" -ForegroundColor Green
    } else {
        Write-Host "`n⚠️ ALGUNS TESTES FALHARAM. Verifique as validações." -ForegroundColor Yellow
    }
    
    Write-Host "=" * 60 -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Erro durante os testes: $($_.Exception.Message)" -ForegroundColor Red
} 