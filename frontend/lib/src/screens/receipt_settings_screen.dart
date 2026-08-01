import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';

import '../providers/receipt_settings_provider.dart';
import '../services/local_database.dart';
import '../services/pdf_service.dart';

class ReceiptSettingsScreen extends StatefulWidget {
  const ReceiptSettingsScreen({super.key});

  @override
  State<ReceiptSettingsScreen> createState() => _ReceiptSettingsScreenState();
}

class _ReceiptSettingsScreenState extends State<ReceiptSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _temp = {};
  final TextEditingController _smsController = TextEditingController();
  final TextEditingController _businessController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _receiptTitleController = TextEditingController();
  final TextEditingController _footerController = TextEditingController();
  final TextEditingController _logoPathController = TextEditingController();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // load defaults if missing
      _loadIntoTemp();
      // init controllers
      _businessController.text = _temp['business_name'] ?? '';
      _phoneController.text = _temp['phone'] ?? '';
      _addressController.text = _temp['address'] ?? '';
      _gstController.text = _temp['gst'] ?? '';
      _websiteController.text = _temp['website'] ?? '';
      _receiptTitleController.text = _temp['receipt_title'] ?? '** Invoice **';
      _footerController.text = _temp['footer_text'] ?? 'Thank You, Visit Again.';
      _logoPathController.text = _temp['logo_path'] ?? '';
      _smsController.text = _temp['sms_template'] ?? 'Total Bill Amount is #total';
    });
  }

  void _loadIntoTemp() {
    final p = Provider.of<ReceiptSettingsProvider>(context, listen: false);
    // basic text fields
    _temp['business_name'] = p.getString('business_name', def: '');
    _temp['phone'] = p.getString('phone', def: '');
    _temp['address'] = p.getString('address', def: '');
    _temp['gst'] = p.getString('gst', def: '');
    _temp['website'] = p.getString('website', def: '');
    _temp['receipt_title'] = p.getString('receipt_title', def: '** Invoice **');
    _temp['footer_text'] = p.getString('footer_text', def: 'Thank You, Visit Again.');
    _temp['logo_path'] = p.getString('logo_path', def: '');
    _temp['sms_template'] = p.getString('sms_template', def: 'Total Bill Amount is #total');
    _temp['whatsapp_share_app'] = p.getString('whatsapp_share_app', def: 'whatsapp');
    // switches saved as 'true'/'false'

    // ensure switches are available in provider defaults
    for (final key in ['show_list_price','show_rate_in_receipt','show_total_saved','show_cashier_name','show_customer_phone','show_customer_address','use_app_language_for_share','show_total_item_count','show_change_return','show_payment_details']) {
      if (!p.settings.containsKey(key)) {
        p.setBool(key, false);
      }
    }
  }

  Widget _buildTextField(String key, String label, {int maxLines = 1}) {
    final controller = (key == 'sms_template') ? _smsController :
      (key == 'business_name') ? _businessController :
      (key == 'phone') ? _phoneController :
      (key == 'address') ? _addressController :
      (key == 'gst') ? _gstController :
      (key == 'website') ? _websiteController :
      (key == 'receipt_title') ? _receiptTitleController :
      (key == 'footer_text') ? _footerController :
      (key == 'logo_path') ? _logoPathController : null;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      onChanged: (v) => _temp[key] = v,
    );
  }

  Widget _buildSwitch(String key, String label, {String? help}) {
    final current = Provider.of<ReceiptSettingsProvider>(context).getBool(key, def: false);
    return SwitchListTile(
      title: Text(label),
      subtitle: help != null ? Text(help) : null,
      value: current,
      onChanged: (v) async {
        await Provider.of<ReceiptSettingsProvider>(context, listen: false).setBool(key, v);
        setState(() {});
      },
    );
  }

  void _showTokensDialog() {
    showDialog<void>(
      context: context,
      builder: (dctx) {
        final tokens = ['#invoice', '#total', '#date', '#time', '#customer', '#items'];
        return AlertDialog(
          title: const Text('Insert Template Token'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tokens.length,
              itemBuilder: (context, index) {
                final t = tokens[index];
                return ListTile(
                  title: Text(t),
                  onTap: () {
                    final txt = _smsController.text;
                    final sel = _smsController.selection;
                    final newText = txt.replaceRange(sel.start, sel.end, t);
                    _smsController.text = newText;
                    _smsController.selection = TextSelection.collapsed(offset: (sel.start + t.length));
                    Navigator.of(dctx).pop();
                  },
                );
              },
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.of(dctx).pop(), child: const Text('Close'))],
        );
      },
    );
  }

  Future<void> _previewReceipt() async {
    final provider = Provider.of<ReceiptSettingsProvider>(context, listen: false);
    final current = provider.settings;
    // overlay controllers values
    current['business_name'] = _businessController.text.trim();
    current['phone'] = _phoneController.text.trim();
    current['address'] = _addressController.text.trim();
    current['gst'] = _gstController.text.trim();
    current['footer_text'] = _footerController.text.trim();
    final pdfBytes = await PdfService.generateReceiptPreview(current);
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }

  Future<void> _saveAll() async {
    final changed = <String, String>{};
    // text vals
    for (final k in ['business_name','phone','address','gst','website','receipt_title','footer_text','logo_path','sms_template','whatsapp_share_app']) {
      // take values from controllers to ensure latest
      switch (k) {
        case 'business_name': changed[k] = _businessController.text.trim(); break;
        case 'phone': changed[k] = _phoneController.text.trim(); break;
        case 'address': changed[k] = _addressController.text.trim(); break;
        case 'gst': changed[k] = _gstController.text.trim(); break;
        case 'website': changed[k] = _websiteController.text.trim(); break;
        case 'receipt_title': changed[k] = _receiptTitleController.text.trim(); break;
        case 'footer_text': changed[k] = _footerController.text.trim(); break;
        case 'logo_path': changed[k] = _logoPathController.text.trim(); break;
        case 'sms_template': changed[k] = _smsController.text.trim(); break;
        default: changed[k] = _temp[k] ?? ''; break;
      }
    }

    await Provider.of<ReceiptSettingsProvider>(context, listen: false).saveBulk(changed);

    // also persist current switches to settings provider
    final p = Provider.of<ReceiptSettingsProvider>(context, listen: false);
    for (final key in ['show_list_price','show_rate_in_receipt','show_total_saved','show_cashier_name','show_customer_phone','show_customer_address','use_app_language_for_share','show_total_item_count','show_change_return','show_payment_details']) {
      await p.setBool(key, p.getBool(key, def: false));
    }

    // enqueue sync so backend can be updated
    await LocalDatabaseService.instance.enqueueSync({'type': 'receipt_settings', 'payload': changed}, 'receipt_settings');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt settings saved')));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReceiptSettingsProvider>(context);
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Settings'),
        actions: [
          TextButton(onPressed: _saveAll, child: const Text('Save', style: TextStyle(color: Colors.white)))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('business_name', 'Business Name'),
              const SizedBox(height: 12),
              _buildTextField('phone', 'Phone'),
              Row(
                children: [
                  Expanded(child: _buildTextField('address', 'Address', maxLines: 2)),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      // logo preview
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                        child: _logoPathController.text.isEmpty
                    ? const Center(child: Text('No logo'))
                    : Image.file(
                        File(_logoPathController.text),
                        fit: BoxFit.contain,
                        errorBuilder: (context, err, st) => const Center(child: Text('Invalid image')),
                      ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                  // open image picker
                  try {
                    final result = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (result != null) {
                          if (!mounted) return;
                          setState(() {
                            _temp['logo_path'] = result.path;
                            _logoPathController.text = result.path;
                          });
                        }
                      } catch (e) {
                        // fallback to manual path dialog
                        if (!mounted) return;
                        final v = await showDialog<String>(
                          context: context,
                          builder: (dctx) {
                            final tc = TextEditingController(text: _temp['logo_path'] ?? '');
                            return AlertDialog(
                              title: const Text('Logo Path / URL'),
                              content: TextField(controller: tc, decoration: const InputDecoration(labelText: 'Path or URL')),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(dctx).pop(null), child: const Text('Cancel')),
                                ElevatedButton(onPressed: () => Navigator.of(dctx).pop(tc.text.trim()), child: const Text('Save')),
                              ],
                            );
                          },
                        );
                        if (v != null) {
                          if (!mounted) return;
                          setState(() { _temp['logo_path'] = v; _logoPathController.text = v; });
                        }
                      }
                            },
                            child: const Text('Choose Logo (Gallery)'),
                          ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        onPressed: () {
                  setState(() { _temp['logo_path'] = ''; _logoPathController.text = ''; });
                        },
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField('gst', 'Tax no. and Title (GSTIN)', maxLines: 1),
              const SizedBox(height: 12),
              _buildTextField('website', 'Website'),
              const SizedBox(height: 12),
              _buildTextField('receipt_title', 'Receipt title (optional)'),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Receipt Options', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildSwitch('show_list_price', 'Show list price (MRP/MSRP/Sticker price) in receipt'),
                      _buildSwitch('show_rate_in_receipt', 'Show rate in receipt'),
                      _buildSwitch('show_total_saved', 'Show total money saved by the customer'),
                      _buildSwitch('show_cashier_name', 'Show Cashier name on receipt?'),
                      _buildSwitch('show_customer_phone', 'Show customer phone number on receipt'),
                      _buildSwitch('show_customer_address', 'Show customer address on receipt'),
                      const SizedBox(height: 8),
                      _buildTextField('footer_text', 'Thank You Note / Footer', maxLines: 2),
                      const SizedBox(height: 8),
                      _buildSwitch('use_app_language_for_share', 'Use app language to share/print receipts'),
                      _buildSwitch('show_total_item_count', 'Show Total Item count on receipt'),
                      _buildSwitch('show_change_return', 'Show change return amount on receipt'),
                      _buildSwitch('show_payment_details', 'Show payment details on receipt'),
                      const SizedBox(height: 12),
                      const Text('Order items by'),
                      Row(
                        children: [
                      Radio<String>(
                        value: 'name',
                        groupValue: Provider.of<ReceiptSettingsProvider>(context).getString('order_items_by', def: 'name'),
                        onChanged: (v) async {
                          if (v == null) return;
                          final p = Provider.of<ReceiptSettingsProvider>(context, listen: false);
                          await p.setString('order_items_by', v);
                          if (!mounted) return;
                          setState(() {});
                        },
                      ),
                      const Text('Name'),
                      const SizedBox(width: 12),
                      Radio<String>(
                        value: 'ordered',
                        groupValue: Provider.of<ReceiptSettingsProvider>(context).getString('order_items_by', def: 'name'),
                        onChanged: (v) async {
                          if (v == null) return;
                          final p = Provider.of<ReceiptSettingsProvider>(context, listen: false);
                          await p.setString('order_items_by', v);
                          if (!mounted) return;
                          setState(() {});
                        },
                      ),
                      const Text('Ordered added'),
                            ],
                          ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                  Expanded(child: _buildTextField('sms_template', 'SMS / WhatsApp / Email Template', maxLines: 3)),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      ElevatedButton(onPressed: _showTokensDialog, child: const Text('Tokens')),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _previewReceipt, child: const Text('Preview')),
                    ],
                  )
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Select WhatsApp Share App'),
                      Row(
                        children: [
                  Radio<String>(value: 'whatsapp', groupValue: Provider.of<ReceiptSettingsProvider>(context).getString('whatsapp_share_app', def: 'whatsapp'), onChanged: (v) async { if (v!=null) await Provider.of<ReceiptSettingsProvider>(context, listen:false).setString('whatsapp_share_app', v); setState((){}); }),
                  const Text('WhatsApp'),
                  const SizedBox(width: 12),
                  Radio<String>(value: 'whatsapp_business', groupValue: Provider.of<ReceiptSettingsProvider>(context).getString('whatsapp_share_app', def: 'whatsapp'), onChanged: (v) async { if (v!=null) await Provider.of<ReceiptSettingsProvider>(context, listen:false).setString('whatsapp_share_app', v); setState((){}); }),
                  const Text('WhatsApp Business'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
