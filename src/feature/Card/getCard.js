const CardModel = require("../../models/Card")

const getCard = async ({
  filter, repository
}) => {
  const result = await repository.get(filter)
  return result?.map(card => new CardModel(card.toJSON()))
}

module.exports = getCard