const express = require('express'); // Importamos la libreria
const router = express.Router();
const { isNotLoggedIn } = require('../lib/auth');

router.route('/').get(isNotLoggedIn, (req, res) => {
  res.send('/user link');
});

exports.router = router;
