# 🏷️ Sistema de Categorização Automática

## 📋 Visão Geral

O sistema de categorização automática detecta automaticamente a categoria de uma transação baseada na descrição/nome da transação. Isso melhora significativamente a experiência do usuário, eliminando a necessidade de categorizar manualmente cada transação.

## 🎯 Como Funciona

### 1. **Detecção Automática**
- Analisa a descrição da transação
- Compara com palavras-chave pré-definidas
- Atribui a categoria mais apropriada
- Considera o tipo da transação (receita/despesa)

### 2. **Palavras-chave por Categoria**

#### 💰 **Salário** (Receitas)
- `salario`, `remuneracao`, `pagamento`, `proventos`
- `13º`, `ferias`, `bonus`, `comissao`, `premio`
- `contracheque`, `holerite`, `vencimento`

#### 🏠 **Despesas Fixas**
- `luz`, `energia`, `agua`, `gas`, `internet`
- `telefone`, `aluguel`, `condominio`, `seguro`
- `previdencia`, `inss`, `contribuicao`

#### 🍽️ **Alimentação**
- `supermercado`, `mercado`, `feira`, `restaurante`
- `lanche`, `pizza`, `hamburguer`, `cafe`, `almoco`
- `padaria`, `pao`, `leite`, `carne`

#### 🚗 **Transporte**
- `uber`, `99`, `taxi`, `onibus`, `metro`, `trem`
- `combustivel`, `gasolina`, `estacionamento`
- `pedagio`, `ipva`, `manutencao`, `oleo`

#### 🏥 **Saúde**
- `farmacia`, `remedio`, `consulta`, `medico`
- `dentista`, `exame`, `laboratorio`, `hospital`
- `plano de saude`, `unimed`, `amil`

#### 📚 **Educação**
- `escola`, `universidade`, `faculdade`, `curso`
- `mensalidade`, `matricula`, `livro`, `material escolar`
- `ingles`, `musica`, `teatro`, `esporte`

#### 🎉 **Lazer**
- `cinema`, `teatro`, `show`, `concerto`
- `bar`, `pub`, `balada`, `viagem`, `hotel`
- `parque`, `museu`, `jogo`, `netflix`

#### 👕 **Vestuário**
- `roupa`, `camisa`, `calca`, `sapato`, `tenis`
- `bolsa`, `acessorio`, `joia`, `relogio`
- `perfume`, `cosmetico`, `maquiagem`

#### 🏡 **Casa**
- `moveis`, `eletrodomestico`, `geladeira`, `fogao`
- `microondas`, `aspirador`, `detergente`
- `decoracao`, `cortina`, `reforma`

#### 📈 **Investimentos**
- `acoes`, `fii`, `tesouro`, `cdb`, `lci`
- `poupanca`, `investimento`, `cripto`, `bitcoin`
- `bolsa`, `b3`, `bovespa`

#### 📦 **Outros**
- `presente`, `doacao`, `imposto`, `multa`
- `emprestimo`, `financiamento`, `cartao`

## 🔧 Funcionalidades

### 1. **Criação de Transação**
```javascript
// Categoria detectada automaticamente
{
  "accountId": "123",
  "description": "Salário da empresa",
  "amount": 5000,
  "type": "income"
  // category será "Salário" automaticamente
}
```

### 2. **Atualização de Transação**
```javascript
// Se a descrição for alterada, a categoria é recalculada
{
  "description": "Nova descrição: Uber para aeroporto"
  // category será "Transporte" automaticamente
}
```

### 3. **Sugestões de Categoria**
```javascript
GET /account/category-suggestions?description=Salário mensal&type=income

// Resposta:
{
  "detectedCategory": "Salário",
  "suggestions": ["Salário", "Outros"],
  "description": "Salário mensal",
  "type": "income"
}
```

## 🚀 Como Usar

### **1. Criação Automática**
```bash
# A categoria será detectada automaticamente
curl -X POST http://localhost:3000/account/transaction \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "accountId": "123",
    "description": "Conta de luz",
    "amount": 150,
    "type": "expense"
  }'
```

### **2. Obter Sugestões**
```bash
# Obter sugestões antes de criar
curl -X GET "http://localhost:3000/account/category-suggestions?description=Supermercado&type=expense" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### **3. Teste Completo**
```powershell
# Execute o script de teste
.\teste-categorizacao-automatica.ps1
```

## 📊 Exemplos de Categorização

| Descrição | Tipo | Categoria Detectada |
|-----------|------|-------------------|
| "Salário da empresa" | income | Salário |
| "Conta de luz" | expense | Despesas Fixas |
| "Supermercado Extra" | expense | Alimentação |
| "Uber para trabalho" | expense | Transporte |
| "Consulta médica" | expense | Saúde |
| "Mensalidade faculdade" | expense | Educação |
| "Cinema com amigos" | expense | Lazer |
| "Roupa nova" | expense | Vestuário |
| "Geladeira nova" | expense | Casa |
| "Dividendos ações" | income | Investimentos |

## ⚙️ Configuração

### **Adicionar Novas Palavras-chave**
Edite o arquivo `src/utils/categoryDetector.js`:

```javascript
const categoryKeywords = {
  'Nova Categoria': [
    'palavra1', 'palavra2', 'palavra3'
  ],
  // ... outras categorias
}
```

### **Personalizar Categorias**
```javascript
// Modificar a função detectCategory para lógica customizada
function detectCategory(description, type = 'expense') {
  // Sua lógica personalizada aqui
}
```

## 🎯 Benefícios

1. **Experiência do Usuário**: Categorização automática sem esforço
2. **Consistência**: Categorias padronizadas
3. **Eficiência**: Menos tempo categorizando transações
4. **Flexibilidade**: Permite override manual quando necessário
5. **Inteligência**: Aprende com padrões de descrição

## 🔍 Debug e Logs

O sistema inclui logs detalhados:

```javascript
console.log('Categoria detectada:', detectedCategory)
console.log('Sugestões de categoria:', categorySuggestions)
```

## 📝 Notas Importantes

- **Case Insensitive**: A detecção não diferencia maiúsculas/minúsculas
- **Acentos**: Remove acentos para melhor matching
- **Override Manual**: Se uma categoria for fornecida, ela tem prioridade
- **Fallback**: Categoria padrão se nenhuma palavra-chave for encontrada
- **Performance**: Matching rápido com arrays de palavras-chave

## 🧪 Testes

Execute os testes para verificar o funcionamento:

```powershell
# Teste completo
.\teste-categorizacao-automatica.ps1

# Teste específico
.\teste-correcao-id.ps1
```

---

**🎉 Sistema de Categorização Automática implementado com sucesso!** 