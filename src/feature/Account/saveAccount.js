const AccountModel = require("../../models/Account")

const saveAccount = async ({
  account, repository
}) => {
  const resultado = await repository.create(account)
  return new AccountModel(resultado.toJSON())
}

module.exports = saveAccount