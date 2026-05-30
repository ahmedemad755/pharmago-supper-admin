import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supper_admin/featchers/global_products/data/global_product.dart';
import 'package:supper_admin/featchers/global_products/data/global_product_service.dart';
import 'package:supper_admin/featchers/global_products/presentation/widgets/pharmacy_product_review_table.dart';

class PharmacyProductReviewView extends StatefulWidget {
  final String pharmacyId;

  const PharmacyProductReviewView({
    super.key,
    required this.pharmacyId,
  });

  @override
  State<PharmacyProductReviewView> createState() =>
      _PharmacyProductReviewViewState();
}

class _PharmacyProductReviewViewState extends State<PharmacyProductReviewView> {
  final GlobalProductService _service = GlobalProductService();
  final TextEditingController _barcodeController = TextEditingController();
  final List<PharmacyProductDraft> _drafts = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _pickExcelAndMatch() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx'],
      withData: true,
    );

    final file = result?.files.single;
    if (file == null) return;

    setState(() => _isLoading = true);

    try {
      final matchedDrafts = await _service.matchExcelRows(file);
      if (!mounted) return;
      setState(() {
        _drafts
          ..clear()
          ..addAll(matchedDrafts);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Matching failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addBarcodeManually() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) return;

    final draft = PharmacyProductDraft(barcode: barcode);
    setState(() {
      _isLoading = true;
      _drafts.add(draft);
    });

    try {
      await _service.applyBarcodeToDraft(draft);
      if (!mounted) return;
      setState(() {});
    } finally {
      if (mounted) {
        _barcodeController.clear();
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submit() async {
    final hasInvalidRows = _drafts.any((draft) => !draft.isReadyForSubmit);
    if (_drafts.isEmpty || hasInvalidRows) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete matched data, price, and quantity first.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _service.batchWritePharmacyInventory(
        pharmacyId: widget.pharmacyId,
        drafts: _drafts,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Products saved successfully.')),
      );
      setState(_drafts.clear);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Product Review'),
            actions: [
              TextButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload),
                label: const Text('Submit'),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.list(
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _pickExcelAndMatch,
                      icon: const Icon(Icons.table_chart),
                      label: const Text('Upload Pharmacy Excel'),
                    ),
                    SizedBox(
                      width: 280,
                      child: TextField(
                        controller: _barcodeController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        onSubmitted: (_) => _addBarcodeManually(),
                        decoration: InputDecoration(
                          labelText: 'Scan or type barcode',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: 'Search global library',
                            onPressed: _isLoading ? null : _addBarcodeManually,
                            icon: const Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                    if (_isLoading)
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                PharmacyProductReviewTable(
                  drafts: _drafts,
                  onChanged: () => setState(() {}),
                  onRemove: (draft) => setState(() => _drafts.remove(draft)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
