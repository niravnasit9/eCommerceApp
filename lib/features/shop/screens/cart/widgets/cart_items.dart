import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/products/cart/add_remove_button.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/products/cart/cart_item.dart';
import 'package:yt_ecommerce_admin_panel/common/widgets/texts/product_price_text.dart';
import 'package:yt_ecommerce_admin_panel/features/shop/controller/product/cart_controller.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:yt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:yt_ecommerce_admin_panel/utils/helpers/helper_functions.dart';

class TCartItems extends StatelessWidget {
  const TCartItems({
    super.key,
    this.showAddRemoveButtons = true,
  });

  final bool showAddRemoveButtons;

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    final dark = THelperFunctions.isDarkMode(context);
    
    return Obx(
      () => cartController.cartItems.isEmpty
          ? _buildEmptyCart(context, dark)
          : ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: cartController.cartItems.length,
              separatorBuilder: (_, __) => const SizedBox(
                height: TSizes.spaceBtwItems,
              ),
              itemBuilder: (_, index) => Obx(() {
                final item = cartController.cartItems[index];
                return Container(
                  padding: const EdgeInsets.all(TSizes.sm),
                  margin: const EdgeInsets.symmetric(horizontal: TSizes.sm),
                  decoration: BoxDecoration(
                    color: dark ? TColors.dark : TColors.white,
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                    border: Border.all(
                      color: dark ? TColors.borderSecondary : TColors.borderPrimary,
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Cart Items
                      TCartItem(cartItem: item),
                      
                      if (showAddRemoveButtons) ...[
                        const SizedBox(height: TSizes.spaceBtwItems),
                        
                        /// Divider
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: dark ? TColors.borderSecondary : TColors.borderPrimary,
                        ),
                        
                        const SizedBox(height: TSizes.spaceBtwItems),
                        
                        /// Quantity and Price Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// Add Remove Button
                            Container(
                              decoration: BoxDecoration(
                                color: dark ? TColors.darkContainer : TColors.softGrey,
                                borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                              ),
                              child: TProductQuantityWithAddRemove(
                                quantity: item.quantity,
                                add: () => cartController.addOneToCart(item),
                                remove: () => cartController.removeOneFromCart(item),
                              ),
                            ),

                            /// Product Total Price
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: TSizes.sm,
                                vertical: TSizes.xs,
                              ),
                              decoration: BoxDecoration(
                                color: TColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                              ),
                              child: TProductPriceText(
                                price: (item.price * item.quantity).toStringAsFixed(0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ),
    );
  }
  
  /// Empty Cart Widget
  Widget _buildEmptyCart(BuildContext context, bool dark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Empty Cart Illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: dark ? TColors.darkContainer : TColors.softGrey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: dark ? TColors.textWhite : TColors.textSecondary,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            
            /// Title
            Text(
              'Your Cart is Empty',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: dark ? TColors.textWhite : TColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            
            /// Subtitle
            Text(
              'Looks like you haven\'t added any items yet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: dark ? TColors.textWhite : TColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            
            /// Shop Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to products screen
                  // Get.to(() => const AllProductsScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: TColors.textWhite,
                  padding: const EdgeInsets.symmetric(
                    vertical: TSizes.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
                  ),
                ),
                child: const Text('Start Shopping'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}