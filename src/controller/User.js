const userDTO = require('../models/User')
const accountDTO = require('../models/Account')
const cardDTO = require('../models/Card')
const jwt = require('jsonwebtoken')
const config = require('../config/config')

class UserController {
  constructor(di = {}) {
    this.di = Object.assign({
      userRepository: require('../infra/mongoose/repository/userRepository'),
      accountRepository: require('../infra/mongoose/repository/accountRepository'),
      cardRepository: require('../infra/mongoose/repository/cardRepository'),

      saveCard: require('../feature/Card/saveCard'),
      salvarUsuario: require('../feature/User/salvarUsuario'),
      saveAccount: require('../feature/Account/saveAccount'),
      getUser: require('../feature/User/getUser'),
    }, di)
  }

  async create(req, res, next) {
    try {
      const user = new userDTO(req.body)
      const { userRepository, accountRepository, cardRepository, salvarUsuario, saveAccount, saveCard } = this.di

      if (!user.isValid()) {
        return res.status(400).json({ 'message': 'Dados do usuário inválidos' })
      }

      const userCreated = await salvarUsuario({
        user, repository: userRepository
      })

      const accountCreated = await saveAccount({ 
        account: new accountDTO({ userId: userCreated.id, type: 'Debit' }), 
        repository: accountRepository 
      })

      const firstCard = new cardDTO({ 
        type: 'GOLD',
        number: 13748712374891010,
        dueDate: '2027-01-07',
        functions: 'Debit',
        cvc: '505',
        paymentDate: null,
        name: userCreated.username,
        accountId: accountCreated.id,
        type: 'Debit' 
      })

      await saveCard({ card: firstCard, repository: cardRepository })

      res.status(201).json({
        message: 'Usuário criado com sucesso',
        result: userCreated,
      })
    } catch (error) {
      next(error)
    }
  }
  async find(req, res, next) {
    try {
      const { userRepository, getUser } = this.di
      const users = await getUser({ repository: userRepository })
      res.status(200).json({
        message: 'Usuários carregados com sucesso',
        result: users
      })
    } catch (error) {
      next(error)
    }
  }
  async auth(req, res, next) {
    try {
      const { userRepository, getUser } = this.di
      const { email, password } = req.body
      const user = await getUser({ repository: userRepository, userFilter: { email, password } })
      
      if (!user?.[0]) {
        return res.status(401).json({ message: 'Email ou senha inválidos' })
      }
      
      const userToTokenize = {...user[0], id: user[0].id.toString()}
      const token = jwt.sign(userToTokenize, config.JWT_SECRET, { expiresIn: '12h' })
      
      res.status(200).json({
        message: 'Usuário autenticado com sucesso',
        result: {
          token,
          id: user[0].id.toString()
        }
      })
    } catch (error) {
      next(error)
    }
  }
  static getToken(token) {
    try {
        if (!token) {
            return null;
        }
        const decoded = jwt.verify(token, config.JWT_SECRET)
        return decoded
    } catch (error) {
        console.log('Erro ao verificar token:', error.message);
        return null
    }
  }
}



module.exports = UserController