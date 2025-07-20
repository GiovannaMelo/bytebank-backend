const fs = require('fs')
const path = require('path')
const multer = require('multer')

// Configuração do diretório de uploads
const UPLOAD_DIR = path.join(__dirname, '../../uploads')
const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'text/plain']
const MAX_FILE_SIZE = 5 * 1024 * 1024 // 5MB

// Criar diretório de uploads se não existir
if (!fs.existsSync(UPLOAD_DIR)) {
  fs.mkdirSync(UPLOAD_DIR, { recursive: true })
}

// Configuração do multer para upload
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, UPLOAD_DIR)
  },
  filename: (req, file, cb) => {
    // Gerar nome único para o arquivo
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9)
    const extension = path.extname(file.originalname)
    cb(null, `transaction-${uniqueSuffix}${extension}`)
  }
})

// Filtro para validar tipos de arquivo
const fileFilter = (req, file, cb) => {
  if (ALLOWED_TYPES.includes(file.mimetype)) {
    cb(null, true)
  } else {
    cb(new Error('Tipo de arquivo não permitido. Tipos aceitos: JPEG, PNG, GIF, PDF, TXT'), false)
  }
}

// Configuração do multer
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: MAX_FILE_SIZE
  }
})

/**
 * Salva informações do arquivo no banco de dados
 * @param {Object} file - Objeto do arquivo do multer
 * @param {string} transactionId - ID da transação
 * @returns {Object} - Informações do arquivo salvo
 */
function saveFileInfo(file, transactionId) {
  return {
    filename: file.filename,
    originalName: file.originalname,
    mimetype: file.mimetype,
    size: file.size,
    path: file.path,
    transactionId: transactionId,
    uploadDate: new Date()
  }
}

/**
 * Obtém o caminho completo do arquivo
 * @param {string} filename - Nome do arquivo
 * @returns {string} - Caminho completo
 */
function getFilePath(filename) {
  return path.join(UPLOAD_DIR, filename)
}

/**
 * Verifica se o arquivo existe
 * @param {string} filename - Nome do arquivo
 * @returns {boolean} - True se existe
 */
function fileExists(filename) {
  const filePath = getFilePath(filename)
  return fs.existsSync(filePath)
}

/**
 * Remove um arquivo
 * @param {string} filename - Nome do arquivo
 * @returns {boolean} - True se removido com sucesso
 */
function deleteFile(filename) {
  try {
    const filePath = getFilePath(filename)
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath)
      return true
    }
    return false
  } catch (error) {
    console.error('Erro ao deletar arquivo:', error)
    return false
  }
}

/**
 * Obtém informações do arquivo
 * @param {string} filename - Nome do arquivo
 * @returns {Object|null} - Informações do arquivo
 */
function getFileInfo(filename) {
  try {
    const filePath = getFilePath(filename)
    if (fs.existsSync(filePath)) {
      const stats = fs.statSync(filePath)
      return {
        filename,
        path: filePath,
        size: stats.size,
        created: stats.birthtime,
        modified: stats.mtime
      }
    }
    return null
  } catch (error) {
    console.error('Erro ao obter informações do arquivo:', error)
    return null
  }
}

/**
 * Gera URL para acesso ao arquivo
 * @param {string} filename - Nome do arquivo
 * @param {string} baseUrl - URL base da API
 * @returns {string} - URL completa
 */
function generateFileUrl(filename, baseUrl) {
  return `${baseUrl}/account/transaction/attachment/${filename}`
}

module.exports = {
  upload,
  saveFileInfo,
  getFilePath,
  fileExists,
  deleteFile,
  getFileInfo,
  generateFileUrl,
  UPLOAD_DIR,
  ALLOWED_TYPES,
  MAX_FILE_SIZE
} 