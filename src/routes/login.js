const express = require('express'); // Importamos la libreria
const router = express.Router();
const { db } = require('../conexion');
router.route('/')
    .get((req, res) => {
        res.render('login.html');
    });
router.route('/ingresar')
    .post(async (req, res) => {
        const { email, clave } = req.body;
        let pass = false;

        const consulta1 = await db.query('select contrasena_art from artista where email_art= $1', [email]);
        console.log(consulta1.rows == true);
        pass = validar(consulta1.rows, clave);
        if (!pass) {
            const consulta2 = await db.query('select contrasena_usu from usuarios where email_usu= $1', [email]);
            pass = validar(consulta2.rows, clave);
        }
        let status = pass ? 202 : 400;
        res.status(status).json({ aceptado: pass });
    });

const validar = (fila, claveIngresada) => {
    if (fila.length <= 0) return false;
    if (fila[0].contrasena_usu === claveIngresada) return true;
    if (fila[0].contrasena_art === claveIngresada) return true;
    console.log('no mismo pasa');
    return false;
}

exports.router = router;