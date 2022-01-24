const express = require('express'); // Importamos la libreria
const path = require('path');
const morgan = require('morgan');
const app = express();
const exphbs = require('express-handlebars');
const flash = require('connect-flash');
const session = require('express-session');
const PgStore = require('connect-pg-simple')(session);
const { db } = require('./conexion');
const passport = require('passport');

require('./lib/passport');

// Ajustes
app.set('views', path.join(__dirname, './views'));
const hbs = exphbs.create({
    defaultLayout: 'main',
    layoutsDir: path.join(app.get('views'), 'layouts'),
    partialsDir: path.join(app.get('views'), 'partials'),
    extname: '.hbs',
    helpers: require('./lib/handlebars')
});

app.set('port', process.env.PORT || '3000');
app.engine('.hbs', hbs.engine);
app.set('view engine', '.hbs');

// Middlewars
// Crear sessiones de los usuarios
app.use(session({
    secret: 'luisnodesession',
    resave: false,
    saveUninitialized: false,
    store: new PgStore({
        pool: db
    })
}));
app.use(flash());
app.use(morgan('dev'));
app.use(express.urlencoded({ extended: false }));
app.use(express.json());
app.use(passport.initialize());
app.use(passport.session());
// app.use(bodyParser.urlencoded({ extended: true }));
// app.use(bodyParser.json());

// Global variables
app.use((req, res, next) => {
    app.locals.success_album = req.flash('success_album');
    app.locals.message_card = req.flash('message_card');
    app.locals.message_card_success = req.flash('message_card_success');
    app.locals.buy_art_success = req.flash('buy_art_success');
    app.locals.buy_art_fail = req.flash('buy_art_fail');
    app.locals.message = req.flash('message');
    app.locals.change_pass_success = req.flash('change_pass_success');
    app.locals.change_pass_fail = req.flash('change_pass_fail');
    app.locals.change_profile_success = req.flash('change_profile_success');
    app.locals.change_profile_fail = req.flash('change_profile_fail');
    // console.log('estoy en global');
    // console.log(req.user);
    app.locals.user = req.user;
    next();
});

// Rutas
const indexRoute = require('./routes/index').router;
const linksRoute = require('./routes/links').router;
const authRoute = require('./routes/autenticacion').router;
const profileArtRoute = require('./routes/profileArt').router;
const profileUsRoute = require('./routes/profileUs').router;

// Usando rutas
app.use('/', indexRoute);
app.use('/', authRoute);
app.use('/home', linksRoute);
app.use('/profile', profileArtRoute);
app.use('/profile', profileUsRoute);

// archivos
app.use(express.static(path.join(__dirname, 'public')));


app.listen(app.get('port'), () => {
    console.log(`Server started at port ${app.get('port')}`);
});

exports.app = app; 