const { db } = require('../conexion');
const path = require('path');

const getLatestSub = async () => {
  try {
    const response = await db.query(
      `SELECT seudonimo_art, email_art, finico_sus, nombre_pl, total_sus
       FROM artistas INNER JOIN suscripciones USING(id_art)
       INNER JOIN planes USING(id_pl)
       ORDER BY finico_sus DESC
       LIMIT 10`
    );

    const Subs = {};
    let total = 0;
    let i = 1;
    for (const sub of response.rows) {
      sub.numbers = i;
      total += sub.total_sus;
      i++;
    }

    Subs.latestSub = response.rows;
    Subs.Total = total;
    return Subs;
  } catch (e) {
    console.log(e);
  }
};


exports.getLatestSub = getLatestSub;
