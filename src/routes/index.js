const express = require('express'); // Importamos la libreria
const { route } = require('express/lib/application');
const router = express.Router();

router.route('/')
    .get((req, res) => {
        console.log('Estoy en el home')
        res.render('index.html');
    })

router.route('/redirect').post((req, res) => {
    res.redirect('../home');
});

exports.router = router;