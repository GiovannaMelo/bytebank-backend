const User = require("../../models/User")

const getUser = async ({
  userFilter, repository
}) => {
  const result = await repository.get(userFilter)
  return result?.map(user => new User(user))
}

module.exports = getUser