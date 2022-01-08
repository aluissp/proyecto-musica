const express = require('express'); // Importamos la libreria
const path = require('path');
const morgan = require('morgan');
const app = express();
const bodyParser = require('body-parser');
const exphbs = require('express-handlebars');

// Ajustes
const hbs = exphbs.create({
    defaultLayaout: 'main',
    layaoutsDir: path.join(app.get('views'), 'layaouts'),
    layaoutsDir: path.join(app.get('views'), 'partials'),
    // layaoutsDir: path.join(app.get('views'), 'links'),
    extname: '.hbs',
    helpers: require('./lib/handlebars')
});

app.set('port', process.env.PORT || '3000');
app.set('views', path.join(__dirname, './views'));
app.engine('.hbs', hbs.engine);
app.set('view engine', '.hbs');

// Middlewars
// Son funciones que se ejecutan antes de que vengan las peticiones del usuario (rutas del servidor)
app.use(morgan('dev'));
app.use(express.urlencoded({ extended: false }));
app.use(express.json());
// app.use(bodyParser.urlencoded({ extended: true }));
// app.use(bodyParser.json());

// Global variables
app.use((req, res, next) => {
    next();
});

// Rutas
const indexRoute = require('./routes/index').router;
const linksRoute = require('./routes/links').router;
const authRoute = require('./routes/autenticacion').router;

// Usando rutas
app.use('/', indexRoute);
app.use('/', authRoute);
app.use('/home', linksRoute);

// archivos
app.use(express.static(path.join(__dirname, 'public')));


app.listen(app.get('port'), () => {
    console.log(`Server started at port ${app.get('port')}`);
});

exports.app = app; 