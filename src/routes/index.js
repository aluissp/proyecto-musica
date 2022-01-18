const express = require('express'); // Importamos la libreria
const router = express.Router();

router.route('/')
    .get((req, res) => {
        res.render('index');
    })


exports.router = router;