const Joi = require('joi');

const validate = (schema) => {
  return (req, res, next) => {
    const { error } = schema.validate(req.body);
    if (error) {
      return res.status(400).json({
        message: 'Dados inválidos',
        errors: error.details.map(detail => detail.message)
      });
    }
    next();
  };
};

// Schemas de validação
const userSchema = Joi.object({
  username: Joi.string().min(3).max(50).required(),
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required()
});

const authSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required()
});

const transactionSchema = Joi.object({
  accountId: Joi.string().required(),
  description: Joi.string().required(),
  amount: Joi.number().positive().required(),
  type: Joi.string().valid('income', 'expense').required(),
  category: Joi.string().optional(),
  account: Joi.string().optional(),
  notes: Joi.string().optional(),
  tags: Joi.array().items(Joi.string()).optional(),
  anexo: Joi.string().optional(),
  // Campos mantidos para compatibilidade
  from: Joi.string().optional(),
  to: Joi.string().optional(),
  value: Joi.number().optional()
});

const transactionUpdateSchema = Joi.object({
  description: Joi.string().optional(),
  amount: Joi.number().positive().optional(),
  type: Joi.string().valid('income', 'expense').optional(),
  category: Joi.string().optional(),
  account: Joi.string().optional(),
  notes: Joi.string().optional(),
  tags: Joi.array().items(Joi.string()).optional(),
  anexo: Joi.string().optional(),
  // Campos mantidos para compatibilidade
  from: Joi.string().optional(),
  to: Joi.string().optional(),
  value: Joi.number().optional()
});

const accountSchema = Joi.object({
  type: Joi.string().valid('Debit', 'Credit', 'Savings', 'Investment').required(),
  name: Joi.string().min(3).max(50).optional(),
  description: Joi.string().max(200).optional(),
  initialBalance: Joi.number().default(0).optional()
});

module.exports = {
  validate,
  userSchema,
  authSchema,
  transactionSchema,
  transactionUpdateSchema,
  accountSchema
}; 