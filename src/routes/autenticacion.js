const express = require('express'); // Importamos la libreria
const router = express.Router();
const passport = require('passport');
const { isLoggedIn } = require('../lib/auth');
// ARTISTAS
// Autenticacion
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
    .get(isLoggedIn, (req, res) => {
        res.render('home');
    });

router.route('/logout')
    .get((req, res) => {
        req.logOut();
        res.redirect('/signinArtist');
    });

// Ingreso
router.route('/signinArtist')
    .get((req, res) => {
        res.render('auth/signin');
    })
    .post((req, res, next) => {
        passport.authenticate('local.signinArtist', {
            successRedirect: '/home/artist',
            failureRedirect: '/signinArtist',
            failureFlash: true
        })(req, res, next);
    });


// USUARIOS
// Autenticacion
router.route('/signup')
    .get((req, res) => { // Para renderizar la vista
        res.render('auth/signup');
    })
    .post((req, res) => { // Para obtener los datos de la vista
        res.send('recibido');
    });

exports.router = router;