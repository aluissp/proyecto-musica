const express = require('express'); // Importamos la libreria
const router = express.Router();
const { db } = require('../conexion');
router.route('/addmusic')
    .get(async (req, res) => {

        const consulta = await db.query("select * from albumes where id_art= $1", ['001']);
        const albumes = consulta.rows;
        res.render('links/addMusic', { albumes });
    });

router.route('/addmusic/album')
    .post(async (req, res) => {
        const { titulo, fecha, npistas, genero, precio, url } = req.body;
        const npistas_n = Number(npistas);
        const precio_n = Number(precio);
        const nuevoAlbum = [
            titulo,
            fecha,
            npistas_n,
            genero,
            precio_n,
            url
        ]

        // await db.query('insert into albumes values( $1, $2, $3, $4, $5, $6, $7,$8)', [nuevoAlbum]);
        await db.query("insert into albumes values( 'ALBM-004', '001', $1, $2, $3, $4, $5,$6)", nuevoAlbum);

        res.redirect('/home/addmusic');
    });

router.route('/addmusic/delete/:id')
    .get(async (req, res) => {
        const { id } = req.params;
        await db.query('delete from albumes where id_al = $1', [id]);
        res.redirect('/home/addmusic');
    });

router.route('/addmusic/edit/:id')
    .post(async (req, res) => {
        const { id } = req.params;
        const { titulo, fecha, npistas, genero, precio, url } = req.body;
        const npistas_n = Number(npistas);
        const precio_n = Number(precio);
        const editAlbum = [
            titulo,
            fecha,
            npistas_n,
            genero,
            precio_n,
            url,
            id
        ]
        const consulta = await db.query('update albumes set titulo_al = $1, fecha_al = $2, numpistas_al = $3, genero_al = $4, precio_al = $5, url_al = $6 where id_al = $7', editAlbum);

        res.redirect('/home/addmusic');
    });
/*                           Tabla «public.albumes»
   Columna    |         Tipo          | Ordenamiento | Nulable  | Por omisión
--------------+-----------------------+--------------+----------+-------------
 id_al        | character varying(10) |              | not null |
 id_art       | character varying(10) |              |          |
 titulo_al    | character varying(50) |              | not null |
 fecha_al     | date                  |              | not null |
 numpistas_al | smallint              |              | not null |
 genero_al    | character varying(30) |              | not null |
 precio_al    | real                  |              | not null |
 url_al       | text                  |    

                           Tabla «public.canciones»
   Columna    |          Tipo          | Ordenamiento | Nulable  | Por omisión
--------------+------------------------+--------------+----------+-------------
 id_can       | character varying(10)  |              | not null |
 id_al        | character varying(10)  |              |          |
 nombre_can   | character varying(50)  |              | not null |
 duracion_can | time without time zone |              | not null |
 nropista_can | smallint               |              | not null |
 genero_can   | character varying(30)  |              | not null |
 url_can      | text                   |              |          |

*/
exports.router = router;