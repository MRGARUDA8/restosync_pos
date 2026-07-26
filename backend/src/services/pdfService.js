const PDFDocument = require('pdfkit');

const generateBillPDF = (billData, res) => {
  const doc = new PDFDocument({ margin: 30, size: 'A6' }); // Thermal / receipt size

  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader('Content-Disposition', `attachment; filename=Bill-${billData.billNumber}.pdf`);

  doc.pipe(res);

  // Header
  doc.fontSize(16).text('RestoSync Cloud POS', { align: 'center', bold: true });
  doc.fontSize(10).text('Official Tax Invoice / Bill', { align: 'center' });
  doc.moveDown(0.5);

  doc.text(`Bill No: ${billData.billNumber}`);
  doc.text(`Order No: ${billData.orderNumber}`);
  doc.text(`Date: ${new Date(billData.createdAt || Date.now()).toLocaleString()}`);
  doc.text(`Table: ${billData.tableNumber || 'Takeaway'}`);
  doc.text(`Payment: ${billData.paymentMethod}`);
  doc.moveDown(0.5);

  // Line separator
  doc.text('--------------------------------------------------');

  // Items header
  doc.fontSize(10).text('Item                  Qty    Price    Total');
  doc.text('--------------------------------------------------');

  if (billData.items && billData.items.length > 0) {
    billData.items.forEach(item => {
      const lineTotal = item.price * item.quantity;
      doc.text(`${item.name.padEnd(20).substring(0, 18)} ${item.quantity.toString().padStart(3)}   ₹${item.price.toFixed(2)}  ₹${lineTotal.toFixed(2)}`);
    });
  }

  doc.text('--------------------------------------------------');
  doc.text(`Sub Total:                ₹${billData.subTotal.toFixed(2)}`, { align: 'right' });
  doc.text(`GST Tax:                  ₹${billData.gstTax.toFixed(2)}`, { align: 'right' });
  if (billData.discount > 0) {
    doc.text(`Discount:                -₹${billData.discount.toFixed(2)}`, { align: 'right' });
  }
  doc.fontSize(12).text(`Grand Total:             ₹${billData.grandTotal.toFixed(2)}`, { align: 'right', bold: true });
  doc.moveDown();

  doc.fontSize(9).text('Thank you for dining with us!', { align: 'center' });
  doc.text('Powered by RestoSync Cloud POS', { align: 'center' });

  doc.end();
};

module.exports = { generateBillPDF };
