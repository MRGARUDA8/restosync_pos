const ExcelJS = require('exceljs');

const exportSalesReportExcel = async (salesData, res) => {
  const workbook = new ExcelJS.Workbook();
  const worksheet = workbook.addWorksheet('Sales Report');

  worksheet.columns = [
    { header: 'Bill Number', key: 'billNumber', width: 15 },
    { header: 'Order Number', key: 'orderNumber', width: 15 },
    { header: 'Table', key: 'tableNumber', width: 10 },
    { header: 'Payment Method', key: 'paymentMethod', width: 15 },
    { header: 'SubTotal (₹)', key: 'subTotal', width: 15 },
    { header: 'GST Tax (₹)', key: 'gstTax', width: 12 },
    { header: 'Discount (₹)', key: 'discount', width: 12 },
    { header: 'Grand Total (₹)', key: 'grandTotal', width: 18 },
    { header: 'Date', key: 'createdAt', width: 22 }
  ];

  salesData.forEach(bill => {
    worksheet.addRow({
      billNumber: bill.billNumber,
      orderNumber: bill.orderNumber,
      tableNumber: bill.tableNumber || 'Takeaway',
      paymentMethod: bill.paymentMethod,
      subTotal: bill.subTotal,
      gstTax: bill.gstTax,
      discount: bill.discount,
      grandTotal: bill.grandTotal,
      createdAt: new Date(bill.createdAt).toLocaleString()
    });
  });

  worksheet.getRow(1).font = { bold: true };

  res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  res.setHeader('Content-Disposition', 'attachment; filename=SalesReport.xlsx');

  await workbook.xlsx.write(res);
  res.end();
};

module.exports = { exportSalesReportExcel };
