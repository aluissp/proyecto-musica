const { db } = require('../conexion');
const {
  construcPdf,
  insertHeader,
  insertTableWhite,
  insertTable,
} = require('../lib/pdfSimple');

const getFullBill = async (idArt) => {
  try {
    const consulta = await db.query(
      `SELECT codigo_fac, fechaemision_fac, subtotal_fac, iva_fac, total_fac, tarjeta_fac, id_alb
      FROM facturas INNER JOIN detalles_facturas USING(codigo_fac)
      WHERE id_usu = $1
      ORDER BY fechaemision_fac`,
      [idArt]
    );
    return consulta.rows;
  } catch (e) {
    console.log(e);
  }
};

const insertBill = async (req, res, idUser, idAlb, card) => {
  try {
    await db.query(
      `INSERT INTO facturas(id_usu, tarjeta_fac)
      VALUES($1, $2)`,
      [idUser, card]
    );

    const consulta1 = await db.query(`SELECT Obtener_UltimoIdFac($1)`, [
      idUser,
    ]);
    const idFac = consulta1.rows[0].obtener_ultimoidfac;
    await db.query(`SELECT Completar_Factura($1, $2, $3)`, [
      idAlb,
      idUser,
      idFac,
    ]);

    // Generando pdf
    let doc = construcPdf(res, `facturación ${req.user.nombres}`);
    doc = insertHeader(doc, 'Factura de compra');

    doc = await generateBillHeader(doc, req, idAlb);
    doc = await generateBillBody(doc, idUser, idAlb);

    doc.render();
    doc.end();
  } catch (e) {
    console.log(e);
  }
};

const generateBillBody = async (doc, idUser, idAlb) => {
  const billRow = [
    { key: 'codigo_fac', label: 'Código de facturación', aling: 'left' },
    { key: 'fechaemision_fac', label: 'Fecha de emisión', aling: 'left' },
    { key: 'subtotal_fac', label: 'Subtotal', aling: 'left' },
    { key: 'iva_fac', label: 'iva', aling: 'left' },
    { key: 'total_fac', label: 'Total', aling: 'left' },
  ];

  const consulta1 = await db.query(
    `SELECT codigo_fac, fechaemision_fac, subtotal_fac, iva_fac, total_fac
    FROM facturas INNER JOIN detalles_facturas USING(codigo_fac)
    WHERE id_usu = $1 AND id_alb = $2
    `,
    [idUser, idAlb]
  );
  const billTable = consulta1.rows;

  billTable.forEach((row) => {
    row.fechaemision_fac = dateFormat(row.fechaemision_fac);
    row.subtotal_fac = coinFormat(row.subtotal_fac);
    row.iva_fac = coinFormat(row.iva_fac);
    row.total_fac = coinFormat(row.total_fac);
  });

  doc = insertTableWhite(doc, billTable, billRow);

  const detailBillRow = [
    { key: 'codigo_fac', label: 'Código de facturación', aling: 'left' },
    { key: 'nombre_alb', label: 'Album', aling: 'left' },
    { key: 'fecha_alb', label: 'Fecha de lazamiento', aling: 'left' },
    { key: 'descripcion_fac', label: 'Descripción', aling: 'left' },
  ];

  const consulta2 = await db.query(
    `SELECT codigo_fac, nombre_alb, fecha_alb, descripcion_fac
    FROM detalles_facturas INNER JOIN albumes USING(id_alb)
    WHERE codigo_fac = $1
    `,
    [billTable[0].codigo_fac]
  );
  const detailBillTable = consulta2.rows;

  detailBillTable.forEach((row) => {
    row.fecha_alb = dateFormat(row.fecha_alb);
  });
  doc = insertTableWhite(doc, detailBillTable, detailBillRow);

  const songsRow = [
    { column_name: 'Nombre de la canción' },
    { column_name: 'Género' },
    { column_name: 'Duración' },
    { column_name: 'Nro. pista' },
  ];

  const consulta3 = await db.query(
    `SELECT nombre_can, nombre_gen, duracion_can, nropista_can
     FROM canciones INNER JOIN albumes USING(id_alb)
     INNER JOIN generos USING(id_gen)
     WHERE id_alb = $1
     ORDER BY nropista_can`,
    [idAlb]
  );
  const songsTable = consulta3.rows;
  doc = insertTable(doc, songsTable, songsRow);
  return doc;
};

const generateBillHeader = async (doc, req, idAlb) => {
  const header = [
    { key: 'labelData', label: 'Datos Personales', aling: 'left' },
    { key: 'userData', label: '', aling: 'left' },
  ];

  const consulta = await db.query(
    `SELECT tarjeta_fac
    FROM facturas INNER JOIN detalles_facturas USING(codigo_fac)
    WHERE id_usu = $1 AND id_alb = $2`,
    [req.user.id_usu, idAlb]
  );
  const tarjeta = consulta.rows[0].tarjeta_fac;

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
    { labelData: 'Tarjeta', userData: tarjeta },
  ];

  doc = insertTableWhite(doc, userData, header);
  return doc;
};

const getBill = async (
  filtros,
  codigoFac,
  tarjetaFac,
  ordenar,
  ordenar2,
  wordkey,
  idUser
) => {
  try {
    let response;
    if (filtros === 'facturas') {
      if (wordkey === '') {
        const consulta = await db.query(
          `SELECT codigo_fac, fechaemision_fac, subtotal_fac, iva_fac, total_fac, tarjeta_fac, id_alb
          FROM facturas INNER JOIN detalles_facturas USING(codigo_fac)
          WHERE codigo_fac = $1
          ORDER BY ${ordenar} ${ordenar2}
          `,
          [codigoFac]
        );
        response = consulta.rows;
      } else {
        const consulta = await db.query(
          `SELECT codigo_fac, fechaemision_fac, subtotal_fac, iva_fac, total_fac, tarjeta_fac, id_alb
          FROM facturas INNER JOIN detalles_facturas USING(codigo_fac)
          WHERE codigo_fac LIKE '${wordkey}%'
          ORDER BY ${ordenar} ${ordenar2}
          `
        );
        response = consulta.rows;
      }
    } else {
      if (wordkey === '') {
        const consulta = await db.query(
          `SELECT codigo_fac, fechaemision_fac, subtotal_fac, iva_fac, total_fac, tarjeta_fac, id_alb
          FROM facturas INNER JOIN detalles_facturas USING(codigo_fac)
          WHERE tarjeta_fac = $1 AND id_usu = $2
          ORDER BY ${ordenar} ${ordenar2}
          `,
          [tarjetaFac, idUser]
        );
        response = consulta.rows;
      } else {
        const consulta = await db.query(
          `SELECT codigo_fac, fechaemision_fac, subtotal_fac, iva_fac, total_fac, tarjeta_fac, id_alb
          FROM facturas INNER JOIN detalles_facturas USING(codigo_fac)
          WHERE tarjeta_fac LIKE '${wordkey}%' AND id_usu = $1
          ORDER BY ${ordenar} ${ordenar2}
          `,
          [idUser]
        );
        response = consulta.rows;
      }
    }
    return response;
  } catch (e) {
    console.log(e);
  }
};

const getBillPdf = async (req, res, idUser, idAlb) => {
  try {
    // Generando pdf
    let doc = construcPdf(res, `facturación ${req.user.nombres}`);
    doc = insertHeader(doc, 'Factura de compra');

    doc = await generateBillHeader(doc, req, idAlb);
    doc = await generateBillBody(doc, idUser, idAlb);

    doc.render();
    doc.end();
  } catch (e) {
    console.log(e);
  }
};

const getBillDetail = async (req, idAlb) => {
  try {
    const consulta = await db.query(
      `SELECT tarjeta_fac
      FROM facturas INNER JOIN detalles_facturas USING(codigo_fac)
      WHERE id_usu = $1 AND id_alb = $2`,
      [req.user.id_usu, idAlb]
    );
    const tarjeta = consulta.rows[0].tarjeta_fac;

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
      { labelData: 'Tarjeta', userData: tarjeta },
    ];

    const consulta1 = await db.query(
      `SELECT codigo_fac, fechaemision_fac, subtotal_fac, iva_fac, total_fac
      FROM facturas INNER JOIN detalles_facturas USING(codigo_fac)
      WHERE id_usu = $1 AND id_alb = $2
      `,
      [req.user.id_usu, idAlb]
    );
    const billTable = consulta1.rows;

    billTable.forEach((row) => {
      row.fechaemision_fac = dateFormat(row.fechaemision_fac);
      row.subtotal_fac = coinFormat(row.subtotal_fac);
      row.iva_fac = coinFormat(row.iva_fac);
      row.total_fac = coinFormat(row.total_fac);
    });

    const consulta2 = await db.query(
      `SELECT codigo_fac, nombre_alb, fecha_alb, descripcion_fac
      FROM detalles_facturas INNER JOIN albumes USING(id_alb)
      WHERE codigo_fac = $1
      `,
      [billTable[0].codigo_fac]
    );
    const detailBillTable = consulta2.rows;

    detailBillTable.forEach((row) => {
      row.fecha_alb = dateFormat(row.fecha_alb);
    });

    const consulta3 = await db.query(
      `SELECT nombre_can, nombre_gen, duracion_can, nropista_can
       FROM canciones INNER JOIN albumes USING(id_alb)
       INNER JOIN generos USING(id_gen)
       WHERE id_alb = $1
       ORDER BY nropista_can`,
      [idAlb]
    );
    const songsTable = consulta3.rows;
    const response = {
      userData,
      billTable,
      detailBillTable,
      songsTable,
    };

    return response;
  } catch (e) {
    console.log(e);
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

exports.getFullBill = getFullBill;
exports.insertBill = insertBill;
exports.generateBillBody = generateBillBody;
exports.generateBillHeader = generateBillHeader;
exports.getBill = getBill;
exports.getBillPdf = getBillPdf;
exports.getBillDetail = getBillDetail;
