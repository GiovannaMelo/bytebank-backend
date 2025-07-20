/**
 * Utilitário para detectar automaticamente a categoria de uma transação
 * baseada na descrição/nome da transação
 */

// Palavras-chave para cada categoria
const categoryKeywords = {
  // Receitas
  'Salário': [
    'salario', 'salários', 'remuneracao', 'remuneração', 'pagamento', 'proventos',
    'ordenado', 'vencimento', 'contracheque', 'contra-cheque', 'holerite',
    '13º', '13 salario', '13º salário', 'ferias', 'férias', 'bonus', 'bônus',
    'comissao', 'comissão', 'premio', 'prêmio', 'gratificacao', 'gratificação'
  ],
  
  // Despesas Fixas
  'Despesas Fixas': [
    'luz', 'energia', 'eletrica', 'elétrica', 'eletricidade', 'conta de luz',
    'agua', 'água', 'agua e esgoto', 'água e esgoto', 'saneamento',
    'gas', 'gás', 'gas natural', 'gás natural', 'gas de cozinha', 'gás de cozinha',
    'internet', 'wi-fi', 'wifi', 'banda larga', 'fibra optica', 'fibra óptica',
    'telefone', 'celular', 'plano de celular', 'plano de telefone',
    'aluguel', 'rent', 'moradia', 'condominio', 'condomínio',
    'seguro', 'seguros', 'seguro auto', 'seguro carro', 'seguro casa',
    'previdencia', 'previdência', 'inss', 'contribuicao', 'contribuição'
  ],
  
  // Alimentação
  'Alimentação': [
    'supermercado', 'super mercado', 'mercado', 'feira', 'feira livre',
    'restaurante', 'restaurantes', 'lanche', 'lanches', 'fast food',
    'pizza', 'hamburguer', 'hambúrguer', 'sorvete', 'doces', 'chocolate',
    'cafe', 'café', 'cafezinho', 'café da manha', 'café da manhã',
    'almoco', 'almoço', 'janta', 'jantar', 'refeicao', 'refeição',
    'padaria', 'padarias', 'pao', 'pão', 'leite', 'queijo', 'carne'
  ],
  
  // Transporte
  'Transporte': [
    'uber', '99', 'taxi', 'táxi', 'cabify', 'lyft', 'passagem', 'passagens',
    'onibus', 'ônibus', 'metro', 'metrô', 'trem', 'trens', 'vlt',
    'combustivel', 'combustível', 'gasolina', 'etanol', 'diesel',
    'estacionamento', 'parking', 'pedagio', 'pedágio', 'ipva',
    'manutencao', 'manutenção', 'oleo', 'óleo', 'pneu', 'pneus',
    'lavagem', 'lavar carro', 'posto', 'posto de gasolina'
  ],
  
  // Saúde
  'Saúde': [
    'farmacia', 'farmácia', 'remedio', 'remédio', 'medicamento', 'medicamentos',
    'consulta', 'consultas', 'medico', 'médico', 'dentista', 'psicologo', 'psicólogo',
    'exame', 'exames', 'laboratorio', 'laboratório', 'hospital', 'clinica', 'clínica',
    'plano de saude', 'plano de saúde', 'unimed', 'amil', 'sulamerica', 'sulamérica',
    'acupuntura', 'fisioterapia', 'massagem', 'pilates', 'academia', 'gym'
  ],
  
  // Educação
  'Educação': [
    'escola', 'colégio', 'universidade', 'faculdade', 'curso', 'cursos',
    'mensalidade', 'matricula', 'matrícula', 'livro', 'livros', 'material escolar',
    'ingles', 'inglês', 'espanhol', 'francês', 'alemao', 'alemão',
    'musica', 'música', 'piano', 'violao', 'violão', 'guitarra',
    'teatro', 'danca', 'dança', 'ballet', 'balé', 'esporte', 'esportes'
  ],
  
  // Lazer
  'Lazer': [
    'cinema', 'teatro', 'show', 'shows', 'concerto', 'concertos',
    'bar', 'pub', 'balada', 'boate', 'discoteca', 'karaoke', 'karaokê',
    'viagem', 'viagens', 'hotel', 'hospedagem', 'passagem aerea', 'passagem aérea',
    'parque', 'parques', 'museu', 'museus', 'exposicao', 'exposição',
    'jogo', 'jogos', 'video game', 'videogame', 'netflix', 'spotify', 'youtube'
  ],
  
  // Vestuário
  'Vestuário': [
    'roupa', 'roupas', 'camisa', 'camisas', 'calca', 'calça', 'calças',
    'sapato', 'sapatos', 'tenis', 'tênis', 'bolsa', 'bolsas', 'mochila',
    'acessorio', 'acessórios', 'joia', 'joias', 'relogio', 'relógio',
    'perfume', 'cosmetico', 'cosméticos', 'maquiagem', 'cabelo', 'cabeleireiro'
  ],
  
  // Casa
  'Casa': [
    'moveis', 'móveis', 'eletrodomestico', 'eletrodomésticos', 'geladeira',
    'fogao', 'fogão', 'microondas', 'maquina de lavar', 'máquina de lavar',
    'aspirador', 'vassoura', 'rodo', 'detergente', 'sabao', 'sabão',
    'decoracao', 'decoração', 'cortina', 'cortinas', 'tapete', 'tapetes',
    'reforma', 'reformas', 'pintura', 'pintar', 'jardim', 'jardinagem'
  ],
  
  // Investimentos
  'Investimentos': [
    'acoes', 'ações', 'acao', 'ação', 'fii', 'fiis', 'fundos imobiliarios',
    'tesouro', 'cdb', 'lci', 'lca', 'poupanca', 'poupança', 'investimento',
    'cripto', 'bitcoin', 'ethereum', 'crypto', 'bolsa', 'b3', 'bovespa'
  ],
  
  // Outros
  'Outros': [
    'presente', 'presentes', 'doacao', 'doação', 'caridade', 'igreja',
    'imposto', 'impostos', 'iptu', 'iptu', 'iptr', 'multa', 'multas',
    'emprestimo', 'empréstimo', 'financiamento', 'cartao', 'cartão',
    'despesa', 'despesas', 'gasto', 'gastos', 'pagamento', 'pagamentos'
  ]
};

/**
 * Detecta a categoria baseada na descrição da transação
 * @param {string} description - Descrição da transação
 * @param {string} type - Tipo da transação ('income' ou 'expense')
 * @returns {string} - Categoria detectada
 */
function detectCategory(description, type = 'expense') {
  if (!description) return 'Outros';
  
  const desc = description.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
  
  // Para receitas, priorizar categorias de receita
  if (type === 'income') {
    // Verificar primeiro categorias de receita
    for (const [category, keywords] of Object.entries(categoryKeywords)) {
      if (category === 'Salário' || category === 'Investimentos') {
        for (const keyword of keywords) {
          if (desc.includes(keyword.toLowerCase())) {
            return category;
          }
        }
      }
    }
  }
  
  // Para despesas ou receitas não categorizadas, verificar todas as categorias
  for (const [category, keywords] of Object.entries(categoryKeywords)) {
    for (const keyword of keywords) {
      if (desc.includes(keyword.toLowerCase())) {
        return category;
      }
    }
  }
  
  // Categoria padrão baseada no tipo
  return type === 'income' ? 'Outros' : 'Despesas Fixas';
}

/**
 * Sugere categorias baseadas na descrição
 * @param {string} description - Descrição da transação
 * @param {string} type - Tipo da transação
 * @returns {Array} - Array de categorias sugeridas
 */
function suggestCategories(description, type = 'expense') {
  if (!description) return ['Outros'];
  
  const desc = description.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
  const suggestions = [];
  
  for (const [category, keywords] of Object.entries(categoryKeywords)) {
    for (const keyword of keywords) {
      if (desc.includes(keyword.toLowerCase())) {
        if (!suggestions.includes(category)) {
          suggestions.push(category);
        }
      }
    }
  }
  
  // Adicionar categoria padrão se não houver sugestões
  if (suggestions.length === 0) {
    suggestions.push(type === 'income' ? 'Outros' : 'Despesas Fixas');
  }
  
  return suggestions.slice(0, 3); // Retornar no máximo 3 sugestões
}

module.exports = {
  detectCategory,
  suggestCategories,
  categoryKeywords
}; 