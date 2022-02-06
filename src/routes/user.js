const express = require('express'); // Importamos la libreria
const router = express.Router();
const { isLoggedIn } = require('../lib/auth');
const { db } = require('../conexion');
const {
  exploreMusic,
  getFullArtist,
  getFullAlbum,
  updatePerfil,
  updatePass,
  getIva,
} = require('../user/user');

const {
  getUserCard,
  insertCard,
  updateCard,
  deleteCard,
} = require('../user/card');

const { getFullBill, insertBill } = require('../user/bill');
// Perfil
router
  .route('/')
  .get(isLoggedIn, async (req, res) => {
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
    res.render('user/perfil', { generos });
  })
  .post(async (req, res) => {
    const { nombre, apellido, genero, fnacimiento } = req.body;

    await updatePerfil(
      req,
      req.user.id_usu,
      nombre,
      apellido,
      genero,
      fnacimiento
    );
    res.redirect('/user');
  });

router.route('/pass').post(async (req, res) => {
  const { chPass, confPass } = req.body;
  await updatePass(req, req.user.id_usu, chPass, confPass);

  res.redirect('/user');
});

// Explorar
router
  .route('/explore')
  .get(isLoggedIn, (req, res) => {
    const noneData = {
      canciones: true,
      albumes: true,
      artistas: true,
    };
    res.render('user/explorar', noneData);
  })
  .post(async (req, res) => {
    const { wordkey } = req.body;
    const response = await exploreMusic(wordkey);
    res.render('user/explorar', response);
  });

// Artistas
router.route('/art/:idArt').get(async (req, res) => {
  const { idArt } = req.params;
  const response = await getFullArtist(idArt, req.user.id_usu);
  const tarjetas = await getUserCard(req.user.id_usu);
  const iva = await getIva();
  response.tarjetas = tarjetas;
  response.iva = iva;
  res.render('user/artist', response);
});

// Albumes
router.route('/art/album/:idAlb').get(async (req, res) => {
  const { idAlb } = req.params;
  const response = await getFullAlbum(idAlb);
  res.render('user/album', response);
});

// Facturas
router
  .route('/bill')
  .get(isLoggedIn, async (req, res) => {
    const facturas = await getFullBill(req.user.id_usu);
    const tarjetas = await getUserCard(req.user.id_usu);

    res.render('user/bill', { tarjetas, facturas });
  })
  .post(async (req, res) => {
    console.log(req.body);
    const facturas = await getFullBill(req.user.id_usu);
    const tarjetas = await getUserCard(req.user.id_usu);

    res.render('user/bill', { tarjetas, facturas });
  });

router.route('/bill/pdf').post(async (req, res) => {
  console.log(req.body);
});

// Tarjetas
router
  .route('/card')
  .get(async (req, res) => {
    const tarjetas = await getUserCard(req.user.id_usu);
    res.render('user/card', { tarjetas });
  })
  .post(async (req, res) => {
    const { tipotarjetas, nrotarjeta, fcaducidad } = req.body;
    const id = req.user.id_usu;
    const newCard = [id, tipotarjetas, nrotarjeta, fcaducidad];

    await insertCard(req, newCard);

    res.redirect('/user/card');
  });

router.route('/card/edit/:id').post(async (req, res) => {
  const { tipotarjetas, nrotarjeta, fcaducidad } = req.body;
  const id = req.params.id;
  const newCard = [tipotarjetas, nrotarjeta, fcaducidad, id];

  await updateCard(req, newCard);

  res.redirect('/user/card');
});

router.route('/card/delete/:id').get(async (req, res) => {
  const id = req.params.id;
  await deleteCard(req, id);
  res.redirect('/user/card');
});

router.route('/search/card').post(async (req, res) => {
  const { wordkey } = req.body;
  const tarjetas = await getUserCard(req.user.id_usu, wordkey);
  res.render('user/card', { tarjetas });
});

// Compras de albumes
router.route('/buy/:idAlb').post(async (req, res) => {
  const { tarjeta } = req.body;
  const { idAlb } = req.params;
  const idUser = req.user.id_usu;

  await insertBill(req, res, idUser, idAlb, tarjeta);
});

exports.router = router;
