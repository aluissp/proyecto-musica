const { db } = require('../conexion');
const {
  construcPdf,
  insertHeader,
  insertTableWhite,
  insertTable,
} = require('../lib/pdfSimple');

const exploreMusic = async (wordkey) => {
  try {
    const consulta1 = await db.query(
      `SELECT id_can, id_alb,  nombre_can, seudonimo_art, nombre_alb, nombre_gen, duracion_can, nropista_can
      FROM canciones INNER JOIN albumes USING(id_alb)
      INNER JOIN artistas USING(id_art)
      INNER JOIN generos USING(id_gen)
      WHERE nombre_can LIKE '${wordkey}%'
      ORDER BY nombre_can`
    );

    const consulta2 = await db.query(
      `SELECT id_alb, nombre_alb
      FROM albumes
      WHERE nombre_alb LIKE '${wordkey}%'
      ORDER BY nombre_alb;`
    );

    const consulta3 = await db.query(
      `SELECT id_art, seudonimo_art
      FROM artistas
      WHERE seudonimo_art LIKE '${wordkey}%'
      ORDER BY seudonimo_art`
    );

    const canciones = consulta1.rows;
    let i = 1;
    canciones.forEach((cancion) => {
      cancion.nro = i;
      i++;
    });

    const response = {
      canciones,
      albumes: consulta2.rows,
      artistas: consulta3.rows,
    };

    return response;
  } catch (e) {
    console.log(e);
  }
};

const getFullArtist = async (idArt) => {
  try {
    const consulta1 = await db.query(
      `SELECT id_art, seudonimo_art, pais_art
      FROM artistas
      WHERE id_art = $1`,
      [idArt]
    );
    const consulta2 = await db.query(
      `SELECT id_alb, nombre_alb, numpistas_alb, precio_alb
       FROM albumes
       WHERE id_art = $1
       ORDER BY nombre_alb`,
      [idArt]
    );
    const consulta3 = await db.query(
      `SELECT id_can, id_alb,  nombre_can, nombre_alb, nombre_gen, duracion_can, nropista_can
      FROM canciones INNER JOIN albumes USING(id_alb)
      INNER JOIN generos USING(id_gen)
      WHERE id_art = $1
      ORDER BY nombre_can
	    LIMIT 5`,
      [idArt]
    );

    const consulta4 = await db.query(
      `SELECT id_alb, nombre_alb, numpistas_alb, precio_alb, fecha_alb, nombre_gen
      FROM albumes INNER JOIN generos USING(id_gen)
      WHERE id_art = $1
      ORDER BY fecha_alb DESC
      LIMIT 1`,
      [idArt]
    );

    const info = {};

    const artista = consulta1.rows[0];
    const albumes = consulta2.rows;
    const canciones = consulta3.rows;

    let i = 0;
    let nroPistas = 0;
    // Contar albumes
    albumes.forEach((album) => {
      i++;
      nroPistas += album.numpistas_alb;
    });
    info.nroAlbumes = i;
    info.nroPistas = nroPistas;

    // Contar canciones
    i = 1;
    canciones.forEach((cancion) => {
      cancion.nro = i;
      i++;
    });

    const response = {
      artista,
      albumes,
      canciones,
      info,
      ultimoLanzamiento: consulta4.rows[0],
    };
    return response;
  } catch (e) {
    console.log(e);
  }
};

const getFullAlbum = async (idAlb) => {
  try {
    const consulta1 = await db.query(
      `SELECT id_can, id_alb,  nombre_can, nombre_gen, duracion_can, nropista_can
      FROM canciones INNER JOIN albumes USING(id_alb)
      INNER JOIN generos USING(id_gen)
      WHERE id_alb = $1
      ORDER BY nropista_can`,
      [idAlb]
    );

    const consulta2 = await db.query(
      `SELECT nombre_alb, numpistas_alb, fecha_alb, seudonimo_art
      FROM albumes INNER JOIN artistas USING(id_art)
      WHERE id_alb = $1`,
      [idAlb]
    );

    const response = {
      canciones: consulta1.rows,
      album: consulta2.rows[0].nombre_alb,
      fecha: consulta2.rows[0].fecha_alb,
      pistas: consulta2.rows[0].numpistas_alb,
      artista: consulta2.rows[0].seudonimo_art,
    };
    return response;
  } catch (e) {
    console.log(e);
  }
};

exports.exploreMusic = exploreMusic;
exports.getFullArtist = getFullArtist;
exports.getFullAlbum = getFullAlbum;
