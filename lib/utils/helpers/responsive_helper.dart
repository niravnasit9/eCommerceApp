// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ResponsiveHelper {
//   // Screen breakpoints
//   static const double mobileBreakpoint = 600;
//   static const double tabletBreakpoint = 900;
//   static const double desktopBreakpoint = 1200;
//   static const double largeDesktopBreakpoint = 1600;

//   // Get screen width
//   static double get screenWidth => Get.width;

//   // Get screen height
//   static double get screenHeight => Get.height;

//   // Check if screen is mobile
//   static bool get isMobile => screenWidth < mobileBreakpoint;

//   // Check if screen is tablet
//   static bool get isTablet =>
//       screenWidth >= mobileBreakpoint && screenWidth < desktopBreakpoint;

//   // Check if screen is desktop
//   static bool get isDesktop => screenWidth >= desktopBreakpoint;

//   // Check if screen is large desktop
//   static bool get isLargeDesktop => screenWidth >= largeDesktopBreakpoint;

//   // Get responsive padding
//   static EdgeInsets get responsivePadding {
//     if (isMobile) {
//       return const EdgeInsets.all(12);
//     } else if (isTablet) {
//       return const EdgeInsets.all(20);
//     } else {
//       return const EdgeInsets.all(24);
//     }
//   }

//   // Get responsive grid cross axis count for products
//   static int getProductGridCrossAxisCount() {
//     if (isMobile) return 1;
//     if (isTablet) return 2;
//     return 3;
//   }

//   // Get responsive grid cross axis count for brands
//   static int getBrandGridCrossAxisCount() {
//     if (isMobile) return 2;
//     if (isTablet) return 3;
//     return 4;
//   }

//   // Get responsive grid cross axis count for banners
//   static int getBannerGridCrossAxisCount() {
//     if (isMobile) return 1;
//     if (isTablet) return 2;
//     return 3;
//   }

//   // Get responsive font size
//   static double getFontSize(double size) {
//     if (isMobile) return size;
//     if (isTablet) return size * 1.2;
//     return size * 1.4;
//   }

//   // Get responsive card width
//   static double getCardWidth(BuildContext context) {
//     if (isMobile) return screenWidth - 24;
//     if (isTablet) return (screenWidth - 48) / 2;
//     return (screenWidth - 72) / 3;
//   }

//   // Get responsive stats grid cross axis count
//   static int getStatsGridCrossAxisCount() {
//     if (isMobile) return 2;
//     return 4;
//   }

//   // Get responsive stats card aspect ratio
//   static double getStatsCardAspectRatio() {
//     if (isMobile) return 1.1;
//     return 1.2;
//   }
// }
