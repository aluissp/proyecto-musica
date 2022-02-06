const { db } = require('../conexion');
const {
  construcPdf,
  insertHeader,
  insertTableWhite,
  insertTable,
} = require('./pdfSimple');

const getLatestSub = async () => {
  try {
    const response = await db.query(
      `SELECT seudonimo_art, email_art, finico_sus, nombre_pl, total_sus
       FROM artistas INNER JOIN suscripciones USING(id_art)
       INNER JOIN planes USING(id_pl)
       ORDER BY finico_sus DESC
       LIMIT 10`
    );

    const Subs = {};
    let total = 0;
    let i = 1;
    for (const sub of response.rows) {
      sub.numbers = i;
      total += sub.total_sus;
      i++;
    }

    Subs.latestSub = response.rows;
    Subs.Total = total;
    return Subs;
  } catch (e) {
    console.log(e);
  }
};

const getArtistList = async () => {
  try {
    const headerTable = [
      { column_name: '#' },
      { column_name: 'Artista' },
      { column_name: 'Correo electrónico' },
      { column_name: 'País' },
      { column_name: 'Reporte de suscripciones' },
    ];

    const consulta = await db.query(
      'SELECT id_art, seudonimo_art FROM artistas ORDER BY seudonimo_art'
    );

    const response = {
      artList: consulta.rows,
      headerTable,
    };
    return response;
  } catch (e) {
    console.log(e);
  }
};

const getArtistFilter = async (request) => {
  try {
    const response = await getArtistList();
    let reportArt;

    let consulta;
    let i = 1;

    if (!request) {
      consulta = await db.query(
        'SELECT * FROM artistas ORDER BY seudonimo_art'
      );
      reportArt = consulta.rows;
    } else {
      const { filtros, id_art, id_pl, ordenar, wordkey, ordenar2 } = request;

      if (filtros === 'artistas' && id_art === 'none') {
        consulta = await db.query(
          `SELECT id_art, seudonimo_art, email_art, pais_art
           FROM artistas
           WHERE seudonimo_art LIKE '${wordkey}%'
           ORDER BY ${ordenar} ${ordenar2};
          `
        );

        reportArt = consulta.rows;
      } else if (filtros === 'artistas' && id_art !== 'none') {
        consulta = await db.query(
          `SELECT id_art, seudonimo_art, email_art, pais_art
          FROM artistas
          WHERE id_art = $1`,
          [id_art]
        );
        reportArt = consulta.rows;
      } else if (filtros === 'suscripciones' && id_pl === 'none') {
        response.headerSub = [
          { column_name: '#' },
          { column_name: 'Orden #: Plan' },
          { column_name: 'Artista' },
          { column_name: 'Fecha inicio' },
          { column_name: 'Fecha fin' },
          { column_name: 'Subtotal' },
          { column_name: 'iva' },
          { column_name: 'Total' },
        ];

        consulta = await db.query(
          `SELECT CONCAT(id_sus,': ', nombre_pl) orden, seudonimo_art, finico_sus, ffin_sus,subtotal_sus, iva_sus,total_sus
          FROM artistas INNER JOIN suscripciones USING(id_art)
          INNER JOIN planes USING(id_pl)
          WHERE CONCAT(id_sus,': ', nombre_pl) LIKE '${wordkey}%'
          ORDER BY ${ordenar} ${ordenar2}`
        );

        reportArt = consulta.rows;
      } else if (filtros === 'suscripciones' && id_pl !== 'none') {
        response.headerSub = [
          { column_name: '#' },
          { column_name: 'Orden #: Plan' },
          { column_name: 'Artista' },
          { column_name: 'Fecha inicio' },
          { column_name: 'Fecha fin' },
          { column_name: 'Subtotal' },
          { column_name: 'iva' },
          { column_name: 'Total' },
        ];

        consulta = await db.query(
          `SELECT CONCAT(id_sus,': ', nombre_pl) orden, seudonimo_art, finico_sus, ffin_sus,subtotal_sus, iva_sus,total_sus
          FROM artistas INNER JOIN suscripciones USING(id_art)
          INNER JOIN planes USING(id_pl)
          WHERE id_pl = '${id_pl}'
          AND CONCAT(id_sus,': ', nombre_pl) LIKE '${wordkey}%'
          ORDER BY ${ordenar} ${ordenar2}`
        );

        reportArt = consulta.rows;
      }
    }

    const formatReport = [];
    for (const row of reportArt) {
      const newRow = {
        nro: i,
      };

      for (const item in row) {
        newRow[item] = row[item];
      }
      formatReport.push(newRow);
      i++;
    }

    // console.log(formatReport);
    response.reportArt = formatReport;
    return response;
  } catch (e) {
    console.log(e);
  }
};

const getArtistPdf = (req, res, content) => {
  try {
    let doc = construcPdf(res, 'Artista');

    doc = insertHeader(doc, 'REPORTE DE ARTISTAS');

    const header = [
      { key: 'labelData', label: 'Datos Personales', aling: 'left' },
      { key: 'userData', label: '', aling: 'left' },
    ];

    const userData = [
      {
        labelData: 'Nombre y apellido',
        userData: `${req.user.nombres} ${req.user.apellidos}`,
      },
      { labelData: 'Correo Electrónico', userData: req.user.email_usu },
      {
        labelData: 'Fecha de nacimiento',
        userData: dateFormat(req.user.fecha_nacim),
      },
      { labelData: 'Género', userData: req.user.genero },
    ];
    doc = insertTableWhite(doc, userData, header);

    const { headerTable, headerSub, reportArt } = content;
    if (headerTable.length === 5 && !headerSub) {
      doc = insertTable(doc, reportArt, headerTable);
    } else if (headerSub) {
      reportArt.forEach((row) => {
        row.finico_sus = dateFormat(row.finico_sus);
        row.ffin_sus = dateFormat(row.ffin_sus);
        row.subtotal_sus = coinFormat(row.subtotal_sus);
        row.iva_sus = coinFormat(row.iva_sus);
        row.total_sus = coinFormat(row.total_sus);
      });
      doc = insertTable(doc, reportArt, headerSub);
    }
    doc.render();
    doc.end();
  } catch (e) {
    console.log(e);
  }
};

const getArtistReport = async (req, res, mail) => {
  try {
    const consulta = await db.query(
      `SELECT CONCAT(id_sus,': ', nombre_pl) orden, seudonimo_art, finico_sus, ffin_sus,subtotal_sus, iva_sus,total_sus
      FROM artistas INNER JOIN suscripciones USING(id_art)
      INNER JOIN planes USING(id_pl)
      WHERE email_art = $1
      ORDER BY finico_sus`,
      [mail]
    );

    let doc = construcPdf(res, 'Artista');

    doc = insertHeader(doc, `Reporte de suscripciones`);

    const userHeader = [
      { key: 'labelData', label: 'Datos Personales', aling: 'left' },
      { key: 'userData', label: '', aling: 'left' },
    ];

    const userData = [
      {
        labelData: 'Nombre y apellido',
        userData: `${req.user.nombres} ${req.user.apellidos}`,
      },
      { labelData: 'Correo Electrónico', userData: req.user.email_usu },
      {
        labelData: 'Fecha de nacimiento',
        userData: dateFormat(req.user.fecha_nacim),
      },
      { labelData: 'Género', userData: req.user.genero },
    ];
    doc = insertTableWhite(doc, userData, userHeader);

    const table = consulta.rows;
    if (table.length > 0) {
      const header = [
        { column_name: 'Orden #: Plan' },
        { column_name: 'Artista' },
        { column_name: 'Fecha inicio' },
        { column_name: 'Fecha fin' },
        { column_name: 'Subtotal' },
        { column_name: 'iva' },
        { column_name: 'Total' },
      ];
      table.forEach((row) => {
        row.finico_sus = dateFormat(row.finico_sus);
        row.ffin_sus = dateFormat(row.ffin_sus);
        row.subtotal_sus = coinFormat(row.subtotal_sus);
        row.iva_sus = coinFormat(row.iva_sus);
        row.total_sus = coinFormat(row.total_sus);
      });

      doc = insertTable(doc, table, header);
    }

    doc.render();
    doc.end();
  } catch (e) {
    console.log(e);
  }
};

const getAllPlan = async () => {
  try {
    const consulta = await db.query('SELECT * FROM planes');
    const planes = consulta.rows;
    return planes;
  } catch (e) {
    console.error(e);
  }
};

const insertPlan = async (req, nombre, descripcion, precio, duracion) => {
  try {
    const data = [nombre, descripcion, precio, duracion];
    await db.query(
      `INSERT INTO planes(nombre_pl, descripcion_pl, precio_pl, duracion_pl)
       VALUES($1, $2, $3,$4)`,
      data
    );
    req.flash('messageAdmin', 'Se creo correctamente el plan');
  } catch (e) {
    console.log(e);
    req.flash('messageAdminFail', 'No se pudo crear el plan');
  }
};

const deletePlan = async (req, idPlan) => {
  try {
    await db.query(`DELETE FROM planes WHERE id_pl = $1`, [idPlan]);
    req.flash('messageAdmin', 'Se elimino correctamente el plan');
  } catch (e) {
    console.log(e);
    req.flash(
      'messageAdminFail',
      'No se puede borrar el plan porque hay artistas que ya compraron el plan'
    );
  }
};

const updatePlan = async (
  req,
  nombre,
  descripcion,
  precio,
  duracion,
  idPlan
) => {
  try {
    const data = [nombre, descripcion, precio, duracion, idPlan];
    await db.query(
      `UPDATE planes SET nombre_pl = $1, descripcion_pl = $2,
      precio_pl = $3, duracion_pl = $4 WHERE id_pl = $5`,
      data
    );
    req.flash('messageAdmin', 'Se actualizo correctamente el plan');
  } catch (e) {
    console.log(e);
    req.flash('messageAdminFail', 'No se pudo actualizar el plan');
  }
};

const updatePerfil = async (
  req,
  idAdm,
  nombre,
  apellido,
  genero,
  fnacimiento
) => {
  try {
    const edad = calcularEdad(fnacimiento);
    if (genero === 'none') {
      req.flash('messageAdminFail', 'Debe eligir un genero valido!');
    } else if (edad < 18) {
      req.flash('messageAdminFail', 'Usted debe tener al menos 18 años!');
    } else {
      const data = [nombre, apellido, genero, fnacimiento, idAdm];
      await db.query(
        `UPDATE administradores SET nombres = $1, apellidos = $2,
        genero = $3, fecha_nacim = $4
        WHERE id_adm = $5`,
        data
      );

      req.flash('messageAdmin', 'Se actualizo correctamente el perfil');
    }
  } catch (e) {
    console.log(e);
    req.flash('messageAdminFail', 'No se pudo actualizar el perfil');
  }
};

const updatePass = async (req, id, newPass, confirmPass) => {
  try {
    if (newPass.length < 8) {
      req.flash(
        'messageAdminFail',
        'La contraseña debe tener al menos 8 caracteres'
      );
    } else if (newPass === confirmPass) {
      await db.query(
        `UPDATE administradores
        SET	contrasena_usu = $1
        WHERE id_adm = $2`,
        [newPass, id]
      );
      req.flash('messageAdmin', 'Se actualizó correctamente el contraseña');
    } else {
      req.flash(
        'messageAdminFail',
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

const newAdmin = async (
  req,
  nombre,
  apellido,
  genero,
  fnacimiento,
  mail,
  pass
) => {
  try {
    const edad = calcularEdad(fnacimiento);
    if (genero === 'none') {
      req.flash('messageAdminFail', 'Debe eligir un genero valido!');
    } else if (pass.length < 8) {
      req.flash(
        'messageAdminFail',
        'La contraseña debe tener al menos 8 caracteres!'
      );
    } else if (edad < 18) {
      req.flash(
        'messageAdminFail',
        'El nuevo administrador debe ser mayor de edad!'
      );
    } else {
      const data = [nombre, apellido, genero, fnacimiento, mail, pass];
      await db.query(
        `INSERT INTO administradores(
          nombres, apellidos, genero, fecha_nacim, email_usu, contrasena_usu)
          VALUES ($1, $2, $3, $4, $5, $6)`,
        data
      );
      req.flash(
        'messageAdmin',
        'Se registro correctamente el nuevo administrador'
      );
    }
  } catch (e) {
    console.log(e);
    req.flash(
      'messageAdminFail',
      'El ocurrio un error al registrar administrador !'
    );
  }
};

const dateFormat = (date) => {
  dia = date.getDate();
  mes = parseInt(date.getMonth()) + 1;
  anio = date.getFullYear();
  return `${dia < 10 ? '0' + dia : dia}/${mes < 10 ? '0' + mes : mes}/${anio}`;
};

const coinFormat = (coin) => {
  return `$ ${coin.toFixed(2)}`;
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
exports.getLatestSub = getLatestSub;
exports.getArtistFilter = getArtistFilter;
exports.getArtistPdf = getArtistPdf;
exports.getArtistReport = getArtistReport;
exports.getAllPlan = getAllPlan;
exports.insertPlan = insertPlan;
exports.deletePlan = deletePlan;
exports.updatePlan = updatePlan;
exports.updatePerfil = updatePerfil;
exports.updatePass = updatePass;
exports.newAdmin = newAdmin;
