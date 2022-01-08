const { format } = require('timeago.js');
// const dateFormat = require('handlebars-dateformat');

const helpers = {};

helpers.timeago = (timestamp) => {

    return format(timestamp);
}
// helpers.registerHelper('dateFormat', require('handlebars-dateformat'))

module.exports = helpers;