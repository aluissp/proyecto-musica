const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const { db } = require('../conexion');

// passport.use('local.signinArtist', new LocalStrategy({
//    
// }));

// Artistas
passport.use('local.signupArtist', new LocalStrategy({
    usernameField: 'email',
    passwordField: 'password',
    passReqToCallback: true
}, async (req, artistmail, password, done) => {
    const { artista, pais } = req.body;

    const newArtist = [
        artista,
        artistmail,
        password,
        pais
    ]

    await db.query(`INSERT INTO
    artistas(seudonimo_art, email_art, contrasena_art, pais_art)
    VALUES ($1, $2, $3, $4)`, newArtist);

    const resultado = await db.query(`SELECT id_art FROM artistas WHERE email_art = $1`, [artistmail]);
    newArtist.id = resultado.rows[0].id_art;
    return done(null, newArtist);
}));

passport.serializeUser((art, done) => {
    done(null, art.id);
});

passport.deserializeUser(async (id, done) => {
    const consulta = await db.query('SELECT * FROM artistas WHERE id_art = $1', [id]);
    done(null, consulta.rows[0].id_art);
});