const { Pool } = require('pg');

const config = {
    user: 'postgres',
    host: 'localhost',
    password: '2002',
    database: 'musica_test',
    port: '5432'
}
const db = new Pool(config);

db.connect((err, connection) => {
    if (err) {
        if (err.code === 'PROTOCOL_CONNECTION_LOST') {
            console.error('CONEXION CON LA BASE DE DATOS CERRADA');
        } else if (err.code === 'ERR_CON_COUNT_ERROR') {
            console.log('CONEXION SATURADA EN LA BASE DE DATOS');
        } else if (err.code === 'ECONNREFUSED') {
            console.log('CONEXION RECHAZADA');
        }
        return;
    }
    if (connection) connection.release();
    console.log('Base de datos conectada');

    return;
});

exports.db = db;