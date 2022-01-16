const { format } = require('timeago.js');
// const dateFormat = require('handlebars-dateformat');

const helpers = {};

helpers.timeago = (timestamp) => {

    return format(timestamp);
}
helpers.dateFormat = (date) => {
    dia = date.getDate()
    mes = parseInt(date.getMonth()) + 1
    anio = date.getFullYear()
    return `${(dia < 10 ? '0' + dia : dia)}/${(mes < 10 ? '0' + mes : mes)}/${anio}`;
}
module.exports = helpers;