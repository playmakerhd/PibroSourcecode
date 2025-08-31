import 'package:get/get.dart';
import 'package:pibro/core/claim/views/claim_details_screen.dart';
import 'package:pibro/core/claim/views/claim_screen.dart';
import 'package:pibro/core/claim/views/lodge_claims_screen.dart';
import 'package:pibro/core/config/view/service_config_screen.dart';
import 'package:pibro/core/landing/views/about_us_screen.dart';
import 'package:pibro/core/landing/views/contact_us_screen.dart';
import 'package:pibro/core/landing/views/faq_screen.dart';
import 'package:pibro/core/landing/views/landing_screen.dart';
import 'package:pibro/core/login/view/login_screen.dart';
import 'package:pibro/core/main_screen/view/main_screen.dart';
import 'package:pibro/core/policy/views/payment_confirmation_screen.dart';
import 'package:pibro/core/policy/views/policies_screen.dart';
import 'package:pibro/core/policy/views/policy_details_screen.dart';
import 'package:pibro/core/policy/views/renew_policy_confirmation_screen.dart';
import 'package:pibro/core/policy/views/renew_policy_screen.dart';
import 'package:pibro/core/profile/views/account_handler_screen.dart';
import 'package:pibro/core/profile/views/configuration_screen.dart';
import 'package:pibro/core/profile/views/info_screen.dart';
import 'package:pibro/core/quote/views/get_quote_screen.dart';
import 'package:pibro/core/quote/views/quote_confirmation_screen.dart';
import 'package:pibro/core/quote/views/quote_details_screen.dart';
import 'package:pibro/core/quote/views/quote_screen.dart';
import 'package:pibro/core/quote/views/quote_summary_screen.dart';
import 'package:pibro/core/quote/views/quotes_list_screen.dart';
import 'package:pibro/core/signup/view/signup_screen.dart';
import 'package:pibro/core/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String aboutUs = '/about-us';
  static const String contactUs = '/contact-us';
  static const String faq = '/faq';
  static const String landing = '/landing';
  static const String splash = '/splash';

  static const String main = '/main';
  static const String login = '/login';
  static const String signup = '/signup';

  static const String policy = '/policy';
  static const String renewPolicy = '/renew-policy';
  static const String renewPolicyConfirmation = '/renew-policy-confirmation';
  static const String itemsToInsure = '/items-to-insure';
  static const String policyDetail = '/policy-detail';
  static const String quoteDetail = '/quote-detail';
  static const String myInfo = '/my-info';
  static const String accountHandler = '/account-handler';
  static const String configuration = '/configuration';
  static const String serviceConfig = '/service-config';
  static const String quote = '/quote';
  static const String quoteList = '/quote-list';
  static const String getQuote = '/get-quote';
  static const String paymentConfirmation = '/payment-confirmation';
  static const String quoteConfirmation = '/quote-confirmation';
  static const String quoteSummary = '/quote-summary';

  static const String claim = '/claim';
  static const String claimDetail = '/claim-detail';
  static const String lodgeClaims = '/lodge-claims';

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: aboutUs,
      page: () => const AboutUsScreen(),
    ),
    GetPage(
      name: contactUs,
      page: () => const ContactUsScreen(),
    ),
    GetPage(
      name: faq,
      page: () => const FAQScreen(),
    ),
    GetPage(
      name: main,
      page: () => const MainScreen(),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: signup,
      page: () => const SignupScreen(),
    ),
    GetPage(
      name: policy,
      page: () => const PoliciesScreen(),
    ),
    GetPage(
      name: policyDetail,
      page: () => const PolicyDetailsScreen(),
    ),
    GetPage(
      name: quoteDetail,
      page: () => const QuoteDetailsScreen(),
    ),
    GetPage(
      name: myInfo,
      page: () => const InfoScreen(),
    ),
    GetPage(
      name: accountHandler,
      page: () => const AccountHandlerScreen(),
    ),
    GetPage(
      name: configuration,
      page: () => const ConfigurationScreen(),
    ),
    GetPage(
      name: renewPolicy,
      page: () => const RenewPolicyScreen(),
    ),
    GetPage(
      name: renewPolicyConfirmation,
      page: () => const RenewPolicyConfirmationScreen(),
    ),
    GetPage(
      name: quoteConfirmation,
      page: () => const QuoteConfirmationScreen(),
    ),
     GetPage(name: quoteSummary, page: () => const QuoteSummaryScreen()),
    GetPage(
      name: paymentConfirmation,
      page: () => const PaymentConfirmationScreen(),
    ),
    GetPage(
      name: quote,
      page: () => const QuoteScreen(),
    ),
    GetPage(
      name: quoteList,
      page: () => const QuoteListScreen(),
    ),
    GetPage(
      name: getQuote,
      page: () => const GetQuoteScreen(),
    ),
    GetPage(
      name: claim,
      page: () => const ClaimScreen(),
    ),
    GetPage(
      name: claimDetail,
      page: () => const ClaimDetailsScreen(),
    ),
    GetPage(
      name: lodgeClaims,
      page: () => const LodgeClaimsScreen(),
    ),
    GetPage(
      name: landing,
      page: () => LandingScreen(),
    ),
    GetPage(
      name: serviceConfig,
      page: () => ServiceConfigScreen(),
    ),
  ];
}
