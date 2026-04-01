import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:yt_ecommerce_admin_panel/common/styles/spacing_styles.dart';
import 'package:yt_ecommerce_admin_panel/navigation_menu.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/text_strings.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
    this.onPressed,
    this.navigateTo = '/home', // Default navigation route
  });

  final String image, title, subTitle;
  final VoidCallback? onPressed;
  final String navigateTo; // 'home', 'orders', or custom route

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppBarHeight * 2,
          child: Column(
            children: [
              // Images
              Lottie.asset(
                image,
                width: MediaQuery.of(context).size.width * 0.6,
                repeat: false,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Title & SubTitle
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                subTitle,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (onPressed != null) {
                      onPressed!();
                    } else {
                      if (navigateTo == '/home') {
                        Get.offAll(() => const NavigationMenu());
                      } else if (navigateTo == '/orders') {
                        Get.offAllNamed('/orders'); // Use named route if available
                        // Or use: Get.offAll(() => const OrdersScreen());
                      } else {
                        Get.offAllNamed(navigateTo);
                      }
                    }
                  },
                  child: const Text(TTexts.tContinue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}