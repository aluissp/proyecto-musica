const path = require('path');
const PDF = require('pdfkit-construct');
const doc = require('pdfkit');

const construcPdf = (res, name) => {
  const doc = new PDF({
    bufferPages: true,
    font: 'Helvetica',
    size: 'A4',
    margins: { top: 20, left: 10, right: 10, bottom: 20 },
  });
  const stream = res.writeHead(200, {
    'Content-Type': 'application/pdf',
    'Content-disposition': `attachment;filename=Reporte_${name}.pdf`,
  });

  doc.on('data', (data) => {
    stream.write(data);
  });
  doc.on('end', () => {
    stream.end();
  });
  return doc;
};

const insertTable = (doc, table, header) => {
  const colum = [];
  for (let key in table[0]) {
    colum.push({ key });
  }

  for (let i = 0; i < colum.length; i++) {
    colum[i].label = header[i].column_name;
    colum[i].align = 'left';
  }

  doc.addTable(colum, table, {
    border: null,
    width: 'fill_body',
    striped: true,
    headBackground: '#b1bfca',
    stripedColors: ['#ffffff', '#e3f2fd'],
    cellsPadding: 10,
    marginLeft: 45,
    marginRight: 45,
    headAlign: 'left',
  });

  return doc;
};

const insertTableWhite = (doc, table, header) => {
  doc.addTable(header, table, {
    border: { size: 0.1, color: '#cdcdcd' },
    width: 'fill_body',
    striped: true,
    stripedColors: ['#ffffff', '#ffffff'],
    // stripedColors: ['#fff', '#f0ecd5'],
    headBackground: '#ffffff',
    cellsPadding: 5,
    cellsFontSize: 9,
    marginLeft: 45,
    marginRight: 45,
    headAlign: 'left',
    cellsAlign: 'left',
  });
  return doc;
};
const insertHeader = (doc, title) => {
  doc.setDocumentHeader({ height: '8%' }, () => {
    doc.moveUp();
    doc.fill('#115dc8').fontSize(20).text(title, 200, 30);
    const img = path.join(__dirname, '../public/img/epicentro-bar.jpg');
    doc.image(img, 460, 10, { width: 100 });
  });

  return doc;
};

exports.construcPdf = construcPdf;
exports.insertHeader = insertHeader;
exports.insertTable = insertTable;
exports.insertTableWhite = insertTableWhite;
