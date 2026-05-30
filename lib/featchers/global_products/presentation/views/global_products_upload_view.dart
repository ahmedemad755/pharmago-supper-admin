import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supper_admin/featchers/global_products/data/global_product_service.dart';

class GlobalProductsUploadView extends StatefulWidget {
  const GlobalProductsUploadView({super.key});

  @override
  State<GlobalProductsUploadView> createState() =>
      _GlobalProductsUploadViewState();
}

class _GlobalProductsUploadViewState extends State<GlobalProductsUploadView> {
  final GlobalProductService _service = GlobalProductService();
  GlobalProductUploadResult? _lastResult;
  bool _isUploading = false;

  Future<void> _pickAndUploadExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx'],
      withData: true,
    );

    final file = result?.files.single;
    if (file == null) return;

    setState(() => _isUploading = true);

    try {
      final uploadResult = await _service.uploadGlobalProductsExcel(file);
      if (!mounted) return;

      setState(() => _lastResult = uploadResult);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Uploaded ${uploadResult.uploadedRows} of ${uploadResult.totalRows} products.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Global Product Library')),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList.list(
              children: [
                Text(
                  'Super Admin Bulk Upload',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload an .xlsx file with columns: barcode, name, category, description, image_url, is_prescription_required.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: _isUploading ? null : _pickAndUploadExcel,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_file),
                    label: Text(_isUploading ? 'Uploading...' : 'Upload Excel'),
                  ),
                ),
                const SizedBox(height: 24),
                if (_lastResult != null) _UploadSummary(result: _lastResult!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadSummary extends StatelessWidget {
  final GlobalProductUploadResult result;

  const _UploadSummary({required this.result});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last upload',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text('Rows found: ${result.totalRows}'),
            Text('Rows uploaded: ${result.uploadedRows}'),
            if (result.errors.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Skipped rows',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              ...result.errors.take(20).map(
                    (error) => Text(
                      error,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
