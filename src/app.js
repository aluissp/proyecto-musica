const express = require('express'); // Importamos la libreria
const path = require('path');
const morgan = require('morgan');
const app = express();
const bodyParser = require('body-parser');

// Ajustes
const port = 3000;


app.engine('html', require('ejs').renderFile); // Procesar todos lo archivos html con ejs
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, './views'));


// middlewars
// Son funciones que se ejecutan antes de que vengan las peticiones del usuario (rutas del servidor)
app.use(morgan('dev'));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// Rutas
const indexRoute = require('./routes/index').router;
const loginRoute = require('./routes/login').router;

// Usando rutas
app.use('/login', loginRoute);
app.use('/home', indexRoute);

// archivos
app.use(express.static(path.join(__dirname, 'public')));


app.listen(port, () => {
    console.log(`Server started at port ${port}`);
});

exports.app = app; 