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
        successRedirect: '/home',
        failureRedirect: '/signup/artist',
        failureFlash: true
    }));

router.route('/home')
    .get(isLoggedIn, (req, res) => {
        res.render('home');
    });

router.route('/logout')
    .get((req, res) => {
        req.logOut();
        res.redirect('/signin');
    });

// Ingreso Dual
router.route('/signin')
    .get((req, res) => {
        res.render('auth/signin');
    })
    .post((req, res, next) => {
        passport.authenticate('local.signin', {
            successRedirect: '/home',
            failureRedirect: '/signin',
            failureFlash: true
        })(req, res, next);
    });


// USUARIOS
// Autenticacion
router.route('/signup')
    .get((req, res) => { // Para renderizar la vista
        res.render('auth/signup');
    })
    .post(passport.authenticate('local.signupUser', {
        successRedirect: '/home',
        failureRedirect: '/signup',
        failureFlash: true
    }));

exports.router = router;