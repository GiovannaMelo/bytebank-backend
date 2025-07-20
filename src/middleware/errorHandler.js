const errorHandler = (err, req, res, next) => {
  console.error('Erro:', err);

  // Erro de validação do Mongoose
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      message: 'Erro de validação',
      errors: Object.values(err.errors).map(e => e.message)
    });
  }

  // Erro de duplicação (ex: email já existe)
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue)[0];
    return res.status(400).json({
      message: `${field} já existe no sistema`
    });
  }

  // Erro de JWT
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({
      message: 'Token inválido'
    });
  }

  // Erro de JWT expirado
  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({
      message: 'Token expirado'
    });
  }

  // Erro padrão
  console.error('Erro completo:', {
    message: err.message,
    stack: err.stack,
    name: err.name,
    code: err.code
  });
  
  res.status(500).json({
    message: 'Erro interno do servidor',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
};

module.exports = errorHandler; 