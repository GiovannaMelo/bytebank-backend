const { Account } = require('../modelos');

const create = async (userData) => {
    const user = new Account(userData);
    return user.save();
};

const getById = async (id) => {
  return Account.findById(id);
};

const get = async (account={}) => {
    return Account.find(account);
};

module.exports = {
  create,
  getById,
  get
};