const User = require("../../models/User")

const saveUser = async ({
  user, repository
}) => {
  const resultado = await repository.create(user)
  return new User(resultado.toJSON())
}

module.exports = saveUser