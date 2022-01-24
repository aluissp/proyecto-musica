const e = require('connect-flash');
const { response } = require('express');
const { db } = require('../conexion');

const getCardArt = async (idArt) => {
    const consulta = await db.query(`SELECT * FROM tarjetas_artistas WHERE id_art = $1`, [idArt]);
    return consulta.rows;
}

const getPlans = async () => {
    const consulta = await db.query('SELECT * FROM planes');
    return consulta.rows;
}

const getSuscriptions = async (idArt) => {
    const consulta = await db.query('SELECT * FROM suscripciones WHERE id_art = $1 ORDER BY finico_sus DESC', [idArt]);
    const listSuscriptions = consulta.rows;
    listSuscriptions.forEach(async (suscription) => {
        const reslt = await db.query('SELECT nombre_pl FROM planes WHERE id_pl = $1', [suscription.id_pl]);
        suscription.plan = reslt.rows[0].nombre_pl;
    });
    return listSuscriptions;
}

const getCurrentPlan = async (idArt) => {
    try {
        const consulta = await db.query('SELECT * FROM suscripciones WHERE id_art = $1 ORDER BY finico_sus DESC', [idArt]);

        const sus_plan = consulta.rows[0];
        var currentPlan = null;
        const hoy = new Date(Date.now());
        const ffin = sus_plan.ffin_sus;

        if (hoy <= ffin) {
            const plan = await db.query('SELECT * FROM planes where id_pl = $1', [sus_plan.id_pl]);
            currentPlan = plan.rows[0];
        }
        return currentPlan;
    } catch (e) {
        // console.log(e);
        return currentPlan;
    }
}

const insertCard = async (newCard) => {
    try {
        const hoy = new Date(Date.now());
        const fcaducidad = new Date(newCard[3]);

        if (!(newCard[2].length >= 16)) {
            return 'La tarjeta debe tener 16 numeros';
        } else if (fcaducidad < hoy) {
            return 'La fecha de caducidad debe ser mayor a la fecha actual';
        } else {
            await db.query('INSERT INTO tarjetas_artistas(id_art, tipo_tar, numero_tar, fcaducidad) VALUES($1, $2, $3, $4)', newCard);
        }

    } catch (e) {
        console.log(e);
    }
}

const updateCard = async (newCard) => {
    try {
        const hoy = new Date(Date.now());
        const fcaducidad = new Date(newCard[2]);

        if (!(newCard[1].length >= 16)) {
            return 'La tarjeta debe tener 16 numeros';
        } else if (fcaducidad < hoy) {
            return 'La fecha de caducidad debe ser mayor a la fecha actual';
        } else {
            await db.query('UPDATE tarjetas_artistas SET tipo_tar = $1, numero_tar = $2, fcaducidad = $3 WHERE id_tar = $4', newCard);
        }

    } catch (e) {
        console.log(e);
    }
}

const deleteCard = async (id) => {
    try {
        await db.query('DELETE FROM tarjetas_artistas WHERE id_tar = $1', [id]);
    } catch (e) {
        console.log(e);
    }
}

const buyPlan = async (idArt, idPlan) => {
    try {
        const hoy = new Date(Date.now());
        await db.query('INSERT INTO suscripciones(id_art, id_pl, finico_sus) VALUES($1, $2, $3)', [idArt, idPlan, hoy]);
        return 'Se ha comprado exitosamente su plan';
    } catch (e) {
        console.log(e);
    }
}

const changePass = async (idArt, pass1, pass2) => {
    try {
        if (pass1 !== pass2) {
            return 'Las contraseñas deben coincidir para continuar';
        } else if (!(pass1.length >= 10 && pass2.length >= 10)) {
            return 'La longitud de la contraseña debe ser mayor o igual a 10';
        } else {
            await db.query('UPDATE artistas SET contrasena_art = $1 WHERE id_art = $2', [pass1, idArt]);
        }
    } catch (e) {
        console.log(e);
    }
}

const changeProfile = async (idArt, artName, artMail, artPais) => {
    try {
        await db.query('UPDATE artistas SET seudonimo_art = $1, email_art =$2, pais_art = $3 WHERE id_art = $4', [artName, artMail, artPais, idArt]);
    } catch (e) {
        console.log(e);
        return 'Ocurrio un error al actualizar su perfil';
    }
}

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