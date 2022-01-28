const { db } = require('../conexion');
const path = require('path');

const getCardArt = async (idArt) => {
  const consulta = await db.query(
    `SELECT * FROM tarjetas_artistas WHERE id_art = $1`,
    [idArt]
  );
  return consulta.rows;
};

const getPlans = async () => {
  const consulta = await db.query('SELECT * FROM planes');
  return consulta.rows;
};

const getSuscriptions = async (idArt) => {
  const consulta = await db.query(
    'SELECT * FROM suscripciones WHERE id_art = $1 ORDER BY finico_sus DESC',
    [idArt]
  );
  const listSuscriptions = consulta.rows;
  listSuscriptions.forEach(async (suscription) => {
    const reslt = await db.query(
      'SELECT nombre_pl FROM planes WHERE id_pl = $1',
      [suscription.id_pl]
    );
    suscription.plan = reslt.rows[0].nombre_pl;
  });
  return listSuscriptions;
};

const getCurrentPlan = async (idArt) => {
  try {
    const consulta = await db.query(
      'SELECT * FROM suscripciones WHERE id_art = $1 ORDER BY finico_sus DESC',
      [idArt]
    );

    const sus_plan = consulta.rows[0];
    var currentPlan = null;
    const hoy = new Date(Date.now());
    const ffin = sus_plan.ffin_sus;

    if (hoy <= ffin) {
      const plan = await db.query('SELECT * FROM planes where id_pl = $1', [
        sus_plan.id_pl,
      ]);
      currentPlan = plan.rows[0];
    }
    return currentPlan;
  } catch (e) {
    // console.log(e);
    return currentPlan;
  }
};

const insertCard = async (newCard) => {
  try {
    const hoy = new Date(Date.now());
    const fcaducidad = new Date(newCard[3]);

    if (!(newCard[2].length >= 16)) {
      return 'La tarjeta debe tener 16 numeros';
    } else if (fcaducidad < hoy) {
      return 'La fecha de caducidad debe ser mayor a la fecha actual';
    } else {
      await db.query(
        'INSERT INTO tarjetas_artistas(id_art, tipo_tar, numero_tar, fcaducidad) VALUES($1, $2, $3, $4)',
        newCard
      );
    }
  } catch (e) {
    console.log(e);
  }
};

const updateCard = async (newCard) => {
  try {
    const hoy = new Date(Date.now());
    const fcaducidad = new Date(newCard[2]);

    if (!(newCard[1].length >= 16)) {
      return 'La tarjeta debe tener 16 numeros';
    } else if (fcaducidad < hoy) {
      return 'La fecha de caducidad debe ser mayor a la fecha actual';
    } else {
      await db.query(
        'UPDATE tarjetas_artistas SET tipo_tar = $1, numero_tar = $2, fcaducidad = $3 WHERE id_tar = $4',
        newCard
      );
    }
  } catch (e) {
    console.log(e);
  }
};

const deleteCard = async (id) => {
  try {
    await db.query('DELETE FROM tarjetas_artistas WHERE id_tar = $1', [id]);
  } catch (e) {
    console.log(e);
  }
};

const buyPlan = async (idArt, idPlan) => {
  try {
    const hoy = new Date(Date.now());
    await db.query(
      'INSERT INTO suscripciones(id_art, id_pl, finico_sus) VALUES($1, $2, $3)',
      [idArt, idPlan, hoy]
    );
    return 'Se ha comprado exitosamente su plan';
  } catch (e) {
    console.log(e);
  }
};

const changePass = async (idArt, pass1, pass2) => {
  try {
    if (pass1 !== pass2) {
      return 'Las contraseñas deben coincidir para continuar';
    } else if (!(pass1.length >= 10 && pass2.length >= 10)) {
      return 'La longitud de la contraseña debe ser mayor o igual a 10';
    } else {
      await db.query(
        'UPDATE artistas SET contrasena_art = $1 WHERE id_art = $2',
        [pass1, idArt]
      );
    }
  } catch (e) {
    console.log(e);
  }
};

const changeProfile = async (idArt, artName, artMail, artPais) => {
  try {
    await db.query(
      'UPDATE artistas SET seudonimo_art = $1, email_art =$2, pais_art = $3 WHERE id_art = $4',
      [artName, artMail, artPais, idArt]
    );
  } catch (e) {
    console.log(e);
    return 'Ocurrio un error al actualizar su perfil';
  }
};

const getMusicReport = async (
  idArt,
  tabla,
  ordenar,
  wordkey,
  ordenar2,
  albumfilter
) => {
  try {
    const consulta1 = await db.query(
      'SELECT nombre_alb FROM albumes WHERE id_art = $1',
      [idArt]
    );
    if (idArt && !tabla) {
      const headerTable = [
        { column_name: 'Album' },
        { column_name: 'Numero de pistas' },
        { column_name: 'Precio' },
        { column_name: 'Fecha' },
        { column_name: 'Género' },
      ];

      const consulta = await db.query(
        'SELECT nombre_alb, numpistas_alb, precio_alb, fecha_alb, nombre_gen FROM albumes INNER JOIN generos USING(id_gen) WHERE id_art = $1',
        [idArt]
      );
      const response = {
        headerTable,
        report: consulta.rows,
        albumes: consulta1.rows,
        inMusic: true,
      };
      return response;
    }

    if (tabla === 'albumes') {
      const headerTable = [
        { column_name: 'Album' },
        { column_name: 'Numero de pistas' },
        { column_name: 'Precio' },
        { column_name: 'Fecha' },
        { column_name: 'Género' },
      ];
      const consulta = await db.query(
        `SELECT nombre_alb, numpistas_alb, precio_alb, fecha_alb, nombre_gen
       FROM albumes INNER JOIN generos USING(id_gen)
       WHERE id_art = $1 AND nombre_alb LIKE '${wordkey}%'
       ORDER BY ${ordenar} ${ordenar2}`,
        [idArt]
      );
      const response = {
        headerTable,
        report: consulta.rows,
        albumes: consulta1.rows,
        inMusic: true,
      };

      return response;
    } else if (tabla === 'canciones') {
      const headerTable = [
        { column_name: 'Cancion' },
        { column_name: 'Numero de pista' },
        { column_name: 'Género' },
        { column_name: 'Duración' },
      ];

      const consulta = await db.query(
        `SELECT nombre_can, nropista_can, nombre_gen, duracion_can
        FROM canciones INNER JOIN albumes USING(id_alb)
                       INNER JOIN generos USING(id_gen)
        WHERE id_art = $1 AND nombre_can LIKE '${wordkey}%'
        AND nombre_alb LIKE '${albumfilter}%'
        ORDER BY ${ordenar} ${ordenar2}`,
        [idArt]
      );
      const response = {
        headerTable,
        reportSong: consulta.rows,
        albumes: consulta1.rows,
        inMusic: true,
        isSong: true,
      };

      return response;
    } else if (tabla === 'generos') {
      const headerTable = [
        { column_name: 'Album' },
        { column_name: 'Numero de pistas' },
        { column_name: 'Precio' },
        { column_name: 'Fecha' },
        { column_name: 'Género' },
      ];
      const consulta = await db.query(
        `
        SELECT nombre_alb, numpistas_alb, precio_alb, fecha_alb, nombre_gen
        FROM albumes INNER JOIN generos USING(id_gen)
        WHERE id_art = $1 AND nombre_gen LIKE '${wordkey}%'
        ORDER BY nombre_gen ${ordenar2}`,
        [idArt]
      );

      const response = {
        headerTable,
        report: consulta.rows,
        albumes: consulta1.rows,
        inMusic: true,
      };
      return response;
    }
  } catch (e) {
    console.log(e);
  }
};

const getMusicPDF = async (req, doc, content) => {
  const { headerTable, report, reportSong, isSong } = content;
  const tabla = report || reportSong;
  const colum = [];
  for (let key in tabla[0]) {
    colum.push({ key });
  }

  for (let i = 0; i < colum.length; i++) {
    colum[i].label = headerTable[i].column_name;
    colum[i].align = 'left';
  }

  if (!isSong) {
    tabla.forEach((row) => {
      const dia = row.fecha_alb.getDate();
      const mes = parseInt(row.fecha_alb.getMonth()) + 1;
      const anio = row.fecha_alb.getFullYear();
      row.fecha_alb = `${dia < 10 ? '0' + dia : dia}/${
        mes < 10 ? '0' + mes : mes
      }/${anio}`;
    });
  }
  // const img = path.join(__dirname, '../public/img/epicentro-bar.jpg');
  // doc.image(img, 45, 10, { width: 100 });
  doc.setDocumentHeader({ height: '23%' }, () => {
    doc.fontSize(13).text('REPORTES', { width: 420, align: 'center' });
    doc.fontSize(11);

    doc.text(`Nombre artístico: ${req.user.seudonimo_art}`, {
      marginLeft: 45,
      align: 'left',
    });
    doc.text(`Correo electronico: ${req.user.email_art}`, {
      width: 420,
      align: 'left',
    });
    doc.text(`Pais de residencia: ${req.user.pais_art}`, {
      width: 420,
      align: 'left',
    });
    doc.text('Resumen breve', {
      width: 420,
      align: 'left',
    });
    doc.text('');
    if (isSong) {
      doc.text('');
    } else {
      const { nroAlbumes, precioTotal, pistasTotal } = summaryAlbum(tabla);

      doc.text(`Se filtró: ${nroAlbumes} albumes`, {
        width: 420,
        align: 'left',
      });
      doc.text(`El precio de los albumes: $ ${precioTotal} dólares en total`, {
        width: 420,
        align: 'left',
      });
      doc.text(`En total hay: ${pistasTotal} pistas`, {
        width: 420,
        align: 'left',
      });
    }
  });

  doc.addTable(colum, tabla, {
    border: null,
    width: 'fill_body',
    striped: true,
    stripedColors: ['#f6f6f6', '#d6c4dd'],
    cellsPadding: 10,
    marginLeft: 45,
    marginRight: 45,
    headAlign: 'left',
  });
  doc.render();
  doc.end();
};

const summaryAlbum = (table) => {
  let nroAlbumes = 0;
  let precioTotal = 0;
  let pistasTotal = 0;
  for (let row of table) {
    nroAlbumes++;
    precioTotal += row.precio_alb;
    pistasTotal += row.numpistas_alb;
  }
  return { nroAlbumes, precioTotal, pistasTotal };
};

exports.getCardArt = getCardArt;
exports.getPlans = getPlans;
exports.getSuscriptions = getSuscriptions;
exports.getCurrentPlan = getCurrentPlan;
exports.insertCard = insertCard;
exports.updateCard = updateCard;
exports.deleteCard = deleteCard;
exports.buyPlan = buyPlan;
exports.changePass = changePass;
exports.changeProfile = changeProfile;
exports.getMusicReport = getMusicReport;
exports.getMusicPDF = getMusicPDF;
