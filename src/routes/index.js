const express = require('express'); // Importamos la libreria
const router = express.Router();

router.get('/', (req, res) => {
    res.render('index.html');
});


exports.router = router;