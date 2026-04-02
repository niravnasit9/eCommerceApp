import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/brand_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';

class AddBrandForm extends StatefulWidget {
  const AddBrandForm({super.key, this.brand});

  final BrandModel? brand;

  @override
  State<AddBrandForm> createState() => _AddBrandFormState();
}

class _AddBrandFormState extends State<AddBrandForm> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final productsCountController = TextEditingController();
  var isFeatured = false.obs;

  @override
  void initState() {
    super.initState();
    if (widget.brand != null) {
      nameController.text = widget.brand!.name;
      productsCountController.text = widget.brand!.productsCount.toString();
      isFeatured.value = widget.brand!.isFeatured!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.brand == null ? 'Add Brand' : 'Edit Brand'),
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
              /// Brand Name
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Brand Name',
                  prefixIcon: Icon(Iconsax.tag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter brand name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Products Count
              TextFormField(
                controller: productsCountController,
                decoration: const InputDecoration(
                  labelText: 'Number of Products',
                  prefixIcon: Icon(Iconsax.box),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Featured Checkbox
              Obx(
                () => CheckboxListTile(
                  title: const Text('Featured Brand'),
                  subtitle: const Text('Show this brand in featured section'),
                  value: isFeatured.value,
                  onChanged: (value) {
                    isFeatured.value = value ?? false;
                  },
                  activeColor: TColors.primary,
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              /// Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveBrand,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                  ),
                  child: Text(
                    widget.brand == null ? 'Add Brand' : 'Update Brand',
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

  void _saveBrand() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement brand save logic
      Get.back();
      Get.snackbar(
        'Success',
        widget.brand == null ? 'Brand added successfully' : 'Brand updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.success,
        colorText: TColors.white,
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    productsCountController.dispose();
    super.dispose();
  }
}