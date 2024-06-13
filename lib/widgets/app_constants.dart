// APP CONSTANTS NAME,ENDPOINTS

import 'package:intl/intl.dart';

class AppConstants {
  static const String APPNAME = 'KauntaBook';
  static const String BASE_URL = 'https://cashbook.shamostechsolutions.com';
  // authentication
  static const String FORGET_PASSWORD_URI = '/api/v1/auth/forgot-password';
  static const String RESET_PASSWORD_URI = '/api/v1/auth/reset-password';
  static const String REGISTER_URI = '/api/v1/auth/register';
  static const String LOGIN_URI = '/api/v1/auth/login';
  static const String TOKEN_URI = '/api/v1/user/cm-firebase-token';
  // BUSINESS
  static const String BUSINESS_URI = '/api/v1/business/list';
  static const String CREAT_BUSINESS_URI = '/api/v1/business/create_business';
  static const String DELETE_BUSINESS_URI = '/api/v1/business/delete-business/';
  static const String UPDATE_BUSINESS_URI = '/api/v1/business/update-business/';

  // NOTEBOOKS
  static const String NOTEBOOK_URI = '/api/v1/notebooks/list/';
  static const String CREAT_NOTEBOOK_URI = '/api/v1/notebooks/create_notebook';
  static const String DELETE_NOTEBOOK_URI =
      '/api/v1/notebooks/delete-notebook/';
  static const String UPDATE_BNOTEBOOK_URI =
      '/api/v1/notebooks/update-notebook/';

  // TRANSACTIONS
  static const String TRANSACTIONS_URI = '/api/v1/transactions/list/';
  static const String CREATE_TRANSACTION_URI =
      '/api/v1/transactions/create_trx';
  static const String DELETE_TRANSACTION_URI =
      '/api/v1/transactions/delete-trx/';
  static const String UPDATE_TRANSACTION_URI =
      '/api/v1/transactions/update-trx/';

  // configurations
  static const String CONFIG_URI = '/api/v1/config';

  // user account info
  static const String USER_INFO_URI = '/api/v1/user/info';
  static const String UPDATE_PROFILE_URI = '/api/v1/user/update-profile';

  // Shared Key
  static const String THEME = 'theme';
  static const String TOKEN = 'cashbook_token';
  static const String USER_PASSWORD = 'user_password';
  static const String USER_NAME = 'user_name';
  static const String NOTIFICATION = 'notification';
  static const String INTRO = 'intro';
  static const String NOTIFICATION_COUNT = 'notification_count';
  static const String TOPIC = 'kauntabook';

  static String formatCurrency(double amount) {
    final NumberFormat formatter = NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String capitalize(String s) {
    if (s.isNotEmpty) {
      return s[0].toUpperCase() + s.substring(1);
    } else {
      return '';
    }
  }
}
