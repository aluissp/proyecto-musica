const express = require('express'); // Importamos la libreria
const router = express.Router();
const { isLoggedIn } = require('../lib/auth');
const { exploreMusic, getFullArtist, getFullAlbum } = require('../user/user');

router.route('/').get(isLoggedIn, (req, res) => {
  res.render('user/perfil');
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
  const response = await getFullArtist(idArt);
  res.render('user/artist', response);
});

// Albumes
router.route('/art/album/:idAlb').get(async (req, res) => {
  const { idAlb } = req.params;
  const response = await getFullAlbum(idAlb);
  res.render('user/album', response);
});

router.route('/bill').get(isLoggedIn, (req, res) => {
  res.render('user/bill');
});

exports.router = router;
