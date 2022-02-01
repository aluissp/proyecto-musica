const express = require('express'); // Importamos la libreria
const router = express.Router();
const { isLoggedIn, isNotLoggedIn } = require('../lib/auth');
const { getPlans } = require('../lib/suscription');
const {
  getArtistFilter,
  getArtistPdf,
  getArtistReport,
  getAllPlan,
} = require('../lib/adminManagement');
// Perfil
router.route('/').get(isLoggedIn, (req, res) => {
  res.render('admin/admin');
});

// Nuevo Admin
router.route('/newAdmin').get(isLoggedIn, (req, res) => {
  res.render('admin/newAdmin');
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
router.route('/planes').get(isLoggedIn, async (req, res) => {
  const planes = await getAllPlan();

  res.render('admin/plan', { planes });
});

exports.router = router;
