# Script para testar upload e download de anexos
Write-Host "=== Teste: Sistema de Anexos ===" -ForegroundColor Green

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

# 3. Criar transação para teste
Write-Host "`n3. Criando transação para teste..." -ForegroundColor Yellow
$createBody = @{
    accountId = $accountId
    description = "Transação com anexo"
    amount = 150
    type = "expense"
    category = "Teste"
} | ConvertTo-Json

$createResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction" -Method POST -Headers $headers -Body $createBody
$transactionId = $createResponse.result.id

Write-Host "✅ Transação criada: $transactionId" -ForegroundColor Green

# 4. Criar arquivo de teste
Write-Host "`n4. Criando arquivo de teste..." -ForegroundColor Yellow
$testContent = "Este é um arquivo de teste para anexo.`nCriado em: $(Get-Date)`nTransação: $transactionId"
$testFilePath = "teste-anexo.txt"
$testContent | Out-File -FilePath $testFilePath -Encoding UTF8

Write-Host "✅ Arquivo de teste criado: $testFilePath" -ForegroundColor Green

# 5. Upload do anexo
Write-Host "`n5. Fazendo upload do anexo..." -ForegroundColor Yellow

try {
    # Preparar headers para multipart/form-data
    $uploadHeaders = @{
        "Authorization" = "Bearer $token"
    }
    
    # Criar form data
    $form = @{
        file = Get-Item -Path $testFilePath
    }
    
    $uploadResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction/$transactionId/attachment" -Method POST -Headers $uploadHeaders -Form $form
    
    Write-Host "✅ Anexo enviado com sucesso!" -ForegroundColor Green
    Write-Host "   Nome original: $($uploadResponse.result.attachment.originalName)" -ForegroundColor Gray
    Write-Host "   Nome salvo: $($uploadResponse.result.attachment.filename)" -ForegroundColor Gray
    Write-Host "   Tamanho: $($uploadResponse.result.attachment.size) bytes" -ForegroundColor Gray
    Write-Host "   Tipo: $($uploadResponse.result.attachment.mimetype)" -ForegroundColor Gray
    
    $filename = $uploadResponse.result.attachment.filename
    
} catch {
    Write-Host "❌ Erro no upload: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Detalhes: $errorBody" -ForegroundColor Red
    }
}

# 6. Verificar transação atualizada
Write-Host "`n6. Verificando transação atualizada..." -ForegroundColor Yellow
$transactionResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction/$transactionId" -Method GET -Headers $headers

Write-Host "✅ Transação verificada:" -ForegroundColor Green
Write-Host "   Tem anexo: $($transactionResponse.result.transaction.anexo -ne $null)" -ForegroundColor Gray
if ($transactionResponse.result.transaction.anexo) {
    Write-Host "   Nome do anexo: $($transactionResponse.result.transaction.anexo.originalName)" -ForegroundColor Gray
    Write-Host "   Tamanho: $($transactionResponse.result.transaction.anexo.size) bytes" -ForegroundColor Gray
}

# 7. Download do anexo
Write-Host "`n7. Fazendo download do anexo..." -ForegroundColor Yellow

try {
    $downloadResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction/attachment/$filename" -Method GET -Headers $headers -OutFile "download-anexo.txt"
    
    Write-Host "✅ Anexo baixado com sucesso!" -ForegroundColor Green
    Write-Host "   Salvo como: download-anexo.txt" -ForegroundColor Gray
    
    # Verificar conteúdo
    $downloadedContent = Get-Content -Path "download-anexo.txt" -Raw
    Write-Host "   Conteúdo: $($downloadedContent.Substring(0, [Math]::Min(50, $downloadedContent.Length)))..." -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Erro no download: $($_.Exception.Message)" -ForegroundColor Red
}

# 8. Testar upload de imagem (se existir)
Write-Host "`n8. Testando upload de imagem..." -ForegroundColor Yellow

# Criar uma imagem simples (1x1 pixel PNG)
$pngBytes = [byte[]]@(0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0x99, 0x63, 0xF8, 0xCF, 0xCF, 0x00, 0x00, 0x03, 0x01, 0x01, 0x00, 0x18, 0xDD, 0x8D, 0xB0, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82)
$pngBytes | Out-File -FilePath "teste-imagem.png" -Encoding Byte

try {
    $form = @{
        file = Get-Item -Path "teste-imagem.png"
    }
    
    $imageResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/transaction/$transactionId/attachment" -Method POST -Headers $uploadHeaders -Form $form
    
    Write-Host "✅ Imagem enviada com sucesso!" -ForegroundColor Green
    Write-Host "   Nome: $($imageResponse.result.attachment.originalName)" -ForegroundColor Gray
    Write-Host "   Tipo: $($imageResponse.result.attachment.mimetype)" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Erro no upload da imagem: $($_.Exception.Message)" -ForegroundColor Red
}

# 9. Listar transações com anexos
Write-Host "`n9. Listando transações com anexos..." -ForegroundColor Yellow
$transactionsResponse = Invoke-RestMethod -Uri "http://localhost:3000/account/$accountId/statement" -Method GET -Headers $headers

$transactionsWithAttachments = $transactionsResponse.result.transactions | Where-Object { $_.anexo -ne $null }
Write-Host "✅ Transações com anexos encontradas: $($transactionsWithAttachments.Count)" -ForegroundColor Green

foreach ($transaction in $transactionsWithAttachments) {
    Write-Host "   - $($transaction.description): $($transaction.anexo.originalName)" -ForegroundColor Gray
}

# 10. Limpeza
Write-Host "`n10. Limpeza..." -ForegroundColor Yellow

# Remover arquivos de teste
if (Test-Path $testFilePath) { Remove-Item $testFilePath }
if (Test-Path "download-anexo.txt") { Remove-Item "download-anexo.txt" }
if (Test-Path "teste-imagem.png") { Remove-Item "teste-imagem.png" }

Write-Host "✅ Arquivos de teste removidos" -ForegroundColor Green

Write-Host "`n=== Teste de Anexos Concluído! ===" -ForegroundColor Green
Write-Host "`n📝 Notas para Angular:" -ForegroundColor Cyan
Write-Host "   - Use FormData para upload: new FormData().append('file', file)" -ForegroundColor Gray
Write-Host "   - Para exibir: <img [src]='apiUrl + /attachment/filename'>" -ForegroundColor Gray
Write-Host "   - Para download: window.open(apiUrl + /attachment/filename)" -ForegroundColor Gray 