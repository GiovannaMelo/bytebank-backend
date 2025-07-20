const { DetailedAccount } = require('../modelos');

const create = async (action) => {
    const detailedAccount = new DetailedAccount(action);
    return detailedAccount.save();
};

const getById = async (id) => {
  return DetailedAccount.findById(id);
};

const get = async (detailedAccount={}, options={}) => {
    const { pagination, count } = options;
    
    if (count) {
        return DetailedAccount.countDocuments(detailedAccount);
    }
    
    let query = DetailedAccount.find(detailedAccount);
    
    if (pagination) {
        const { skip, limit, sort } = pagination;
        if (skip !== undefined) query = query.skip(skip);
        if (limit !== undefined) query = query.limit(limit);
        if (sort) query = query.sort(sort);
    }
    
    return query.exec();
};

const update = async (id, updateData) => {
    console.log('Repository update - ID:', id);
    console.log('Repository update - Data:', updateData);
    
    // Verificar se o documento existe antes de atualizar
    const existingDoc = await DetailedAccount.findById(id);
    if (!existingDoc) {
        console.log('Documento não encontrado para atualização:', id);
        throw new Error(`Documento com ID ${id} não encontrado`);
    }
    
    const result = await DetailedAccount.findByIdAndUpdate(id, updateData, { new: true });
    console.log('Repository update - Resultado:', result);
    
    return result;
};

const deleteById = async (id) => {
    return DetailedAccount.findByIdAndDelete(id);
};

module.exports = {
  create,
  getById,
  get,
  update,
  deleteById
};