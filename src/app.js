const express = require('express'); // Importamos la libreria
const path = require('path');
const app = express();
const bodyParser = require('body-parser');
const { Pool } = require('pg');

// Ajustes
const port = 3000;
const config = {
    user: 'postgres',
    host: 'localhost',
    password: '2002',
    database: 'musica_test',
    port: '5432'
}
const db = new Pool(config);

app.engine('html',require('ejs').renderFile); // Procesar todos lo archivos html con ejs
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, './views'));
app.set(db);
// app.use(bodyParser.json());


// middlewars


// Rutas
const indexRoute = require('./routes/index').router;
const loginRoute = require('./routes/login').router;

// Usando rutas
app.use(indexRoute);
app.use('/login', loginRoute);

// archivos
app.use(express.static(path.join(__dirname, 'public')));

// CREACION DE NUESTRA API
app.listen(port, () => {
    console.log(`Server started at port ${port}`);
});

exports.app = app; 