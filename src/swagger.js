const swaggerJsdoc = require('swagger-jsdoc');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'API de Contas',
      version: '1.0.0',
      description: 'Documentação da API de Contas',
    },
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        }
    
      }
    },
    security: [
      {
        BearerAuth: [], // Define que toda rota utilizará este esquema como padrão
      },
    ],
    servers: [
      {
        url: 'http://localhost:3000',
        description: 'Servidor de Desenvolvimento',
      },
    ],
  },
  apis: ['./src/routes.js', './src/publicRoutes.js'], // arquivos que contêm anotações do swagger
};

const specs = swaggerJsdoc(options);
module.exports = specs;