const express = require('express'); // Importamos la libreria
const router = express.Router();

router.route('/art')
    .get((req, res) => {
        res.render('profile/profileArt');
    })


exports.router = router;