import 'package:flutter/material.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/product_variation_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';

class VariationSelector extends StatefulWidget {
  const VariationSelector({required this.variations});
  final List<ProductVariationModel> variations;

  @override
  State<VariationSelector> createState() => VariationSelectorState();
}

class VariationSelectorState extends State<VariationSelector> {
  final Map<String, String> _selected = {};
  ProductVariationModel? _matched;

  /// All unique attribute keys across all variations e.g. ["Size", "Color"]
  List<String> get _allKeys {
    final keys = <String>{};
    for (var v in widget.variations) {
      keys.addAll(v.attributeValues.keys);
    }
    return keys.toList();
  }

  /// All unique values for a given key e.g. ["S", "M", "L"] for "Size"
  List<String> _valuesFor(String key) {
    final values = <String>{};
    for (var v in widget.variations) {
      if (v.attributeValues.containsKey(key)) {
        values.add(v.attributeValues[key]!);
      }
    }
    return values.toList();
  }

  /// Check if this value has at least one variation in stock
  bool _isAvailable(String key, String value) {
    return widget.variations
        .any((v) => v.attributeValues[key] == value && v.stock > 0);
  }

  /// Find variation that matches all selected attributes
  void _updateMatch() {
    _matched = widget.variations.cast<ProductVariationModel?>().firstWhere(
          (v) => _selected.entries
              .every((e) => v!.attributeValues[e.key] == e.value),
          orElse: () => null,
        );
  }

  @override
  void initState() {
    super.initState();
    // Auto-select first value for each key
    for (var key in _allKeys) {
      final firstVal = widget.variations
          .firstWhere((v) => v.attributeValues.containsKey(key))
          .attributeValues[key];
      if (firstVal != null) _selected[key] = firstVal;
    }
    _updateMatch();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Attribute chip rows ──
        ..._allKeys.map((key) {
          final values = _valuesFor(key);
          return Padding(
            padding: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label: "Size: M"
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '$key: ',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      TextSpan(
                        text: _selected[key] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TSizes.xs),
                // Chips
                Wrap(
                  spacing: TSizes.sm,
                  runSpacing: TSizes.xs,
                  children: values.map((value) {
                    final isSelected = _selected[key] == value;
                    final isAvailable = _isAvailable(key, value);

                    return GestureDetector(
                      onTap: isAvailable
                          ? () => setState(() {
                                _selected[key] = value;
                                _updateMatch();
                              })
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : isAvailable
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : isAvailable
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                    : Colors.grey.shade400,
                            decoration: isAvailable
                                ? TextDecoration.none
                                : TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: TSizes.xs),

        // ── Matched variation summary card ──
        if (_matched != null)
          Container(
            padding: const EdgeInsets.all(TSizes.md),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(TSizes.md),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(TSizes.sm),
                  child: _matched!.image.isNotEmpty
                      ? Image.network(
                          _matched!.image,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imageFallback(),
                        )
                      : _imageFallback(),
                ),
                const SizedBox(width: TSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price
                      Row(
                        children: [
                          Text(
                            "₹${(_matched!.salePrice > 0 ? _matched!.salePrice : _matched!.price).toStringAsFixed(0)}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          if (_matched!.salePrice > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              "₹${_matched!.price.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Discount badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${(((_matched!.price - _matched!.salePrice) / _matched!.price) * 100).toStringAsFixed(0)}% off',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Stock
                      Row(
                        children: [
                          Icon(
                            _matched!.stock > 0
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            size: 14,
                            color: _matched!.stock > 0
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _matched!.stock > 0
                                ? 'In Stock (${_matched!.stock} units)'
                                : 'Out of Stock',
                            style: TextStyle(
                              fontSize: 12,
                              color: _matched!.stock > 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      // SKU
                      if (_matched!.sku.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'SKU: ${_matched!.sku}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

        // ── No combination available ──
        if (_matched == null)
          Container(
            padding: const EdgeInsets.all(TSizes.md),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(TSizes.md),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: Colors.orange[700], size: 18),
                const SizedBox(width: TSizes.sm),
                const Expanded(
                  child: Text(
                    'This combination is not available',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _imageFallback() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(TSizes.sm),
      ),
      child: const Icon(Icons.image_outlined, size: 28, color: Colors.grey),
    );
  }
}