const express = require('express'); // Importamos la libreria
const router = express.Router();
const PDF = require('pdfkit-construct');
// const fs = require('fs');
const {
  // Compra Planes
  getPlans,
  getSuscriptions,
  getCurrentPlan,
  buyPlan,
  // Tarjetas
  getCardArt,
  insertCard,
  updateCard,
  deleteCard,
  // Perfil
  changePass,
  changeProfile,
  // Reportes
  getMusicReport,
  getMusicPDF,
  getBillReport,
  getBillPDF,
  getDefaultBillReport,
} = require('../lib/suscription');

// Perfil
router
  .route('/art')
  .get(async (req, res) => {
    const tarjetas = await getCardArt(req.user.id_art);
    const suscripciones = await getSuscriptions(req.user.id_art);
    const planes = await getPlans();
    const planActual = await getCurrentPlan(req.user.id_art);
    const artSubInfo = {
      tarjetas,
      suscripciones,
      planes,
      planActual,
      defaultview: true,
    };
    // console.log(planes);
    res.render('artist/profileArt', artSubInfo);
  })
  .post(async (req, res) => {
    const { artName, artMail, artPais } = req.body;
    const response = await changeProfile(
      req.user.id_art,
      artName,
      artMail,
      artPais
    );
    if (response) {
      req.flash('change_profile_fail', response);
    } else {
      req.flash(
        'change_profile_success',
        'Se actualizo correctamente su informacion'
      );
    }
    res.redirect('/profile/art/1');
  });

router.route('/art/passchange').post(async (req, res) => {
  const { pass1, pass2 } = req.body;
  const response = await changePass(req.user.id_art, pass1, pass2);
  if (response) {
    req.flash('change_pass_fail', response);
  } else {
    req.flash(
      'change_pass_success',
      'Se actualizo correctamente la contraseña'
    );
  }
  res.redirect('/profile/art/2');
});

router.route('/art/:view').get(async (req, res) => {
  const nrovista = req.params.view;
  const tarjetas = await getCardArt(req.user.id_art);
  const suscripciones = await getSuscriptions(req.user.id_art);
  const planes = await getPlans();
  const planActual = await getCurrentPlan(req.user.id_art);
  const artSubInfo = {
    tarjetas,
    suscripciones,
    planes,
    planActual,
  };

  if (nrovista === '1') {
    artSubInfo.inpro = true;
  } else if (nrovista === '2') {
    artSubInfo.inpass = true;
  } else if (nrovista === '3') {
    artSubInfo.insus = true;
  } else if (nrovista === '4') {
    artSubInfo.incard = true;
  }

  res.render('artist/profileArt', artSubInfo);
});

router.route('/art/card').post(async (req, res) => {
  const { tipotarjetas, nrotarjeta, fcaducidad } = req.body;
  const id = req.user.id_art;
  const newCard = [id, tipotarjetas, nrotarjeta, fcaducidad];

  const response = await insertCard(newCard);
  if (response) {
    console.log(response);
    req.flash('message_card', response);
  } else {
    req.flash('message_card_success', 'La tarjeta se ha guardado con exito');
  }
  res.redirect('/profile/art/4');
});

router.route('/art/card/delete/:id').get(async (req, res) => {
  const id = req.params.id;
  await deleteCard(id);
  req.flash('message_card', 'La tarjeta se eliminó correctamente');
  res.redirect('/profile/art/4');
});
router.route('/art/card/edit/:id').post(async (req, res) => {
  const { tipotarjetas, nrotarjeta, fcaducidad } = req.body;
  const id = req.params.id;
  const newCard = [tipotarjetas, nrotarjeta, fcaducidad, id];

  const response = await updateCard(newCard);
  if (response) {
    console.log(response);
    req.flash('message_card', response);
  } else {
    req.flash('message_card_success', 'La tarjeta se ha actualizado con exito');
  }
  res.redirect('/profile/art/4');
});

// Suscripciones
router.route('/art/sub/:idplan').post(async (req, res) => {
  const idplan = req.params.idplan;
  const idart = req.user.id_art;
  const response = await buyPlan(idart, idplan);
  if (response) {
    console.log(response);
    req.flash('buy_art_success', response);
  } else {
    req.flash('buy_art_fail', 'Ha ocurrido un error en la compra');
  }
  res.redirect('/profile/art/3');
});

// Reportes default
router.route('/report').get(async (req, res) => {
  const response = await getMusicReport(req.user.id_art);
  const { planes, tarjetas, reportFac, headerTableFac } =
    await getDefaultBillReport(req.user.id_art);
  response.planes = planes;
  response.tarjetas = tarjetas;
  response.reportFac = reportFac;
  response.headerTableFac = headerTableFac;
  res.render('artist/report', response);
});

// Musica
router.route('/report/music').post(async (req, res) => {
  const { filtros, ordenar, wordkey, ordenar2, albumfilter } = req.body;
  const response = await getMusicReport(
    req.user.id_art,
    filtros,
    ordenar,
    wordkey,
    ordenar2,
    albumfilter
  );
  const { planes, tarjetas, reportFac, headerTableFac } =
    await getDefaultBillReport(req.user.id_art);
  response.planes = planes;
  response.tarjetas = tarjetas;
  response.reportFac = reportFac;
  response.headerTableFac = headerTableFac;
  res.render('artist/report', response);
});
router.route('/report/music/pdf').post(async (req, res) => {
  const { filtros, ordenar, wordkey, ordenar2, albumfilter } = req.body;
  const response = await getMusicReport(
    req.user.id_art,
    filtros,
    ordenar,
    wordkey,
    ordenar2,
    albumfilter
  );

  const doc = new PDF({
    bufferPages: true,
    font: 'Helvetica',
    size: 'A4',
    margins: { top: 20, left: 10, right: 10, bottom: 20 },
  });
  const stream = res.writeHead(200, {
    'Content-Type': 'application/pdf',
    'Content-disposition': `attachment;filename=ReporteMusica_${req.user.seudonimo_art}.pdf`,
  });

  doc.on('data', (data) => {
    stream.write(data);
  });
  doc.on('end', () => {
    stream.end();
  });
  await getMusicPDF(req, doc, response);
});
// Factura 'suscripcion'
router.route('/report/bill').post(async (req, res) => {
  const { filtros, ordenar, wordkey, ordenar2, planfilter, cardfilter } =
    req.body;
  const response = await getBillReport(
    req.user.id_art,
    filtros,
    ordenar,
    wordkey,
    ordenar2,
    planfilter,
    cardfilter
  );
  res.render('artist/report', response);
});
router.route('/report/bill/pdf').post(async (req, res) => {
  const { filtros, ordenar, wordkey, ordenar2, planfilter, cardfilter } =
    req.body;
  const response = await getBillReport(
    req.user.id_art,
    filtros,
    ordenar,
    wordkey,
    ordenar2,
    planfilter,
    cardfilter
  );

  const doc = new PDF({
    bufferPages: true,
    font: 'Helvetica',
    size: 'A4',
    margins: { top: 20, left: 10, right: 10, bottom: 20 },
  });
  const stream = res.writeHead(200, {
    'Content-Type': 'application/pdf',
    'Content-disposition': `attachment;filename=ReporteSuscripcion_${req.user.seudonimo_art}.pdf`,
  });

  doc.on('data', (data) => {
    stream.write(data);
  });
  doc.on('end', () => {
    stream.end();
  });
  await getBillPDF(req, doc, response);
});

exports.router = router;
