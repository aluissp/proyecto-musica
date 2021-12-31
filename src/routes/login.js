const express = require('express'); // Importamos la libreria
const router = express.Router();

router.get('/', (req, res) => {
    res.render('login.html');
});


exports.router = router;