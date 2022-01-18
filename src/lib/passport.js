const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const { db } = require('../conexion');

passport.use('local.signinArtist', new LocalStrategy({
    usernameField: 'email',
    passwordField: 'password',
    passReqToCallback: true
}, async (req, artistmail, password, done) => {

    const consulta = await db.query('SELECT * FROM artistas WHERE email_art = $1', [artistmail]);
    const rows = consulta.rows;
    if (rows.length > 0) {
        const art = rows[0];
        if (art.contrasena_art === password) {
            // const art_id = []
            art.id = art.id_art;
            art.seudonimo = art.seudonimo_art;
            art.email = art.email_art;
            done(null, art, req.flash('success', 'Bienvenido' + art.seudonimo_art));
        } else {
            done(null, false, req.flash('message', 'Contraseña invalida'));
        }
    } else {
        done(null, false, req.flash('message', 'El artista no existe'));
    }

}));

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
    newArtist.seudonimo = artista;
    newArtist.email = artistmail;
    return done(null, newArtist);
}));

passport.serializeUser((user, done) => {
    done(null, user.id);
});

passport.deserializeUser(async (id, done) => {
    const consulta = await db.query('SELECT * FROM artistas WHERE id_art = $1', [id]);
    done(null, consulta.rows[0]);
});