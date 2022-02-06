const { db } = require('../conexion');

const getUserCard = async (idUser, wordkey) => {
  try {
    wordkey = wordkey || '%';
    const consulta = await db.query(
      `SELECT * FROM tarjetas_usuarios
      WHERE id_usu = $1 AND numero_tar LIKE '${wordkey}%'
      ORDER BY fcaducidad_tar`,
      [idUser]
    );
    return consulta.rows;
  } catch (e) {
    console.log(e);
  }
};

const insertCard = async (req, newCard) => {
  try {
    const hoy = new Date(Date.now());
    const fcaducidad = new Date(newCard[3]);

    if (!(newCard[2].length === 16)) {
      req.flash('messageUserFail', 'La tarjeta debe tener 16 numeros');
    } else if (fcaducidad < hoy) {
      req.flash(
        'messageUserFail',
        'La fecha de caducidad debe ser mayor a la fecha actual'
      );
    } else {
      await db.query(
        'INSERT INTO tarjetas_usuarios(id_usu, tipo_tar, numero_tar, fcaducidad_tar) VALUES($1, $2, $3, $4)',
        newCard
      );
      req.flash('messageUser', 'Se registró correctamente la nueva tarjeta');
    }
  } catch (e) {
    console.log(e);
    req.flash('messageUserFail', 'Ocurrió un error al registrar la tarjeta');
  }
};

const updateCard = async (req, newCard) => {
  try {
    const hoy = new Date(Date.now());
    const fcaducidad = new Date(newCard[2]);

    if (!(newCard[1].length >= 16)) {
      req.flash('messageUserFail', 'La tarjeta debe tener 16 numeros');
    } else if (fcaducidad < hoy) {
      req.flash(
        'messageUserFail',
        'La fecha de caducidad debe ser mayor a la fecha actual'
      );
    } else {
      await db.query(
        'UPDATE tarjetas_usuarios SET tipo_tar = $1, numero_tar = $2, fcaducidad_tar = $3 WHERE id_tar = $4',
        newCard
      );
      req.flash('messageUser', 'Se actualizó correctamente la tarjeta');
    }
  } catch (e) {
    console.log(e);
    req.flash('messageUserFail', 'Ocurrió un error al actualizar la tarjeta');
  }
};

const deleteCard = async (req, id) => {
  try {
    await db.query('DELETE FROM tarjetas_usuarios WHERE id_tar = $1', [id]);
    req.flash('messageUser', 'Se eliminó correctamente la tarjeta');
  } catch (e) {
    console.log(e);
    req.flash('messageUserFail', 'Ocurrió un error al eliminar la tarjeta');
  }
};

exports.getUserCard = getUserCard;
exports.insertCard = insertCard;
exports.updateCard = updateCard;
exports.deleteCard = deleteCard;
