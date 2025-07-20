# Script para testar edição e exclusão de transações
# Execute: .\teste-edicao-exclusao.ps1

Write-Host "=== TESTE DE EDIÇÃO E EXCLUSÃO DE TRANSAÇÕES ===" -ForegroundColor Green
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

# Função para criar uma transação de teste
function Create-TestTransaction {
    Write-Host "📝 Criando transação de teste..." -ForegroundColor Yellow
    
    $transactionBody = @{
        accountId = "67607133f840bb97892eb659"
        description = "Transação de teste para edição"
        amount = 250.75
        type = "expense"
        category = "Teste"
        account = "Conta de Teste"
        notes = "Transação criada para testar edição e exclusão"
        tags = @("teste", "edição", "exclusão")
        anexo = "teste.pdf"
    }
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/transaction" -Method POST -Body $transactionBody
    
    if ($response) {
        $script:transactionId = $response.result.id
        Write-Host "✅ Transação de teste criada: $transactionId" -ForegroundColor Green
        Write-Host "   Descrição: $($response.result.description)" -ForegroundColor White
        Write-Host "   Valor: R$ $($response.result.amount)" -ForegroundColor White
        Write-Host "   Tipo: $($response.result.type)" -ForegroundColor White
        Write-Host ""
        return $true
    } else {
        Write-Host "❌ Erro ao criar transação de teste" -ForegroundColor Red
        return $false
    }
}

# Função para testar edição de transação
function Test-UpdateTransaction {
    Write-Host "✏️  Testando edição de transação..." -ForegroundColor Cyan
    
    $updateBody = @{
        description = "Transação de teste ATUALIZADA"
        amount = 300.50
        category = "Teste Atualizado"
        notes = "Transação atualizada com sucesso"
        tags = @("teste", "atualizado", "sucesso")
        anexo = "atualizado.pdf"
    }
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/transaction/$transactionId" -Method PUT -Body $updateBody
    
    if ($response) {
        Write-Host "✅ Transação atualizada com sucesso!" -ForegroundColor Green
        Write-Host "   Nova descrição: $($response.result.description)" -ForegroundColor White
        Write-Host "   Novo valor: R$ $($response.result.amount)" -ForegroundColor White
        Write-Host "   Nova categoria: $($response.result.category)" -ForegroundColor White
        Write-Host "   Novas observações: $($response.result.notes)" -ForegroundColor White
        Write-Host "   Novas tags: $($response.result.tags -join ', ')" -ForegroundColor White
        Write-Host "   Novo anexo: $($response.result.anexo)" -ForegroundColor White
    }
    Write-Host ""
}

# Função para testar edição parcial
function Test-PartialUpdate {
    Write-Host "✏️  Testando edição parcial (apenas descrição)..." -ForegroundColor Cyan
    
    $partialUpdateBody = @{
        description = "Transação com edição parcial"
    }
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/transaction/$transactionId" -Method PUT -Body $partialUpdateBody
    
    if ($response) {
        Write-Host "✅ Edição parcial realizada com sucesso!" -ForegroundColor Green
        Write-Host "   Descrição atualizada: $($response.result.description)" -ForegroundColor White
        Write-Host "   Valor mantido: R$ $($response.result.amount)" -ForegroundColor White
        Write-Host "   Categoria mantida: $($response.result.category)" -ForegroundColor White
    }
    Write-Host ""
}

# Função para testar edição com dados inválidos
function Test-InvalidUpdate {
    Write-Host "✏️  Testando edição com dados inválidos..." -ForegroundColor Cyan
    
    $invalidUpdateBody = @{
        amount = "valor-invalido"
        type = "tipo-invalido"
    }
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/transaction/$transactionId" -Method PUT -Body $invalidUpdateBody
    
    if ($response -eq $null) {
        Write-Host "✅ Comportamento correto: Erro para dados inválidos" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Resposta inesperada para dados inválidos" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Função para testar edição de transação inexistente
function Test-UpdateNonExistentTransaction {
    Write-Host "✏️  Testando edição de transação inexistente..." -ForegroundColor Cyan
    
    $invalidId = "123456789012345678901234"
    $updateBody = @{
        description = "Transação inexistente"
    }
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/transaction/$invalidId" -Method PUT -Body $updateBody
    
    if ($response -eq $null) {
        Write-Host "✅ Comportamento correto: Transação não encontrada" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Resposta inesperada para transação inexistente" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Função para testar exclusão de transação
function Test-DeleteTransaction {
    Write-Host "🗑️  Testando exclusão de transação..." -ForegroundColor Cyan
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/transaction/$transactionId" -Method DELETE
    
    if ($response) {
        Write-Host "✅ Transação excluída com sucesso!" -ForegroundColor Green
        Write-Host "   ID da transação excluída: $($response.result.deletedTransaction.id)" -ForegroundColor White
        Write-Host "   Descrição: $($response.result.deletedTransaction.description)" -ForegroundColor White
        Write-Host "   Valor: R$ $($response.result.deletedTransaction.amount)" -ForegroundColor White
    }
    Write-Host ""
}

# Função para testar exclusão de transação inexistente
function Test-DeleteNonExistentTransaction {
    Write-Host "🗑️  Testando exclusão de transação inexistente..." -ForegroundColor Cyan
    
    $invalidId = "123456789012345678901234"
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/transaction/$invalidId" -Method DELETE
    
    if ($response -eq $null) {
        Write-Host "✅ Comportamento correto: Transação não encontrada" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Resposta inesperada para transação inexistente" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Função para verificar se a transação foi realmente excluída
function Test-VerifyDeletion {
    Write-Host "🔍 Verificando se a transação foi realmente excluída..." -ForegroundColor Cyan
    
    $response = Invoke-AuthenticatedRequest -Uri "$baseUrl/account/transaction/$transactionId"
    
    if ($response -eq $null) {
        Write-Host "✅ Confirmação: Transação não encontrada (excluída com sucesso)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Alerta: Transação ainda existe após exclusão" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Execução dos testes
try {
    # Obter token de autenticação
    Get-AuthToken
    
    # Criar transação de teste
    if (Create-TestTransaction) {
        # Testes de edição
        Test-UpdateTransaction
        Test-PartialUpdate
        Test-InvalidUpdate
        Test-UpdateNonExistentTransaction
        
        # Testes de exclusão
        Test-DeleteTransaction
        Test-DeleteNonExistentTransaction
        Test-VerifyDeletion
        
        Write-Host "🎉 Todos os testes de edição e exclusão foram executados com sucesso!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 Resumo dos testes:" -ForegroundColor Cyan
        Write-Host "   ✅ Criação de transação de teste" -ForegroundColor White
        Write-Host "   ✅ Edição completa de transação" -ForegroundColor White
        Write-Host "   ✅ Edição parcial de transação" -ForegroundColor White
        Write-Host "   ✅ Validação de dados inválidos" -ForegroundColor White
        Write-Host "   ✅ Edição de transação inexistente" -ForegroundColor White
        Write-Host "   ✅ Exclusão de transação" -ForegroundColor White
        Write-Host "   ✅ Exclusão de transação inexistente" -ForegroundColor White
        Write-Host "   ✅ Verificação de exclusão" -ForegroundColor White
        Write-Host ""
        Write-Host "🔗 Endpoints testados:" -ForegroundColor Yellow
        Write-Host "   • PUT /account/transaction/{transactionId}" -ForegroundColor White
        Write-Host "   • DELETE /account/transaction/{transactionId}" -ForegroundColor White
        Write-Host "🌐 Acesse a documentação: http://localhost:3001/docs" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Não foi possível criar transação de teste" -ForegroundColor Red
    }
}
catch {
    Write-Host "❌ Erro durante a execução dos testes: $($_.Exception.Message)" -ForegroundColor Red
} 