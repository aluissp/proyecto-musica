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

const dateFormat = (date) => {
  dia = date.getDate();
  mes = parseInt(date.getMonth()) + 1;
  anio = date.getFullYear();
  return `${dia < 10 ? '0' + dia : dia}/${mes < 10 ? '0' + mes : mes}/${anio}`;
};

const coinFormat = (coin) => {
  return `$ ${coin.toFixed(2)}`;
};

exports.getLatestSub = getLatestSub;
exports.getArtistFilter = getArtistFilter;
exports.getArtistPdf = getArtistPdf;
exports.getArtistReport = getArtistReport;
exports.getAllPlan = getAllPlan;
