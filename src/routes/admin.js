const express = require('express'); // Importamos la libreria
const router = express.Router();
const { isLoggedIn, isNotLoggedIn } = require('../lib/auth');

router.route('/').get(isLoggedIn, (req, res) => {
  res.render('admin/admin');
});

router.route('/newAdmin').get(isLoggedIn, (req, res) => {
  res.render('admin/newAdmin');
});

router.route('/art').get(isLoggedIn, (req, res) => {
  res.render('admin/artist');
});

router.route('/user').get(isLoggedIn, (req, res) => {
  res.render('admin/user');
});

router.route('/planes').get(isLoggedIn, (req, res) => {
  res.render('admin/plan');
});

exports.router = router;
