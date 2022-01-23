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

helpers.coinFormat = (coin) => {
    return `$ ${coin.toFixed(2)}`;
}

helpers.firstPlan = (idPlan) => {
    return idPlan === 'pl-1';
}

module.exports = helpers;