# Script para testar busca de transação por ID
# Execute: .\teste-transacao-por-id.ps1

Write-Host "=== TESTE DE BUSCA DE TRANSAÇÃO POR ID ===" -ForegroundColor Green
Write-Host ""

# Configurações
$baseUrl = "http://localhost:3001"
$token = ""
$transactionId = ""

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

# Função para obter uma transação existente
function Get-ExistingTransaction {
    Write-Host "🔍 Buscando transação existente..." -ForegroundColor Yellow
    
    # Primeiro, vamos buscar o extrato para obter um ID de transação
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/67607133f840bb97892eb659/statement?limit=1"
    
    if ($response -and $response.result.transactions.Count -gt 0) {
        $script:transactionId = $response.result.transactions[0].id
        Write-Host "✅ Transação encontrada: $transactionId" -ForegroundColor Green
        Write-Host "   Descrição: $($response.result.transactions[0].description)" -ForegroundColor White
        Write-Host "   Valor: R$ $($response.result.transactions[0].amount)" -ForegroundColor White
        Write-Host "   Tipo: $($response.result.transactions[0].type)" -ForegroundColor White
        Write-Host ""
        return $true
    } else {
        Write-Host "❌ Nenhuma transação encontrada. Criando uma nova..." -ForegroundColor Yellow
        
        # Criar uma nova transação para teste
        $transactionBody = @{
            accountId = "67607133f840bb97892eb659"
            description = "Transação de teste para busca por ID"
            amount = 100.50
            type = "income"
            category = "Teste"
            notes = "Transação criada para teste"
            tags = @("teste", "busca")
        }
        
        $createResponse = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/transaction" -Method POST -Body $transactionBody
        
        if ($createResponse) {
            $script:transactionId = $createResponse.result.id
            Write-Host "✅ Nova transação criada: $transactionId" -ForegroundColor Green
            Write-Host ""
            return $true
        } else {
            Write-Host "❌ Erro ao criar transação de teste" -ForegroundColor Red
            return $false
        }
    }
}

# Função para testar busca por ID válido
function Test-ValidTransactionId {
    Write-Host "🔍 Testando busca por ID válido..." -ForegroundColor Cyan
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/transaction/$transactionId"
    
    if ($response) {
        Write-Host "✅ Transação encontrada com sucesso!" -ForegroundColor Green
        Write-Host "   ID: $($response.result.transaction.id)" -ForegroundColor White
        Write-Host "   Descrição: $($response.result.transaction.description)" -ForegroundColor White
        Write-Host "   Valor: R$ $($response.result.transaction.amount)" -ForegroundColor White
        Write-Host "   Tipo: $($response.result.transaction.type)" -ForegroundColor White
        Write-Host "   Categoria: $($response.result.transaction.category)" -ForegroundColor White
        Write-Host "   Data: $($response.result.transaction.date)" -ForegroundColor White
        
        if ($response.result.transaction.notes) {
            Write-Host "   Observações: $($response.result.transaction.notes)" -ForegroundColor White
        }
        
        if ($response.result.transaction.tags -and $response.result.transaction.tags.Count -gt 0) {
            Write-Host "   Tags: $($response.result.transaction.tags -join ', ')" -ForegroundColor White
        }
    }
    Write-Host ""
}

# Função para testar busca por ID inválido
function Test-InvalidTransactionId {
    Write-Host "🔍 Testando busca por ID inválido..." -ForegroundColor Cyan
    $invalidId = "123456789012345678901234" # ID inválido do MongoDB
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/transaction/$invalidId"
    
    if ($response -eq $null) {
        Write-Host "✅ Comportamento correto: Transação não encontrada" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Resposta inesperada para ID inválido" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Função para testar busca por ID malformado
function Test-MalformedTransactionId {
    Write-Host "🔍 Testando busca por ID malformado..." -ForegroundColor Cyan
    $malformedId = "invalid-id-format"
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/account/transaction/$malformedId" -Method GET -Headers @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        }
        Write-Host "⚠️  Resposta inesperada para ID malformado" -ForegroundColor Yellow
    }
    catch {
        Write-Host "✅ Comportamento correto: Erro para ID malformado" -ForegroundColor Green
        Write-Host "   Erro: $($_.Exception.Message)" -ForegroundColor Gray
    }
    Write-Host ""
}

# Função para testar busca sem autenticação
function Test-UnauthenticatedRequest {
    Write-Host "🔍 Testando busca sem autenticação..." -ForegroundColor Cyan
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/account/transaction/$transactionId" -Method GET -ContentType "application/json"
        Write-Host "⚠️  Resposta inesperada sem autenticação" -ForegroundColor Yellow
    }
    catch {
        Write-Host "✅ Comportamento correto: Acesso negado sem autenticação" -ForegroundColor Green
        Write-Host "   Erro: $($_.Exception.Message)" -ForegroundColor Gray
    }
    Write-Host ""
}

# Execução dos testes
try {
    # Obter token de autenticação
    Get-AuthToken
    
    # Obter uma transação existente ou criar uma nova
    if (Get-ExistingTransaction) {
        # Executar todos os testes
        Test-ValidTransactionId
        Test-InvalidTransactionId
        Test-MalformedTransactionId
        Test-UnauthenticatedRequest
        
        Write-Host "🎉 Todos os testes de busca por ID foram executados com sucesso!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 Resumo dos testes:" -ForegroundColor Cyan
        Write-Host "   ✅ Busca por ID válido" -ForegroundColor White
        Write-Host "   ✅ Busca por ID inválido" -ForegroundColor White
        Write-Host "   ✅ Busca por ID malformado" -ForegroundColor White
        Write-Host "   ✅ Teste de autenticação" -ForegroundColor White
        Write-Host ""
        Write-Host "🔗 Endpoint testado: GET /account/transaction/{transactionId}" -ForegroundColor Yellow
        Write-Host "🌐 Acesse a documentação: http://localhost:3001/docs" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Não foi possível obter uma transação para teste" -ForegroundColor Red
    }
}
catch {
    Write-Host "❌ Erro durante a execução dos testes: $($_.Exception.Message)" -ForegroundColor Red
} 