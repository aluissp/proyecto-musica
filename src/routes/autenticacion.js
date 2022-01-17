const express = require('express'); // Importamos la libreria
const router = express.Router();
const passport = require('passport');

// Autenticacion para artistas
router.route('/signup/artist')
    .get((req, res) => {
        res.render('auth/signupArtist');
    })
    .post(passport.authenticate('local.signupArtist', {
        successRedirect: '/home/artist',
        failureRedirect: '/signup/artist',
        failureFlash: true
    }));

router.route('/home/artist')
    .get((req, res) => {
        res.send('Este es tu home de artista');
    });

// Autenticacion para usuarios
router.route('/signup')
    .get((req, res) => { // Para renderizar la vista
        res.render('auth/signup');
    })
    .post((req, res) => { // Para obtener los datos de la vista
        res.send('recibido');
    });

router.route('/signin')
    .get((req, res) => {
        res.render('auth/signin');
    });

exports.router = router;