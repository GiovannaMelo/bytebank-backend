const mongoose = require('mongoose');
const { Schema } = mongoose;

const CardSchema = new Schema({
  type: {
    type: String,
    required: true
  },
  is_blocked: {
    type: Boolean,
    default: false
  },
  number: {
    type: String,
    required: true
  },
  dueDate: {
    type: Date,
    required: true
  },
  functions: {
    type: String,
    required: true
  },
  cvc: {
    type: String,
    required: true
  },
  paymentDate: {
    type: Date,
  },
  name: {
    type: String,
    required: true
  },
  accountId: {
    type: Schema.Types.ObjectId,
    ref: 'Account',
    required: true
  }
}, { timestamps: true });

const AccountSchema = new Schema({
  type: {
    type: String,
    required: true
  },
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  name: {
    type: String,
    required: false,
    default: function() {
      return `${this.type} Account`
    }
  },
  description: {
    type: String,
    required: false,
    default: function() {
      return `Conta ${this.type}`
    }
  },
  initialBalance: {
    type: Number,
    default: 0
  }
}, { timestamps: true });

const DetailedAccountSchema = new Schema({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  date: {
    type: Date,
    required: true,
    default: Date.now
  },
  description: {
    type: String,
    required: true
  },
  amount: {
    type: Number,
    required: true
  },
  type: {
    type: String,
    enum: ['income', 'expense'],
    required: true
  },
  category: {
    type: String,
    required: false
  },
  account: {
    type: String,
    required: false
  },
  notes: {
    type: String,
    required: false
  },
  tags: [{
    type: String
  }],
  anexo: {
    type: String,
    required: false
  },
  accountId: {
    type: Schema.Types.ObjectId,
    ref: 'Account',
    required: true
  },
  // Campos mantidos para compatibilidade
  from: {
    type: String,
    required: false
  },
  to: {
    type: String,
    required: false
  },
  value: {
    type: Number,
    required: false
  }
}, { timestamps: true });

const InvestmentSchema = new Schema({
  type: {
    type: String,
    required: true
  },
  value: {
    type: Number,
    required: true
  },
  name: {
    type: String,
    required: true
  },
  accountId: {
    type: Schema.Types.ObjectId,
    ref: 'Account',
    required: true
  }
}, { timestamps: true });

const UserSchema = new Schema({
  username: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  password: {
    type: String,
    required: true,
    minlength: 6
  }
}, { timestamps: true });

// Definindo as relações virtuais
AccountSchema.virtual('cards', {
  ref: 'Card',
  localField: '_id',
  foreignField: 'accountId'
});

AccountSchema.virtual('investments', {
  ref: 'Investment',
  localField: '_id',
  foreignField: 'accountId'
});

AccountSchema.virtual('transactions', {
  ref: 'DetailedAccount',
  localField: '_id',
  foreignField: 'accountId'
});

UserSchema.virtual('accounts', {
  ref: 'Account',
  localField: '_id',
  foreignField: 'userId'
});

// Configurando as opções para que os virtuals sejam incluídos quando converter para JSON
const schemaOptions = {
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
};

AccountSchema.set(schemaOptions);
UserSchema.set(schemaOptions);

// Criando os modelos
const Card = mongoose.model('Card', CardSchema);
const Account = mongoose.model('Account', AccountSchema);
const DetailedAccount = mongoose.model('DetailedAccount', DetailedAccountSchema);
const Investment = mongoose.model('Investment', InvestmentSchema);
const User = mongoose.model('User', UserSchema);

module.exports = { Account, User, Investment, DetailedAccount, Card };