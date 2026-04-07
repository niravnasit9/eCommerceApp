import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/appbar/appbar.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/images/t_circular_image.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/texts/section_heading.dart';
import 'package:yt_ecommerce_admin_panel/data/repositories/authentication/authentication_repository.dart';
import 'package:yt_ecommerce_admin_panel/features/personalization/controllers/user_controller.dart';
import 'package:yt_ecommerce_admin_panel/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/image_strings.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    final authRepo = AuthenticationRepository.instance;

    return Scaffold(
      appBar: const TAppBar(
        title: Text('Profile'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Profile Picture
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Obx(() {
                      final networkImage = controller.user.value.profilePicture;
                      final image =
                          networkImage.isNotEmpty ? networkImage : TImages.user;
                      return TCircularImage(
                        image: image,
                        width: 80,
                        height: 80,
                        isNetworkImage: networkImage.isNotEmpty,
                      );
                    }),
                    TextButton(
                      onPressed: () => controller.uploadUserProfilePicture(),
                      child: const Text('Change Profile Picture'),
                    ),
                  ],
                ),
              ),

              /// Details
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Profile Information
              const TSectionHeading(
                title: 'Profile Information',
                showActionButton: false,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              TProfileMenu(
                title: 'Name',
                value: controller.user.value.fullName,
                onPressed: () {},

                // onPressed: () => controller.updateUserName(),
              ),
              TProfileMenu(
                title: 'Username',
                value: controller.user.value.username,
                onPressed: () {},

                // onPressed: () => controller.updateUserName(),
              ),

              const SizedBox(height: TSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Personal Information
              const TSectionHeading(
                title: 'Personal Information',
                showActionButton: false,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              TProfileMenu(
                title: 'User ID',
                value: controller.user.value.id,
                icon: Iconsax.copy,
                onPressed: () {},

                // onPressed: () => controller.copyUserId(),
              ),
              TProfileMenu(
                title: 'E-mail',
                value: controller.user.value.email,
                onPressed: () {},
              ),
              TProfileMenu(
                title: 'Phone Number',
                value: controller.user.value.phoneNumber.isEmpty
                    ? 'Add Phone Number'
                    : controller.user.value.phoneNumber,
                onPressed: () {},

                // onPressed: () => controller.updatePhoneNumber(),
              ),
              TProfileMenu(
                title: 'Gender',
                value: 'Male',
                onPressed: () {},
              ),
              TProfileMenu(
                title: 'Date of Birth',
                value: '22 May 1998',
                onPressed: () {},
              ),

              const SizedBox(height: TSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwSections),

              // /// ✅ My Orders Button
              // SizedBox(
              //   width: double.infinity,
              //   child: OutlinedButton.icon(
              //     onPressed: () {
              //       Get.to(() => const OrderScreen());
              //     },
              //     icon: const Icon(Iconsax.shopping_bag),
              //     label: const Text('My Orders'),
              //     style: OutlinedButton.styleFrom(
              //       padding: const EdgeInsets.symmetric(vertical: TSizes.md),
              //     ),
              //   ),
              // ),

              const SizedBox(height: TSizes.spaceBtwItems),

              /// ✅ Delete Account Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteAccountConfirmation(
                      context, controller, authRepo),
                  icon: const Icon(Iconsax.trash, color: Colors.red),
                  label: const Text(
                    'Delete Account',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: TSizes.md),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwItems),

              // /// Logout Button
              // SizedBox(
              //   width: double.infinity,
              //   child: OutlinedButton.icon(
              //     onPressed: () => _showLogoutConfirmation(context, authRepo),
              //     icon: const Icon(Iconsax.logout),
              //     label: const Text('Logout'),
              //     style: OutlinedButton.styleFrom(
              //       padding: const EdgeInsets.symmetric(vertical: TSizes.md),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context,
      UserController controller, AuthenticationRepository authRepo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently removed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Show loading
                Get.dialog(
                  const Center(child: CircularProgressIndicator()),
                  barrierDismissible: false,
                );
                try {
                  controller.deleteUserAccount();
                  await authRepo.logout();
                  Get.back(); // Close loading dialog
                  Get.snackbar(
                    'Success',
                    'Account deleted successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: TColors.success,
                    colorText: TColors.white,
                  );
                } catch (e) {
                  Get.back(); // Close loading dialog
                  Get.snackbar(
                    'Error',
                    'Failed to delete account: $e',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: TColors.error,
                    colorText: TColors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
