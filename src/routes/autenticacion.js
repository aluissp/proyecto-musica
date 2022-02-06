const express = require('express'); // Importamos la libreria
const router = express.Router();
const passport = require('passport');
const { isLoggedIn, isNotLoggedIn } = require('../lib/auth');
const { getSummaryMusic } = require('../lib/artist');
const { getLatestSub } = require('../lib/admin');
const { getMyAllSong } = require('../user/user');
// ARTISTAS
// Autenticacion
router
  .route('/signup/artist')
  .get(isNotLoggedIn, (req, res) => {
    res.render('auth/signupArtist');
  })
  .post(
    passport.authenticate('local.signupArtist', {
      successRedirect: '/home',
      failureRedirect: '/signup/artist',
      failureFlash: true,
    })
  );

router.route('/home').get(isLoggedIn, async (req, res) => {
  let info = {};

  if (req.user.isArt) {
    info.albumes = await getSummaryMusic(req.user.id_art);
  } else if (req.user.isAdmin) {
    info.response = await getLatestSub();
  } else if (req.user.isUsu) {
    info = await getMyAllSong(req.user.id_usu);
  }

  res.render('home', info);
});

router.route('/logout').get(isLoggedIn, (req, res) => {
  req.logOut();
  res.redirect('/signin');
});

// Ingreso Dual
router
  .route('/signin')
  .get(isNotLoggedIn, (req, res) => {
    res.render('auth/signin');
  })
  .post((req, res, next) => {
    passport.authenticate('local.signin', {
      successRedirect: '/home',
      failureRedirect: '/signin',
      failureFlash: true,
    })(req, res, next);
  });

// USUARIOS
// Autenticacion
router
  .route('/signup')
  .get(isNotLoggedIn, (req, res) => {
    // Para renderizar la vista
    res.render('auth/signup');
  })
  .post(
    passport.authenticate('local.signupUser', {
      successRedirect: '/home',
      failureRedirect: '/signup',
      failureFlash: true,
    })
  );

exports.router = router;
