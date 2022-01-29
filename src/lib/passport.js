const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const { db } = require('../conexion');

passport.use('local.signin', new LocalStrategy({
    usernameField: 'email',
    passwordField: 'password',
    passReqToCallback: true
}, async (req, mail, password, done) => {

    const consultaArt = await db.query('SELECT * FROM artistas WHERE email_art = $1', [mail]);
    const consultaUs = await db.query('SELECT * FROM usuarios WHERE email_usu = $1', [mail]);
    const consultaAdmin = await db.query('SELECT * FROM administradores WHERE email_usu = $1',[mail]);
    const rowsArt = consultaArt.rows;
    const rowsUs = consultaUs.rows;
    const rowsAdmin = consultaAdmin.rows;
    // Artistas
    if (rowsArt.length > 0) {
        const art = rowsArt[0];
        if (art.contrasena_art === password) {
            art.id = art.id_art;
            done(null, art, req.flash('success', 'Bienvenido' + art.seudonimo_art));
        } else {
            done(null, false, req.flash('message', 'Contraseña invalida'));
        }
    } else if (rowsUs.length > 0) {
        const us = rowsUs[0];
        if (us.contrasena_usu === password) {
            us.id = us.id_usu;
            done(null, us, req.flash('success', 'Bienvenido ' + us.nombre_usu));
        } else {
            done(null, false, req.flash('message', 'Contraseña invalida'));
        }

    } else if (rowsAdmin.length > 0) {
        const admin = rowsAdmin[0];
        if (admin.contrasena_usu === password){
            admin.id = admin.id_adm;
            done(null, admin, req.flash('success', `Bienvenido `+ admin.nombres));
        } else {
            done(null, false, req.flash('message', 'Contraseña invalida'));
        }

    } else {
        done(null, false, req.flash('message', 'El usuario o artista no existe'));
    }

}));

// Artistas singup
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
    try {
        await db.query(`INSERT INTO
        artistas(seudonimo_art, email_art, contrasena_art, pais_art)
        VALUES ($1, $2, $3, $4)`, newArtist);

        const resultado = await db.query(`SELECT id_art FROM artistas WHERE email_art = $1`, [artistmail]);
        newArtist.id = resultado.rows[0].id_art;
        return done(null, newArtist);
    } catch (e) {
        console.log(e);
        return done(null, null);
    }
}));
// Usuarios singup
passport.use('local.signupUser', new LocalStrategy({
    usernameField: 'email',
    passwordField: 'password',
    passReqToCallback: true
}, async (req, usermail, password, done) => {
    const { nombre, apellido, date, genero } = req.body;

    const newUser = [
        nombre,
        apellido,
        usermail,
        password,
        date,
        genero
    ]
    try {
        await db.query(`INSERT INTO
        usuarios(id_usu, nombres, apellidos, email_usu, contrasena_usu, fecha_nacim, genero)
        VALUES ('usu-1',$1, $2, $3, $4, $5, $6)`, newUser);

        const resultado = await db.query(`SELECT id_usu FROM usuarios WHERE email_usu = $1`, [usermail]);
        newUser.id = resultado.rows[0].id_usu;
        return done(null, newUser);
    } catch (e) {
        console.log(e);
        return done(null, null);
    }
}));

passport.serializeUser((user, done) => {
    done(null, user.id);
});

passport.deserializeUser(async (id, done) => {
    const consultaArt = await db.query('SELECT * FROM artistas WHERE id_art = $1', [id]);
    const consultaUs = await db.query('SELECT * FROM usuarios WHERE id_usu = $1', [id]);
    const consultaAdmin = await db.query('SELECT * FROM administradores WHERE id_adm = $1', [id]);
    const rowsArt = consultaArt.rows;
    const rowsUs = consultaUs.rows;
    const rowsAdmin = consultaAdmin.rows;

    if (rowsArt.length > 0) {
        rowsArt[0].isArt = true;
        // console.log(rowsArt);
        done(null, rowsArt[0]);
    } else if (rowsUs.length > 0) {
        rowsUs[0].isUsu = true;
        // console.log(rowsUs);
        done(null, rowsUs[0]);
    } else if (rowsAdmin.length > 0){
        rowsAdmin[0].isAdmin = true;
        done(null, rowsAdmin[0]);
    }
});
