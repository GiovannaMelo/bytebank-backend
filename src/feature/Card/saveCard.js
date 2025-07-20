const CardModel = require("../../models/Card")

const saveCard = async ({
  card, repository
}) => {
  const resultado = await repository.create(card)
  return new CardModel(resultado.toJSON())
}

module.exports = saveCard