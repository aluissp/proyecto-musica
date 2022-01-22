const express = require('express'); // Importamos la libreria
const router = express.Router();
const { getCardArt, getPlans, getSuscriptions, getCurrentPlan, insertCard } = require('../lib/suscription');

router.route('/art')
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
            defaultview: true
        }
        res.render('profile/profileArt', artSubInfo);
    });

router.route('/art/:view')
    .get(async (req, res) => {
        const nrovista = req.params.view;
        const tarjetas = await getCardArt(req.user.id_art);
        const suscripciones = await getSuscriptions(req.user.id_art);
        const planes = await getPlans();
        const planActual = await getCurrentPlan(req.user.id_art);
        const artSubInfo = {
            tarjetas,
            suscripciones,
            planes,
            planActual
        }

        if (nrovista === '1') {
            artSubInfo.inpro = true;
        } else if (nrovista === '2') {
            artSubInfo.inpass = true;
        } else if (nrovista === '3') {
            artSubInfo.insus = true;
        } else if (nrovista === '4') {
            artSubInfo.incard = true;
        }

        res.render('profile/profileArt', artSubInfo);
    });

router.route('/art/card')
    .post(async (req, res) => {


        const { tipotarjetas, nrotarjeta, fcaducidad } = req.body;
        const id = req.user.id_art;
        const newCard = [
            id,
            tipotarjetas,
            nrotarjeta,
            fcaducidad
        ]

        const response = await insertCard(newCard);
        if (response) {
            console.log(response);
            req.flash('message_card', response);
        }
        req.flash('message_card_success', 'La tarjeta se ha guardado con exito');
        res.redirect('/profile/art/4');
    });


exports.router = router;