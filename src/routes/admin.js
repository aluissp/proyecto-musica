const express = require('express'); // Importamos la libreria
const router = express.Router();
const { isLoggedIn, isNotLoggedIn } = require('../lib/auth');
const { getPlans } = require('../lib/suscription');
const {
  getArtistFilter,
  getArtistPdf,
  getArtistReport,
  getAllPlan,
  //Insertar Plan
  insertPlan,
  deletePlan,
  updatePlan,
  updatePerfil,
  updatePass,
  newAdmin,
} = require('../lib/adminManagement');

// Perfil
router
  .route('/')
  .get(isLoggedIn, (req, res) => {
    const generos = [
      { valor: 'Hombre' },
      { valor: 'Mujer' },
      { valor: 'Otro' },
    ];

    for (const genero of generos) {
      if (genero.valor === req.user.genero) {
        genero.selected = 'selected';
      }
    }
    res.render('admin/admin', { generos });
  })
  .post(async (req, res) => {
    const { nombre, apellido, genero, fnacimiento } = req.body;

    await updatePerfil(
      req,
      req.user.id_adm,
      nombre,
      apellido,
      genero,
      fnacimiento
    );
    res.redirect('/admin');
  });

router.route('/pass').post(async (req, res) => {
  const { chPass, confPass } = req.body;
  await updatePass(req, req.user.id_adm, chPass, confPass);

  res.redirect('/admin');
});

// Nuevo Admin
router
  .route('/newAdmin')
  .get(isLoggedIn, (req, res) => {
    res.render('admin/newAdmin');
  })
  .post(async (req, res) => {
    const { nombre, apellido, genero, fnacimiento, mail, pass } = req.body;
    await newAdmin(req, nombre, apellido, genero, fnacimiento, mail, pass);
    res.redirect('/admin/newAdmin');
  });

// Report Artist
router
  .route('/art')
  .get(isLoggedIn, async (req, res) => {
    const response = await getArtistFilter();
    const planList = await getPlans();
    response.planList = planList;
    res.render('admin/artist', response);
  })
  .post(async (req, res) => {
    const response = await getArtistFilter(req.body);
    const planList = await getPlans();
    response.planList = planList;

    res.render('admin/artist', response);
  });

router.route('/art/pdf').post(async (req, res) => {
  const response = await getArtistFilter(req.body);

  getArtistPdf(req, res, response);
});

router.route('/art/pdf/:mail').get(async (req, res) => {
  const { mail } = req.params;
  await getArtistReport(req, res, mail);
});

// Report User
router.route('/user').get(isLoggedIn, (req, res) => {
  res.render('admin/user');
});

// Manager Plan
router
  .route('/planes')
  .get(isLoggedIn, async (req, res) => {
    const planes = await getAllPlan();

    res.render('admin/plan', { planes });
  })
  .post(async (req, res) => {
    const { nombre, descripcion, precio, duracion } = req.body;
    await insertPlan(req, nombre, descripcion, precio, duracion);

    res.redirect('/admin/planes');
  });

router.route('/planes/delete/:idPlan').get(async (req, res) => {
  const { idPlan } = req.params;
  await deletePlan(req, idPlan);
  res.redirect('/admin/planes');
});

router.route('/planes/edit/:idPlan').post(async (req, res) => {
  const { idPlan } = req.params;
  const { nombre, descripcion, precio, duracion } = req.body;
  await updatePlan(req, nombre, descripcion, precio, duracion, idPlan);

  res.redirect('/admin/planes');
});

exports.router = router;
