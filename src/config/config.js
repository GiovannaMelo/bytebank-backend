module.exports = {
  JWT_SECRET: process.env.JWT_SECRET || 'tech-challenge',
  PORT: process.env.PORT || 3001,
  MONGODB_URI: process.env.MONGODB_URI || 'mongodb://localhost:27017/tech-challenge',
  NODE_ENV: process.env.NODE_ENV || 'development',
  
  // Configurações de CORS
  CORS_ORIGIN: process.env.CORS_ORIGIN || '*',
  
  // Configurações de validação
  PASSWORD_MIN_LENGTH: 6,
  USERNAME_MIN_LENGTH: 3,
  USERNAME_MAX_LENGTH: 50,
  
  // Tipos de transação
  TRANSACTION_TYPES: {
    INCOME: 'income',
    EXPENSE: 'expense'
  },
  
  // Tipos de conta
  ACCOUNT_TYPES: {
    DEBIT: 'Debit',
    CREDIT: 'Credit'
  }
}; 