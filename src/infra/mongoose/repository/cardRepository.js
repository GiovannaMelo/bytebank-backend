const { Card } = require('../modelos');

const create = async (userData) => {
    const card = new Card(userData);
    return card.save();
};

const getById = async (id) => {
  return Card.findById(id);
};

const get = async (card={}) => {
    return Card.find(card);
};

module.exports = {
  create,
  getById,
  get
};