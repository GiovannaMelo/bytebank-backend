const DetailedAccountModel = require("../../models/DetailedAccount")

const getTransaction = async ({
  filter, repository, pagination, count
}) => {
  const options = { pagination, count }
  const result = await repository.get(filter, options)
  
  if (count) {
    return result
  }
  
  return result?.map(transaction => new DetailedAccountModel(transaction))
}

module.exports = getTransaction 