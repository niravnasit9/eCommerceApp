import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/controller/product/product_controller.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/product_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';

class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key, this.product});

  final ProductModel? product;

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final productController = Get.put(ProductController());

  // Controllers
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final salePriceController = TextEditingController();
  final stockController = TextEditingController();
  final descriptionController = TextEditingController();
  final shortDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      // Populate form for editing
      titleController.text = widget.product!.title;
      priceController.text = widget.product!.price.toString();
      salePriceController.text = widget.product!.salePrice.toString();
      stockController.text = widget.product!.stock.toString();
      descriptionController.text = widget.product!.fullDescription;
      shortDescriptionController.text = widget.product!.shortDescription;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Iconsax.arrow_left),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Basic Information
              const Text(
                'Basic Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Product Title
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Product Title',
                  prefixIcon: Icon(Iconsax.tag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Price and Sale Price Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (₹)',
                        prefixIcon: Icon(Iconsax.money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  Expanded(
                    child: TextFormField(
                      controller: salePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Sale Price (₹)',
                        prefixIcon: Icon(Iconsax.discount_circle),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Stock
              TextFormField(
                controller: stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity',
                  prefixIcon: Icon(Iconsax.box),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Short Description
              TextFormField(
                controller: shortDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Short Description',
                  prefixIcon: Icon(Iconsax.text),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Full Description
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Full Description',
                  prefixIcon: Icon(Iconsax.document_text),
                ),
                maxLines: 5,
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              /// Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                  ),
                  child: Text(
                    widget.product == null ? 'Add Product' : 'Update Product',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement product save logic
      Get.back();
      Get.snackbar(
        'Success',
        widget.product == null ? 'Product added successfully' : 'Product updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.success,
        colorText: TColors.white,
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    salePriceController.dispose();
    stockController.dispose();
    descriptionController.dispose();
    shortDescriptionController.dispose();
    super.dispose();
  }
}