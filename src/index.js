const express = require('express');
const publicRoutes = require('./publicRoutes');
const routes = require('./routes');
const dashboardRoutes = require('./dashboardRoutes');
const connectDB = require('./infra/mongoose/mongooseConect');
const swaggerUi = require('swagger-ui-express');
const swaggerDocs = require('./swagger');
const UserController = require('./controller/User');
const cors = require('cors');
const errorHandler = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.use(cors({
    origin: '*'
}));

app.use(publicRoutes);
app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));

// Middleware de autenticação para rotas protegidas
app.use(['/dashboard', '/account', '/user'], (req, res, next) => {
    // Pular autenticação para rotas públicas
    if (req.url.includes('/docs') || req.url.includes('/auth') || req.method === 'POST' && req.url === '/user') {
        return next();
    }

    const authHeader = req.headers['authorization'];
    if (!authHeader) {
        return res.status(401).json({ message: 'Token de autorização não fornecido' });
    }

    const [bearer, token] = authHeader.split(' ');
    if (bearer !== 'Bearer' || !token) {
        return res.status(401).json({ message: 'Formato de token inválido' });
    }

    const user = UserController.getToken(token);
    if (!user) {
        return res.status(401).json({ message: 'Token inválido ou expirado' });
    }

    req.user = user;
    next();
});

app.use('/dashboard', dashboardRoutes);
app.use(routes);

// Middleware de tratamento de erros (deve ser o último)
app.use(errorHandler);

connectDB().then(() => {
    app.listen(PORT, () => {
        console.log(`Servidor rodando na porta ${PORT}`);
    });
});

module.exports = app;
