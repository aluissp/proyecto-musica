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
  const img = path.join(__dirname, '../public/img/epicentro-bar.jpg');
  doc.image(img, 460, 10, { width: 100 });

  // set the header to render in every page
  doc.setDocumentHeader({ height: '8%' }, () => {
    doc.moveUp();
    doc.fill('#115dc8').fontSize(20).text('REPORTES', 240, 30);
  });

  const header = [
    { key: 'labelData', label: 'Datos Personales', aling: 'left' },
    { key: 'userData', label: '', aling: 'left' },
  ];

  const userData = [
    { labelData: 'Nombre artístico', userData: req.user.seudonimo_art },
    { labelData: 'Correo electrónico', userData: req.user.email_art },
    { labelData: 'País', userData: req.user.pais_art },
  ];

  doc.addTable(header, userData, {
    border: { size: 0.1, color: '#cdcdcd' },
    width: 'fill_body',
    striped: true,
    stripedColors: ['#ffffff', '#ffffff'],
    // stripedColors: ['#fff', '#f0ecd5'],
    headBackground: '#ffffff',
    cellsPadding: 10,
    cellsFontSize: 9,
    marginLeft: 45,
    marginRight: 45,
    headAlign: 'left',
    cellsAlign: 'left',
  });

  doc.addTable(colum, tabla, {
    border: null,
    width: 'fill_body',
    striped: true,
    headBackground: '#b1bfca',
    stripedColors: ['#ffffff', '#e3f2fd'],
    cellsPadding: 10,
    marginLeft: 45,
    marginRight: 45,
    headAlign: 'left',
  });

  const colf = [{ key: 'summary', label: 'Resumen', aling: 'left' }];
  let dataf;
  if (isSong) {
    const footer = summarySong(tabla);
    dataf = [
      { summary: `Se filtro: ${footer.nroCanciones} canciones` },
      {
        summary: `La duracion total es: ${footer.durTotal.hour} horas con ${footer.durTotal.minute} minutos y ${footer.durTotal.second} segundos`,
      },
    ];
  } else {
    const footer = summaryAlbum(tabla);
    dataf = [
      { summary: `Se filtro: ${footer.nroAlbumes} albumes` },
      { summary: `El precio total es: $ ${footer.precioTotal}` },
      { summary: `El numero de pistas es: ${footer.pistasTotal}` },
    ];
  }

  doc.addTable(colf, dataf, {
    border: null,
    width: 'fill_body',
    striped: true,
    headBackground: '#ffffff',
    stripedColors: ['#ffffff', '#ffffff'],
    cellsPadding: 3,
    cellsFontSize: 10,
    marginLeft: 45,
    marginRight: 45,
    headAlign: 'left',
    cellsAlign: 'left',
  });

  doc.render();

  // doc.setPageNumbers((p, c) => `Página ${p} de ${c}`, 'bottom right');
  doc.end();
};

const getBillReport = async (
  idArt,
  tabla,
  ordenar,
  wordkey,
  ordenar2,
  planfilter,
  cardfilter
) => {
  try {
    const consulta1 = await db.query(
      'SELECT nombre_alb FROM albumes WHERE id_art = $1',
      [idArt]
    );
    const consulta2 = await db.query('SELECT nombre_pl FROM planes');
    const consulta3 = await db.query(
      'SELECT numero_tar FROM tarjetas_artistas WHERE id_art = $1',
      [idArt]
    );

    const headerTable = [
      { column_name: 'Album' },
      { column_name: 'Numero de pistas' },
      { column_name: 'Precio' },
      { column_name: 'Fecha' },
      { column_name: 'Género' },
    ];

    const consultadefaultmusic = await db.query(
      'SELECT nombre_alb, numpistas_alb, precio_alb, fecha_alb, nombre_gen FROM albumes INNER JOIN generos USING(id_gen) WHERE id_art = $1',
      [idArt]
    );
    const response = {
      headerTable,
      report: consultadefaultmusic.rows,
      albumes: consulta1.rows,
      inMusic: false,
      inFac: true,
      planes: consulta2.rows,
      tarjetas: consulta3.rows,
    };

    if (tabla === 'planes') {
      const headerTableFac = [
        { column_name: 'Orden #: Plan' },
        { column_name: 'Fecha inicio' },
        { column_name: 'Fecha fin' },
        { column_name: 'Subtotal' },
        { column_name: 'iva' },
        { column_name: 'Total' },
      ];
      const consulta = await db.query(
        `SELECT CONCAT(id_sus,': ', nombre_pl) orden, finico_sus, ffin_sus,subtotal_sus, iva_sus,total_sus
        FROM suscripciones INNER JOIN planes USING(id_pl)
        WHERE id_art = $1 AND nombre_pl LIKE '${planfilter}%'
        AND CONCAT(id_sus,': ', nombre_pl) LIKE '${wordkey}%'
        ORDER BY ${ordenar} ${ordenar2};`,
        [idArt]
      );

      response.reportFac = consulta.rows;
      response.headerTableFac = headerTableFac;

      return response;
    } else if (tabla === 'tarjetas_artistas' && wordkey === '') {
      const headerTableFac = [
        { column_name: 'Orden #: Plan' },
        { column_name: 'Fecha inicio' },
        { column_name: 'Fecha fin' },
        { column_name: 'Subtotal' },
        { column_name: 'iva' },
        { column_name: 'Total' },
        { column_name: 'Nro. tarjeta' },
      ];
      const consulta = await db.query(
        `SELECT CONCAT(id_sus,': ', nombre_pl) orden, finico_sus, ffin_sus,subtotal_sus, iva_sus,total_sus, tarjeta_fac
        FROM suscripciones INNER JOIN planes USING(id_pl)
        WHERE id_art = $1 AND tarjeta_fac LIKE '${cardfilter}%'
        ORDER BY ${ordenar} ${ordenar2}`,
        [idArt]
      );
      response.reportFac = consulta.rows;
      response.headerTableFac = headerTableFac;

      return response;
    } else if (tabla === 'tarjetas_artistas' && wordkey !== '') {
      const headerTableFac = [
        { column_name: 'Tipo de tarjeta' },
        { column_name: 'Nro. de tarjeta' },
        { column_name: 'Fecha de caducidad' },
      ];
      const consulta = await db.query(
        `SELECT tipo_tar, numero_tar, fcaducidad
        FROM tarjetas_artistas
        WHERE id_art = $1 AND numero_tar LIKE '${wordkey}%'
        ORDER BY fcaducidad;`,
        [idArt]
      );
      response.reportCard = consulta.rows;
      response.headerTableFac = headerTableFac;
      response.isCard = true;
      return response;
    }
  } catch (e) {
    console.log(e);
  }
};

const getBillPDF = async (req, doc, content) => {
  const { headerTableFac, reportFac, reportCard, isCard } = content;
  const tabla = reportFac || reportCard;
  const colum = [];
  for (let key in tabla[0]) {
    colum.push({ key });
  }

  for (let i = 0; i < colum.length; i++) {
    colum[i].label = headerTableFac[i].column_name;
    colum[i].align = 'left';
  }

  if (!isCard) {
    tabla.forEach((row) => {
      row.finico_sus = dateFormat(row.finico_sus);
      row.ffin_sus = dateFormat(row.ffin_sus);
      row.subtotal_sus = `$ ${row.subtotal_sus.toFixed(2)}`;
      row.iva_sus = `$ ${row.iva_sus.toFixed(2)}`;
      row.total_sus = `$ ${row.total_sus.toFixed(2)}`;
    });
  } else {
    tabla.forEach((row) => {
      row.fcaducidad = dateFormat(row.fcaducidad);
    });
  }

  const img = path.join(__dirname, '../public/img/epicentro-bar.jpg');
  doc.image(img, 460, 10, { width: 100 });

  // set the header to render in every page
  doc.setDocumentHeader({ height: '8%' }, () => {
    doc.moveUp();
    doc.fill('#115dc8').fontSize(20).text('FACTURACIÓN', 240, 30);
  });

  const header = [
    { key: 'labelData', label: 'Datos Personales', aling: 'left' },
    { key: 'userData', label: '', aling: 'left' },
  ];

  const userData = [
    { labelData: 'Nombre artístico', userData: req.user.seudonimo_art },
    { labelData: 'Correo electrónico', userData: req.user.email_art },
    { labelData: 'País', userData: req.user.pais_art },
  ];

  doc.addTable(header, userData, {
    border: { size: 0.1, color: '#cdcdcd' },
    width: 'fill_body',
    striped: true,
    stripedColors: ['#ffffff', '#ffffff'],
    // stripedColors: ['#fff', '#f0ecd5'],
    headBackground: '#ffffff',
    cellsPadding: 10,
    cellsFontSize: 9,
    marginLeft: 45,
    marginRight: 45,
    headAlign: 'left',
    cellsAlign: 'left',
  });

  doc.addTable(colum, tabla, {
    border: null,
    width: 'fill_body',
    striped: true,
    headBackground: '#b1bfca',
    stripedColors: ['#ffffff', '#e3f2fd'],
    cellsPadding: 10,
    marginLeft: 45,
    marginRight: 45,
    headAlign: 'left',
  });

  billPageCard(tabla);
  /*
  const colf = [{ key: 'summary', label: 'Resumen', aling: 'left' }];
  let dataf;
  if (isSong) {
    const footer = summarySong(tabla);
    dataf = [
      { summary: `Se filtro: ${footer.nroCanciones} canciones` },
      {
        summary: `La duracion total es: ${footer.durTotal.hour} horas con ${footer.durTotal.minute} minutos y ${footer.durTotal.second} segundos`,
      },
    ];
  } else {
    const footer = summaryAlbum(tabla);
    dataf = [
      { summary: `Se filtro: ${footer.nroAlbumes} albumes` },
      { summary: `El precio total es: $ ${footer.precioTotal}` },
      { summary: `El numero de pistas es: ${footer.pistasTotal}` },
    ];
  }

  doc.addTable(colf, dataf, {
    border: null,
    width: 'fill_body',
    striped: true,
    headBackground: '#ffffff',
    stripedColors: ['#ffffff', '#ffffff'],
    cellsPadding: 3,
    cellsFontSize: 10,
    marginLeft: 45,
    marginRight: 45,
    headAlign: 'left',
    cellsAlign: 'left',
  });*/

  doc.render();

  // doc.setPageNumbers((p, c) => `Página ${p} de ${c}`, 'bottom right');
  doc.end();
};

const getDefaultBillReport = async (idArt) => {
  const headerTableFac = [
    { column_name: 'Orden #: Plan' },
    { column_name: 'Fecha inicio' },
    { column_name: 'Fecha fin' },
    { column_name: 'Subtotal' },
    { column_name: 'iva' },
    { column_name: 'Total' },
  ];

  const consulta1 = await db.query(
    `SELECT CONCAT(id_sus,': ', nombre_pl) orden, finico_sus, ffin_sus,subtotal_sus, iva_sus,total_sus
    FROM suscripciones INNER JOIN planes USING(id_pl)
    WHERE id_art = $1 ORDER BY finico_sus DESC`,
    [idArt]
  );
  const consulta2 = await db.query('SELECT nombre_pl FROM planes');
  const consulta3 = await db.query(
    'SELECT numero_tar FROM tarjetas_artistas WHERE id_art = $1',
    [idArt]
  );

  const response = {
    planes: consulta2.rows,
    tarjetas: consulta3.rows,
    reportFac: consulta1.rows,
    headerTableFac,
  };

  return response;
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

const summarySong = (table) => {
  let nroCanciones = 0;
  let hour = 0;
  let minute = 0;
  let second = 0;
  for (let row of table) {
    nroCanciones++;
    let fdate = new Date(`January 01, 2022 ${row.duracion_can}`);
    hour += fdate.getHours();
    minute += fdate.getMinutes();
    second += fdate.getSeconds();
    if (second >= 60) {
      second = 0;
      minute += 1;
    }

    if (minute >= 60) {
      minute = 0;
      hour += 1;
    }
  }
  const durTotal = {
    hour,
    minute,
    second,
  };
  return { nroCanciones, durTotal };
};

const dateFormat = (date) => {
  dia = date.getDate();
  mes = parseInt(date.getMonth()) + 1;
  anio = date.getFullYear();
  return `${dia < 10 ? '0' + dia : dia}/${mes < 10 ? '0' + mes : mes}/${anio}`;
};

const billPageCard = (table) => {
  let cards = [];

  for (let row of table) {
    console.log(row);
    if (cards.length === 0) {
      cards.push(row.tarjeta_fac);
    }
    for (const card of cards) {
      if (!(card === row.tarjeta_fac)) {
        cards.push(row.tarjeta_fac);
      }
    }
  }
  console.log(cards);
  //return { nroAlbumes, precioTotal, pistasTotal };
};

const getSummaryMusic = async (idArt) => {
  try {
    const consulta1 = await db.query(
      `SELECT id_alb, nombre_alb, numpistas_alb, fecha_alb, nombre_gen
      FROM albumes INNER JOIN generos USING(id_gen)
      WHERE id_art = $1
      ORDER BY numpistas_alb`,
      [idArt]
    );

    const albumes = consulta1.rows;
    for (const album of albumes) {
      const consulta2 = await db.query(
        `SELECT nombre_can, duracion_can, nropista_can
        FROM canciones
        WHERE id_alb = $1
        ORDER BY nropista_can`,
        [album.id_alb]
      );
      album.canciones = consulta2.rows;
    }

    return albumes;
  } catch (e) {
    console.log(e);
  }
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
exports.getBillReport = getBillReport;
exports.getBillPDF = getBillPDF;
exports.getDefaultBillReport = getDefaultBillReport;
exports.getSummaryMusic = getSummaryMusic;
