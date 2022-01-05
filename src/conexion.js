const { Pool } = require('pg');

const config = {
    user: 'postgres',
    host: 'localhost',
    password: '2002',
    database: 'musica_test',
    port: '5432'
}
const db = new Pool(config);


exports.db = db;