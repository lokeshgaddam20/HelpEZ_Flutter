import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

import 'package:bridgefy_example/presentation/screens/home_screen.dart';
import 'package:bridgefy_example/config/theme/app_theme.dart';
import 'package:bridgefy_example/presentation/providers/chat_provider.dart';
import 'package:bridgefy_example/presentation/providers/sdk_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  String? name;
  String? phone;
  String? messages;

  @override
  void initState() {
    super.initState();

    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();

    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle links
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) {
    final queryParams = uri.queryParameters;
    setState(() {
      name = queryParams['name'];
      phone = queryParams['phone'];
      messages = uri.queryParameters['messages'] ?? '';
    });
    // _navigatorKey.currentState?.pushNamed(uri.fragment);
    _navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            HomeScreen(name: name, phone: phone, messages: messages),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SdkProvider>(create: (_) => SdkProvider()),
        ChangeNotifierProxyProvider<SdkProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (_, sdkProvider, chatProvider) =>
              chatProvider!..setSDK(sdkProvider),
        ),
      ],
      child: MaterialApp(
        title: 'Bridgefy example',
        debugShowCheckedModeBanner: false,
        theme: AppTheme().theme(),
        navigatorKey: _navigatorKey,
        home: HomeScreen(
          name: name,
          phone: phone,
          messages: messages,
        ),
      ),
    );
  }
}
