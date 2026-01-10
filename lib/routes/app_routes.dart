import 'package:flutter/material.dart';
import 'auth/auth_routes.dart' as authRoutes;
import 'pages/pages_routes.dart' as pageRoutes;

final Map<String, WidgetBuilder> appRoutes = {
  ...authRoutes.authRoutes,
  ...pageRoutes.pageRoutes,
  // add other route maps here
};
