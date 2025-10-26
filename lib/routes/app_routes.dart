import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/views/activity/activity_view.dart';
import 'package:antill_estates/views/bottom_bar/bottom_bar_view.dart';
import 'package:antill_estates/views/drawer/agents_list/agents_details_view.dart';
import 'package:antill_estates/views/drawer/agents_list/agents_list_view.dart';
import 'package:antill_estates/views/drawer/contact_property/contact_property_view.dart';
import 'package:antill_estates/views/drawer/intresting_reads/interesting_reads_details_view.dart';
import 'package:antill_estates/views/drawer/intresting_reads/interesting_reads_view.dart';
import 'package:antill_estates/views/drawer/recent_activity/recent_activity_view.dart';
import 'package:antill_estates/views/drawer/responses/lead_details_view.dart';
import 'package:antill_estates/views/drawer/responses/responses_view.dart';
import 'package:antill_estates/views/drawer/terms_of_use/about_us_view.dart';
import 'package:antill_estates/views/drawer/terms_of_use/privacy_policy_view.dart';
import 'package:antill_estates/views/drawer/terms_of_use/terms_of_use_view.dart';
import 'package:antill_estates/views/drawer/viewed_property/viewed_property_view.dart';
// import 'package:antill_estates/views/home/delete_listing_view.dart';  // Disabled: Your Listing functionality
import 'package:antill_estates/views/home/home_view.dart';
import 'package:antill_estates/views/login/login_view.dart';
import 'package:antill_estates/views/notification/notification_view.dart';
import 'package:antill_estates/views/onboard/onboard_view.dart';
import 'package:antill_estates/views/otp/otp_view.dart';
import 'package:antill_estates/views/popular_builders/popular_builders_view.dart';
import 'package:antill_estates/views/post_property/add_amenities_view.dart';
import 'package:antill_estates/views/post_property/add_photo_and_pricing_view.dart';
import 'package:antill_estates/views/post_property/add_property_details_view.dart';
import 'package:antill_estates/views/post_property/edit_property_details_view.dart';
import 'package:antill_estates/views/post_property/edit_property_view.dart';
import 'package:antill_estates/views/post_property/post_property_view.dart';
import 'package:antill_estates/views/post_property/show_property_details_view.dart';
import 'package:antill_estates/views/profile/community_settings/community_settings_view.dart';
import 'package:antill_estates/views/profile/edit_profile_view.dart';
import 'package:antill_estates/views/profile/feedback/feedback_view.dart';
import 'package:antill_estates/views/profile/languages/languages_view.dart';
import 'package:antill_estates/views/property_list/about_property_view.dart';
import 'package:antill_estates/views/property_list/contact_owner_view.dart';
import 'package:antill_estates/views/property_list/furnishing_details_view.dart';
import 'package:antill_estates/views/property_list/gallery_view.dart';
import 'package:antill_estates/views/property_list/property_details_view.dart';
import 'package:antill_estates/views/property_list/property_list_view.dart';
import 'package:antill_estates/views/register/register_view.dart';
import 'package:antill_estates/views/reviews/add_reviews_for_broker_view.dart';
import 'package:antill_estates/views/reviews/add_reviews_for_property_view.dart';
import 'package:antill_estates/views/reviews/add_property_review_view.dart';
import 'package:antill_estates/views/saved/saved_properties_view.dart';
import 'package:antill_estates/views/search/search_view.dart';
import 'package:antill_estates/views/splash/splash_view.dart';
import 'package:antill_estates/views/debug/notification_debug_view.dart';
import 'package:antill_estates/views/arts_antiques/arts_antiques_view.dart';
import 'package:antill_estates/views/arts_antiques/arts_antiques_details_view.dart';
import 'package:antill_estates/views/arts_antiques/arts_antiques_search_view.dart';
import 'package:antill_estates/views/arts_antiques/arts_antiques_search_list_view.dart';
import 'package:antill_estates/views/arts_antiques/artist_details_view.dart';
import 'package:antill_estates/views/upcoming_projects/upcoming_projects_view.dart';
import 'package:antill_estates/views/upcoming_projects/upcoming_project_details_view.dart';
import 'package:antill_estates/views/demo/animation_demo_view.dart';
import 'package:antill_estates/routes/page_transitions.dart';
import 'package:antill_estates/configs/app_animations.dart';

class AppRoutes {
  static const String splashView = "/splash_view";
  static const String onboardView = "/onboard_view";
  static const String loginView = "/login_view";
  static const String otpView = "/otp_view";
  static const String registerView = "/register_view";
  static const String homeView = "/home_view";
  static const String bottomBarView = "/bottom_bar_view";
  static const String notificationView = "/notification_view";
  static const String searchView = "/search_view";
  static const String propertyListView = "/property_list_view";
  static const String propertyDetailsView = "/property_details_view";
  static const String galleryView = "/gallery_view";
  static const String furnishingDetailsView = "/furnishing_details_view";
  static const String aboutPropertyView = "/about_property_view";
  static const String contactOwnerView = "/contact_owner_view";
  static const String postPropertyView = "/post_property_view";
  static const String addPropertyDetailsView = "/add_property_details_view";
  static const String addPhotosAndPricingView = "/add_photos_and_pricing_view";
  static const String addAmenitiesView = "/add_amenities_view";
  static const String showPropertyDetailsView = "/show_property_details_view";
  static const String editPropertyView = "/edit_property_view";
  static const String editPropertyDetailsView = "/edit_property_details_view";
  static const String popularBuildersView = "/popular_builders_view";
  static const String savedPropertiesView = "/saved_properties_view";
  static const String contactPropertyView = "/contact_property_view";
  static const String viewedPropertyView = "/viewed_property_view";
  static const String recentActivityView = "/recent_activity_view";
  static const String responsesView = "/responses_view";
  static const String leadDetailsView = "/lead_details_view";
  static const String editProfileView = "/edit_profile_view";
  static const String agentsListView = "/agents_list_view";
  static const String agentsDetailsView = "/agents_details_view";
  static const String addReviewsForBrokerView = "/add_reviews_for_broker_view";
  static const String addReviewsForPropertyView = "/add_reviews_for_property_view";
  static const String addPropertyReviewView = "/add_property_review_view";
  static const String interestingReadsView = "/interesting_reads_view";
  static const String interestingReadsDetailsView = "/interesting_reads_details_view";
  static const String communitySettingsView = "/community_settings_view";
  static const String feedbackView = "/feedback_view";
  static const String termsOfUseView = "/terms_of_use_view";
  static const String privacyPolicyView = "/privacy_policy_view";
  static const String aboutUsView = "/about_us_view";
  static const String languagesView = "/languages_view";
  // static const String deleteListingView = "/delete_listing_view";  // Disabled: Your Listing functionality
  static const String activityView = "/activity_view";
  static const String notificationDebugView = "/notification_debug_view";
  static const String artsAntiquesView = "/arts_antiques_view";
  static const String artsAntiquesDetailsView = "/arts_antiques_details_view";
  static const String artsAntiquesSearchView = "/arts_antiques_search_view";
  static const String artsAntiquesSearchListView = "/arts_antiques_search_list_view";
  static const String artistDetailsView = "/artist_details_view";
  static const String upcomingProjectsView = "/upcoming_projects_view";
  static const String upcomingProjectDetailsView = "/upcoming_project_details_view";
  static const String animationDemoView = "/animation_demo_view";

  static List<GetPage> pages = [
    // Splash & Onboarding - Fade transitions
    GetPage(
      name: splashView,
      page: () => SplashView(),
      transition: Transition.fadeIn,
      transitionDuration: AppAnimations.fast,
    ),
    GetPage(
      name: onboardView,
      page: () => OnboardView(),
      customTransition: _CustomPageTransition(PageTransitions.fadeThrough),
      transitionDuration: AppAnimations.medium,
    ),
    
    // Auth screens - Slide and fade
    GetPage(
      name: loginView,
      page: () => LoginView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: otpView,
      page: () => OtpView(),
      customTransition: _CustomPageTransition(PageTransitions.slideScale),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: registerView,
      page: () => RegisterView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    
    // Main screens - YouTube-fast
    GetPage(
      name: homeView,
      page: () => HomeView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 150),
    ),
    GetPage(
      name: bottomBarView,
      page: () => BottomBarView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 150),
    ),
    GetPage(
      name: notificationView,
      page: () => NotificationView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 150),
    ),
    GetPage(
      name: searchView,
      page: () => SearchView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 150),
    ),
    
    // Property screens - Premium transitions
    GetPage(
      name: propertyListView,
      page: () => PropertyListView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    ),
    GetPage(
      name: propertyDetailsView,
      page: () => PropertyDetailsView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    ),
    GetPage(
      name: galleryView,
      page: () => GalleryView(),
      customTransition: _CustomPageTransition(PageTransitions.scaleAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: furnishingDetailsView,
      page: () => FurnishingDetailsView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: aboutPropertyView,
      page: () => AboutPropertyView(),
      customTransition: _CustomPageTransition(PageTransitions.slideUp),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: contactOwnerView,
      page: () => ContactOwnerView(),
      customTransition: _CustomPageTransition(PageTransitions.slideUp),
      transitionDuration: AppAnimations.medium,
    ),
    
    // Post Property Flow - Sequential animations
    GetPage(
      name: postPropertyView,
      page: () => PostPropertyView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: addPropertyDetailsView,
      page: () => AddPropertyDetailsView(),
      customTransition: _CustomPageTransition(PageTransitions.sharedAxisX),
      transitionDuration: AppAnimations.normal,
    ),
    GetPage(
      name: addPhotosAndPricingView,
      page: () => AddPhotoAndPricingView(),
      customTransition: _CustomPageTransition(PageTransitions.sharedAxisX),
      transitionDuration: AppAnimations.normal,
    ),
    GetPage(
      name: addAmenitiesView,
      page: () => AddAmenitiesView(),
      customTransition: _CustomPageTransition(PageTransitions.sharedAxisX),
      transitionDuration: AppAnimations.normal,
    ),
    GetPage(
      name: showPropertyDetailsView,
      page: () => ShowPropertyDetailsView(),
      customTransition: _CustomPageTransition(PageTransitions.scaleAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: editPropertyView,
      page: () => EditPropertyView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: editPropertyDetailsView,
      page: () => EditPropertyDetailsView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    
    // Listing screens - Elegant transitions
    GetPage(
      name: popularBuildersView,
      page: () => PopularBuildersView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: savedPropertiesView,
      page: () => SavedPropertiesView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: contactPropertyView,
      page: () => ContactPropertyView(),
      customTransition: _CustomPageTransition(PageTransitions.slideUp),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: viewedPropertyView,
      page: () => ViewedPropertyView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: recentActivityView,
      page: () => RecentActivityView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: responsesView,
      page: () => ResponsesView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: leadDetailsView,
      page: () => const LeadDetailsView(),
      customTransition: _CustomPageTransition(PageTransitions.slideUp),
      transitionDuration: AppAnimations.medium,
    ),
    
    // Profile & Settings - Slide transitions
    GetPage(
      name: editProfileView,
      page: () => EditProfileView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: agentsListView,
      page: () => AgentsListView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: agentsDetailsView,
      page: () => AgentsDetailsView(),
      customTransition: _CustomPageTransition(PageTransitions.sharedAxisX),
      transitionDuration: AppAnimations.medium,
    ),
    
    // Reviews - Modal-style transitions
    GetPage(
      name: addReviewsForBrokerView,
      page: () => AddReviewsForBrokerView(),
      customTransition: _CustomPageTransition(PageTransitions.slideUp),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: addReviewsForPropertyView,
      page: () => AddReviewsForPropertyView(),
      customTransition: _CustomPageTransition(PageTransitions.slideUp),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: addPropertyReviewView,
      page: () => AddPropertyReviewView(),
      customTransition: _CustomPageTransition(PageTransitions.slideUp),
      transitionDuration: AppAnimations.medium,
    ),
    
    // Content screens
    GetPage(
      name: interestingReadsView,
      page: () => InterestingReadsView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: interestingReadsDetailsView,
      page: () => InterestingReadsDetailsView(),
      customTransition: _CustomPageTransition(PageTransitions.sharedAxisX),
      transitionDuration: AppAnimations.medium,
    ),
    
    // Settings screens
    GetPage(
      name: communitySettingsView,
      page: () => CommunitySettingsView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: feedbackView,
      page: () => FeedbackView(),
      customTransition: _CustomPageTransition(PageTransitions.slideUp),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: termsOfUseView,
      page: () => const TermsOfUseView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: privacyPolicyView,
      page: () => const PrivacyPolicyView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: aboutUsView,
      page: () => const AboutUsView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: languagesView,
      page: () => LanguagesView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    
    // Other screens
    GetPage(
      name: activityView,
      page: () => ActivityView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: notificationDebugView,
      page: () => const NotificationDebugView(),
      customTransition: _CustomPageTransition(PageTransitions.slideUp),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: artsAntiquesView,
      page: () => ArtsAntiquesView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: artsAntiquesDetailsView,
      page: () => ArtsAntiquesDetailsView(),
      customTransition: _CustomPageTransition(PageTransitions.sharedAxisX),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: artsAntiquesSearchView,
      page: () => const ArtsAntiquesSearchView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: artsAntiquesSearchListView,
      page: () => ArtsAntiquesSearchListView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: artistDetailsView,
      page: () => const ArtistDetailsView(),
      customTransition: _CustomPageTransition(PageTransitions.sharedAxisX),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: upcomingProjectsView,
      page: () => UpcomingProjectsView(),
      customTransition: _CustomPageTransition(PageTransitions.slideAndFade),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: upcomingProjectDetailsView,
      page: () => UpcomingProjectDetailsView(),
      customTransition: _CustomPageTransition(PageTransitions.sharedAxisX),
      transitionDuration: AppAnimations.medium,
    ),
    GetPage(
      name: animationDemoView,
      page: () => const AnimationDemoView(),
      customTransition: _CustomPageTransition(PageTransitions.scaleAndFade),
      transitionDuration: AppAnimations.medium,
    ),
  ];
}

/// Custom page transition wrapper for GetX
class _CustomPageTransition extends CustomTransition {
  final Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  ) transitionBuilder;

  _CustomPageTransition(this.transitionBuilder);

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return transitionBuilder(context, animation, secondaryAnimation, child);
  }
}
