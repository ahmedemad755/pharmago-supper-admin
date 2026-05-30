import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supper_admin/featchers/global_products/data/global_product.dart';

class PharmacyProductReviewTable extends StatelessWidget {
  final List<PharmacyProductDraft> drafts;
  final VoidCallback onChanged;
  final ValueChanged<PharmacyProductDraft> onRemove;

  const PharmacyProductReviewTable({
    super.key,
    required this.drafts,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (drafts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Text('No products selected yet.'),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(Colors.teal.shade50),
        columns: const [
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Barcode')),
          DataColumn(label: Text('Image')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Price')),
          DataColumn(label: Text('Quantity')),
          DataColumn(label: Text('Rx')),
          DataColumn(label: Text('')),
        ],
        rows: drafts.map((draft) {
          final rowColor = !draft.isMatched
              ? WidgetStatePropertyAll(Colors.red.shade50)
              : null;

          return DataRow(
            color: rowColor,
            cells: [
              DataCell(
                Icon(
                  draft.isMatched ? Icons.check_circle : Icons.error,
                  color: draft.isMatched ? Colors.green : Colors.red,
                ),
              ),
              DataCell(Text(draft.barcode)),
              DataCell(_ProductImage(url: draft.imageUrl)),
              DataCell(
                _SmallTextField(
                  initialValue: draft.name,
                  readOnly: draft.isMatched,
                  width: 180,
                  onChanged: (value) {
                    draft.name = value;
                    onChanged();
                  },
                ),
              ),
              DataCell(
                _SmallTextField(
                  initialValue: draft.category,
                  readOnly: draft.isMatched,
                  width: 150,
                  onChanged: (value) {
                    draft.category = value;
                    onChanged();
                  },
                ),
              ),
              DataCell(
                _SmallTextField(
                  initialValue: draft.price?.toString() ?? '',
                  width: 110,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: (value) {
                    draft.price = double.tryParse(value);
                    onChanged();
                  },
                ),
              ),
              DataCell(
                _SmallTextField(
                  initialValue: draft.unitAmount?.toString() ?? '',
                  width: 95,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    draft.unitAmount = int.tryParse(value);
                    onChanged();
                  },
                ),
              ),
              DataCell(
                Checkbox(
                  value: draft.isPrescriptionRequired,
                  onChanged: draft.isMatched
                      ? null
                      : (value) {
                          draft.isPrescriptionRequired = value ?? false;
                          onChanged();
                        },
                ),
              ),
              DataCell(
                IconButton(
                  tooltip: 'Remove',
                  onPressed: () => onRemove(draft),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String url;

  const _ProductImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: Icon(Icons.image_not_supported_outlined),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.broken_image_outlined),
          );
        },
      ),
    );
  }
}

class _SmallTextField extends StatefulWidget {
  final String initialValue;
  final bool readOnly;
  final double width;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String> onChanged;

  const _SmallTextField({
    required this.initialValue,
    required this.width,
    required this.onChanged,
    this.readOnly = false,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  State<_SmallTextField> createState() => _SmallTextFieldState();
}

class _SmallTextFieldState extends State<_SmallTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _SmallTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: TextField(
        controller: _controller,
        readOnly: widget.readOnly,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
      ),
    );
  }
}
