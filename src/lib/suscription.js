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

exports.getCardArt = getCardArt;
exports.getPlans = getPlans;
exports.getSuscriptions = getSuscriptions;
exports.getCurrentPlan = getCurrentPlan;
exports.insertCard = insertCard;