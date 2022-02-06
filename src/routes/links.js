const express = require('express'); // Importamos la libreria
const router = express.Router();
const { db } = require('../conexion');
const { whitPlan } = require('../lib/auth');
const { getAllPlan } = require('../lib/admin');
// RUTAS SOLO DE ARTISTAS
// CRUD ALBUM
router.route('/addmusic')
    .get(whitPlan, async (req, res) => {

        const consulta = await db.query("select * from albumes where id_art= $1", [req.user.id_art]);
        const albumes = consulta.rows;
        albumes.forEach(async (album)=>{
            const response = await db.query("select nombre_gen from generos where id_gen= $1", [album.id_gen]);
            album.genero = response.rows[0].nombre_gen;
        });
        const generos = (await db.query("select * from generos")).rows;
        res.render('links/addAlbum', { albumes, generos });
    });

router.route('/addmusic/album')
    .post(async (req, res) => {
        try {

            const { titulo, fecha, genero, precio } = req.body;
            const precio_n = Number(precio);
            const response = await db.query("select id_gen from generos where nombre_gen= $1", [genero]);
            const idGen = response.rows[0].id_gen;

            const nuevoAlbum = [
                req.user.id_art,
                titulo,
                idGen,
                precio_n,
                fecha
            ]

            await db.query(`INSERT INTO
            albumes(id_art, nombre_alb, id_gen, precio_alb, fecha_alb)
            VALUES($1, $2, $3, $4, $5)`, nuevoAlbum);

            // req.flash('success_album','Album guardado correctamente');
            res.redirect('/home/addmusic');
        } catch (e) {
            console.error(e);
            res.redirect('/home/addmusic');
        }
        });

router.route('/addmusic/delete/:idAlbum')
    .get(async (req, res) => {
        const { idAlbum } = req.params;
        await db.query('delete from albumes where id_alb = $1', [idAlbum]);
        res.redirect('/home/addmusic');
    });

router.route('/addmusic/edit/:idAlbum')
    .post(async (req, res) => {
        const { idAlbum } = req.params;
        const { titulo, fecha, genero, precio } = req.body;
        const precio_n = Number(precio);
        const response = await db.query("select id_gen from generos where nombre_gen= $1", [genero]);
        const idGen = response.rows[0].id_gen;
        const editAlbum = [
            titulo,
            fecha,
            idGen,
            precio_n,
            idAlbum
        ]
        await db.query('update albumes set nombre_alb = $1, fecha_alb = $2, id_gen = $3, precio_alb = $4 where id_alb = $5', editAlbum);

        res.redirect('/home/addmusic');
    });

// CRUD CANCIONES
router.route('/addmusic/music/:idAlbum')
    .get(async (req, res) => {
        const { idAlbum } = req.params;
        const consulta = await db.query("select * from canciones where id_alb= $1 order by nropista_can", [idAlbum]);
        const canciones = consulta.rows;
        const consulta2 = await db.query("select id_gen from albumes where id_alb= $1", [idAlbum]);
        const genero = (await db.query('select nombre_gen from generos where id_gen = $1',[consulta2.rows[0].id_gen])).rows[0].nombre_gen;

        canciones.forEach((cancion) => {
            cancion.genero = genero
        });
        // console.log(canciones);
        res.render('links/addMusic', { canciones, idAlbum });
    });
router.route('/addmusic/music/:idAlbum')
    .post(async (req, res) => {
        const { idAlbum } = req.params;
        const { nombre, duracion } = req.body;
        const nuevaCancion = [
            idAlbum,
            nombre,
            duracion
        ]
        await db.query(`INSERT INTO canciones(
        id_alb, nombre_can, duracion_can)
        VALUES ($1, $2, $3)`, nuevaCancion);

        res.redirect(`/home/addmusic/music/${idAlbum}`);
    });

router.route('/addmusic/music/delete/:idMusic')
    .get(async (req, res) => {
        const { idMusic } = req.params;
        const consulta = await db.query("select id_alb from canciones where id_can= $1", [idMusic]);
        const idAlbum = consulta.rows[0].id_alb;
        await db.query('delete from canciones where id_can = $1', [idMusic]);
        res.redirect(`/home/addmusic/music/${idAlbum}`);
    });

router.route('/addmusic/music/edit/:idMusic')
    .post(async (req, res) => {
        const { idMusic } = req.params;
        const { nombre, duracion } = req.body;
        const consulta = await db.query("select id_alb from canciones where id_can= $1", [idMusic]);
        const idAlbum = consulta.rows[0].id_alb;
        const editCancion = [
            nombre,
            duracion,
            idMusic
        ]

        await db.query('UPDATE canciones set nombre_can = $1, duracion_can = $2 WHERE id_can = $3', editCancion);
        res.redirect(`/home/addmusic/music/${idAlbum}`);
    });

router.route('/planes').get(async (req, res) => {
    const planes = await getAllPlan();
    res.render('artist/plan', { planes });
});
/*    Tabla «public.canciones»
    Columna    |          Tipo          | Ordenamiento | Nulable  | Por omisión
 --------------+------------------------+--------------+----------+-------------
  id_can       | character varying(10)  |              | not null |
  id_alb       | character varying(10)  |              |          |
  nombre_can   | character varying(50)  |              | not null |
  duracion_can | time without time zone |              | not null |
  nropista_can | smallint               |              | not null |*/
exports.router = router;
