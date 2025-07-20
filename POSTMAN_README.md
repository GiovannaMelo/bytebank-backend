# 📮 Guia de Uso - Collection Postman

Este guia explica como importar e usar a collection do Postman para testar a API do Tech Challenge 2.

## 📋 Arquivos Incluídos

- `tech-challenge-2.postman_collection.json` - Collection principal com todos os endpoints
- `tech-challenge-2.postman_environment.json` - Arquivo de ambiente com variáveis
- `POSTMAN_README.md` - Este guia de instruções

## 🚀 Como Importar

### 1. Importar a Collection
1. Abra o Postman
2. Clique em **"Import"** (botão no canto superior esquerdo)
3. Arraste o arquivo `tech-challenge-2.postman_collection.json` ou clique em **"Upload Files"**
4. Clique em **"Import"**

### 2. Importar o Environment
1. Clique em **"Import"** novamente
2. Arraste o arquivo `tech-challenge-2.postman_environment.json`
3. Clique em **"Import"**

### 3. Selecionar o Environment
1. No canto superior direito, clique no dropdown de environments
2. Selecione **"Tech Challenge 2 - Environment"**

## 🔧 Configuração Inicial

### Variáveis do Environment
A collection usa as seguintes variáveis que são preenchidas automaticamente:

- `baseUrl`: URL base da API (localhost:3001)
- `token`: Token JWT de autenticação (preenchido automaticamente)
- `userId`: ID do usuário logado (preenchido automaticamente)
- `accountId`: ID da conta criada (preenchido automaticamente)
- `transactionId`: ID da transação criada (preenchido automaticamente)
- `testEmail`: Email para testes (teste@gmail.com)
- `testPassword`: Senha para testes (testes)

## 📚 Estrutura da Collection

### 🔐 Autenticação
- **Criar Usuário**: Registra um novo usuário
- **Login (Obter Token)**: Faz login e salva o token automaticamente
- **Buscar Usuários**: Lista todos os usuários

### 🏦 Contas
- **Criar Conta**: Cria uma nova conta (salva o ID automaticamente)
- **Buscar Contas**: Lista todas as contas do usuário

### 💳 Transações
- **Criar Transação**: Cria uma nova transação (salva o ID automaticamente)
- **Buscar Transação por ID**: Busca uma transação específica
- **Atualizar Transação**: Edita uma transação existente
- **Excluir Transação**: Remove uma transação

### 📊 Extratos e Relatórios
- **Buscar Extrato com Paginação**: Lista transações com paginação
- **Buscar Transações por Categoria**: Filtra transações por categoria

### 📈 Dashboard
- **Resumo Geral da Conta**: Estatísticas gerais
- **Evolução do Saldo**: Dados para gráficos de linha
- **Top Categorias de Gastos**: Ranking de gastos por categoria
- **Transações Recentes**: Últimas transações
- **Estatísticas por Período**: Dados filtrados por tempo

### 🔧 Utilitários
- **Documentação Swagger**: Acesso à documentação da API
- **Health Check**: Verifica se a API está funcionando

## 🎯 Fluxo de Teste Recomendado

### 1. Preparação
```bash
# Inicie o servidor
npm run dev
```

### 2. Sequência de Testes
1. **Criar Usuário** (se necessário)
2. **Login (Obter Token)** - ⚠️ **OBRIGATÓRIO** - Salva o token automaticamente
3. **Criar Conta** - Salva o accountId automaticamente
4. **Criar Transação** - Salva o transactionId automaticamente
5. **Testar outros endpoints** - Usam os IDs salvos automaticamente

### 3. Testes de Dashboard
Após criar algumas transações, teste os endpoints de dashboard:
1. **Resumo Geral da Conta**
2. **Evolução do Saldo**
3. **Top Categorias de Gastos**
4. **Transações Recentes**
5. **Estatísticas por Período**

## 🔄 Scripts Automáticos

A collection inclui scripts que executam automaticamente:

### Login (Obter Token)
```javascript
// Salva o token automaticamente após login
if (pm.response.code === 200) {
    const response = pm.response.json();
    pm.collectionVariables.set('token', response.result.token);
    pm.collectionVariables.set('userId', response.result.id);
}
```

### Criar Conta
```javascript
// Salva o accountId automaticamente
if (pm.response.code === 201) {
    const response = pm.response.json();
    pm.collectionVariables.set('accountId', response.result.id);
}
```

### Criar Transação
```javascript
// Salva o transactionId automaticamente
if (pm.response.code === 201) {
    const response = pm.response.json();
    pm.collectionVariables.set('transactionId', response.result.id);
}
```

## 📝 Exemplos de Uso

### Criar Conta Corrente
```json
{
    "type": "Debit",
    "name": "Conta Principal",
    "description": "Conta corrente para uso diário",
    "initialBalance": 1000
}
```

### Criar Transação de Receita
```json
{
    "accountId": "{{accountId}}",
    "description": "Salário mensal",
    "amount": 5000,
    "type": "income",
    "category": "Salário",
    "notes": "Salário do mês de dezembro",
    "tags": ["salário", "renda"]
}
```

**Nota**: O `userId` é automaticamente obtido do token de autenticação, não precisa ser enviado no body.

### Criar Transação de Despesa
```json
{
    "accountId": "{{accountId}}",
    "description": "Compras no supermercado",
    "amount": 150.50,
    "type": "expense",
    "category": "Alimentação",
    "notes": "Compras semanais",
    "tags": ["alimentação", "supermercado"]
}
```

### Atualizar Transação
```json
{
    "description": "Salário mensal atualizado",
    "amount": 5500,
    "category": "Salário",
    "notes": "Salário do mês de dezembro com reajuste",
    "tags": ["salário", "renda", "reajuste"]
}
```

**Nota**: Na atualização, não é necessário enviar `accountId` - apenas os campos que deseja atualizar.

## 🎨 Recursos Visuais

### Ícones na Collection
- 🔐 Autenticação
- 🏦 Contas
- 💳 Transações
- 📊 Extratos e Relatórios
- 📈 Dashboard
- 🔧 Utilitários

### Cores de Status
- 🟢 200-299: Sucesso
- 🟡 300-399: Redirecionamento
- 🔴 400-499: Erro do cliente
- 🔴 500-599: Erro do servidor

## 🚨 Troubleshooting

### Token Expirado
Se receber erro 401 (Unauthorized):
1. Execute **"Login (Obter Token)"** novamente
2. O token será atualizado automaticamente

### IDs Não Salvos
Se os IDs não estiverem sendo salvos:
1. Verifique se o environment está selecionado
2. Execute os endpoints na ordem correta
3. Verifique o console do Postman para mensagens de erro

### Servidor Não Responde
Se receber erro de conexão:
1. Verifique se o servidor está rodando (`npm run dev`)
2. Confirme se a porta 3001 está correta
3. Verifique se não há firewall bloqueando

## 📞 Suporte

Para dúvidas ou problemas:
1. Verifique a documentação Swagger: `http://localhost:3001/docs`
2. Consulte o README principal do projeto
3. Execute os scripts PowerShell de teste

## 🎉 Pronto para Usar!

Agora você tem uma collection completa e funcional para testar todos os endpoints da API. Basta seguir o fluxo recomendado e aproveitar os recursos automáticos! 