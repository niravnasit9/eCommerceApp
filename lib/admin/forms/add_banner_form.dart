import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yt_ecommerce_admin_panel/admin/controllers/admin_banner_controller.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/models/banner_model.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';

class AddBannerForm extends StatefulWidget {
  const AddBannerForm({super.key, this.banner});

  final BannerModel? banner;

  @override
  State<AddBannerForm> createState() => _AddBannerFormState();
}

class _AddBannerFormState extends State<AddBannerForm> {
  final _formKey = GlobalKey<FormState>();
  final _imageUrlController = TextEditingController();
  final _targetScreenController = TextEditingController();
  final _titleController = TextEditingController();
  var isActive = true.obs;
  final controller = Get.find<AdminBannerController>();

  @override
  void initState() {
    super.initState();
    if (widget.banner != null) {
      _imageUrlController.text = widget.banner!.imageUrl;
      _targetScreenController.text = widget.banner!.targetScreen;
      _titleController.text = widget.banner!.title;
      isActive.value = widget.banner!.active;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.banner == null ? 'Add Banner' : 'Edit Banner'),
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
              /// Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Banner Title',
                  prefixIcon: Icon(Iconsax.text),
                  hintText: 'Enter banner title',
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Image URL
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  prefixIcon: Icon(Iconsax.image),
                  hintText: 'Enter Cloudinary image URL',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Target Screen
              TextFormField(
                controller: _targetScreenController,
                decoration: const InputDecoration(
                  labelText: 'Target Screen',
                  prefixIcon: Icon(Iconsax.link),
                  hintText: 'e.g., /home, /products, /cart',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter target screen';
                  }
                  return null;
                },
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Active Status
              Obx(
                () => CheckboxListTile(
                  title: const Text('Active Banner'),
                  subtitle: const Text('Show this banner on the home screen'),
                  value: isActive.value,
                  onChanged: (value) {
                    isActive.value = value ?? false;
                  },
                  activeColor: TColors.success,
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              /// Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveBanner,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                  ),
                  child: Text(
                    widget.banner == null ? 'Add Banner' : 'Update Banner',
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

  void _saveBanner() {
    if (_formKey.currentState!.validate()) {
      final banner = BannerModel(
        id: widget.banner?.id ?? '',
        imageUrl: _imageUrlController.text.trim(),
        targetScreen: _targetScreenController.text.trim(),
        title: _titleController.text.trim(),
        active: isActive.value,
      );

      if (widget.banner == null) {
        controller.addBanner(banner);
      } else {
        controller.updateBanner(banner);
      }
      
      Get.back();
    }
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _targetScreenController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}