const { db } = require('../conexion');

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

const getFullArtist = async (idArt, idUser) => {
  try {
    const consulta1 = await db.query(
      `SELECT id_art, seudonimo_art, pais_art
      FROM artistas
      WHERE id_art = $1`,
      [idArt]
    );
    const consulta2 = await db.query(
      `SELECT id_alb, nombre_alb, numpistas_alb, precio_alb, fecha_alb
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
    const ultimoLanzamiento = consulta4.rows[0];

    const misAlbumes = await getMyAlbumId(idUser);

    let i = 0;
    let nroPistas = 0;
    // Contar albumes
    albumes.forEach((album) => {
      i++;
      nroPistas += album.numpistas_alb;
      for (const miAlb of misAlbumes) {
        if (miAlb.albumes_comprados === album.id_alb) {
          album.itsMine = true;
        }
      }
    });
    info.nroAlbumes = i;
    info.nroPistas = nroPistas;

    // Contar canciones
    i = 1;
    canciones.forEach((cancion) => {
      cancion.nro = i;
      i++;
    });

    for (const miAlb of misAlbumes) {
      if (miAlb.albumes_comprados === ultimoLanzamiento.id_alb) {
        ultimoLanzamiento.itsMine = true;
      }
    }

    const response = {
      artista,
      albumes,
      canciones,
      info,
      ultimoLanzamiento,
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
      `SELECT id_art, nombre_alb, numpistas_alb, fecha_alb, seudonimo_art
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
      idArt: consulta2.rows[0].id_art,
    };
    return response;
  } catch (e) {
    console.log(e);
  }
};

const updatePerfil = async (
  req,
  idUser,
  nombre,
  apellido,
  genero,
  fnacimiento
) => {
  try {
    const edad = calcularEdad(fnacimiento);
    if (genero === 'none') {
      req.flash('messageUserFail', 'Debe eligir un genero valido!');
    } else if (edad < 18) {
      req.flash('messageUserFail', 'Usted debe tener al menos 18 años!');
    } else {
      const data = [nombre, apellido, genero, fnacimiento, idUser];
      await db.query(
        `UPDATE usuarios SET nombres = $1, apellidos = $2,
        genero = $3, fecha_nacim = $4
        WHERE id_usu = $5`,
        data
      );

      req.flash('messageUser', 'Se actualizo correctamente el perfil');
    }
  } catch (e) {
    console.log(e);
    req.flash('messageUserFail', 'No se pudo actualizar el perfil');
  }
};

const updatePass = async (req, id, newPass, confirmPass) => {
  try {
    if (newPass.length < 8) {
      req.flash(
        'messageUserFail',
        'La contraseña debe tener al menos 8 caracteres'
      );
    } else if (newPass === confirmPass) {
      await db.query(
        `UPDATE usuarios
        SET	contrasena_usu = $1
        WHERE id_usu = $2`,
        [newPass, id]
      );
      req.flash('messageUser', 'Se actualizó correctamente el contraseña');
    } else {
      req.flash(
        'messageUserFail',
        'La contraseña debe coincidir para actualizarlo'
      );
    }
  } catch (e) {
    console.log(e);
    req.flash(
      'messageAdminFail',
      'Ocurrió en error al actualizar la contraseña'
    );
  }
};

const calcularEdad = (fecha) => {
  var hoy = new Date();
  var cumpleanos = new Date(fecha);
  var edad = hoy.getFullYear() - cumpleanos.getFullYear();
  var m = hoy.getMonth() - cumpleanos.getMonth();

  if (m < 0 || (m === 0 && hoy.getDate() < cumpleanos.getDate())) {
    edad--;
  }

  return edad;
};

const getIva = async () => {
  try {
    const consulta = await db.query(
      `SELECT valor_imp FROM impuestos WHERE id_imp = 'imp-2'`
    );

    const iva = consulta.rows[0];
    return iva;
  } catch (e) {
    console.log(e);
  }
};

const getMyAlbumId = async (idUser) => {
  try {
    const consulta = await db.query(`SELECT albumes_comprados($1)`, [idUser]);
    const misAlbumes = consulta.rows;
    return misAlbumes;
  } catch (e) {
    console.log(e);
  }
};

const getMyAllSong = async (idUser) => {
  try {
    const response = {};
    const misIdAlbumes = await getMyAlbumId(idUser);
    const artistas = [];
    const albumes = [];
    let nroAlb = 0;
    let nroCan = 0;
    let totalPrice = 0;

    for (const id of misIdAlbumes) {
      nroAlb++;
      const consulta1 = await db.query(
        `SELECT id_alb, nombre_alb, precio_alb FROM albumes WHERE id_alb = $1`,
        [id.albumes_comprados]
      );
      totalPrice += consulta1.rows[0].precio_alb;
      albumes.push(consulta1.rows[0]);

      const consulta2 = await db.query(
        `SELECT id_art, seudonimo_art
          FROM albumes INNER JOIN artistas USING(id_art)
          WHERE id_alb = $1`,
        [id.albumes_comprados]
      );
      const art = consulta2.rows[0];

      if (artistas.length === 0) {
        artistas.push(art);
      }
      for (const artista of artistas) {
        if (artista.id_art !== art.id_art) {
          artistas.push(art);
        }
      }

      const consulta3 = await db.query(
        `SELECT id_can
        FROM canciones
        WHERE id_alb = $1`,
        [id.albumes_comprados]
      );
      nroCan += consulta3.rows.length;
    }

    response.albumes = albumes;
    response.artistas = artistas;
    response.nroAlb = nroAlb;
    response.nroCan = nroCan;
    response.totalPrice = totalPrice;
    return response;
  } catch (e) {
    console.log(e);
  }
};

const getMySongs = async (idUser, wordkey) => {
  try {
    wordkey = wordkey || '%';
    const misIdAlbumes = await getMyAlbumId(idUser);
    const canciones = [];

    for (const id of misIdAlbumes) {
      const consulta1 = await db.query(
        `SELECT id_can, id_alb,  nombre_can, seudonimo_art, nombre_alb, nombre_gen, duracion_can, nropista_can
        FROM canciones INNER JOIN albumes USING(id_alb)
        INNER JOIN artistas USING(id_art)
        INNER JOIN generos USING(id_gen)
        WHERE nombre_can LIKE '${wordkey}%' AND id_alb = $1
        ORDER BY nombre_can`,
        [id.albumes_comprados]
      );
      const songs = consulta1.rows;

      for (const song of songs) {
        canciones.push(song);
      }
    }

    let i = 1;
    canciones.forEach((cancion) => {
      cancion.nro = i;
      i++;
    });

    return canciones;
  } catch (e) {
    console.log(e);
  }
};

exports.exploreMusic = exploreMusic;
exports.getFullArtist = getFullArtist;
exports.getFullAlbum = getFullAlbum;
exports.updatePerfil = updatePerfil;
exports.updatePass = updatePass;
exports.getIva = getIva;
exports.getMyAlbumId = getMyAlbumId;
exports.getMyAllSong = getMyAllSong;
exports.getMySongs = getMySongs;
