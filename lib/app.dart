import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:betwizz_app/features/auth/screens/login_screen.dart';
import 'package:betwizz_app/features/auth/screens/register_screen.dart';
import 'package:betwizz_app/features/channels/screens/channel_dashboard_screen.dart';
import 'package:betwizz_app/features/channels/screens/create_channel_screen.dart';
import 'package:betwizz_app/features/channels/screens/video_player_screen.dart'; // Import VideoPlayerScreen
import 'package:betwizz_app/features/receipt_processing/screens/receipt_scan_screen.dart';
import 'package:betwizz_app/features/ai/screens/ai_dashboard_screen.dart';
import 'package:betwizz_app/core/theme/app_theme.dart';
import 'package:betwizz_app/features/auth/notifiers/auth_notifier.dart';
import 'package:betwizz_app/features/auth/models/auth_state.dart';

// Define route names for easy access and to avoid typos
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String channelDashboard = '/channel-dashboard';
  static const String createChannel = '/create-channel';
  static const String videoPlayerDemo = '/video-player-demo'; // Add videoPlayerDemo route
  static const String receiptScan = '/receipt-scan';
  static const String aiDashboard = '/ai-dashboard';
  // Add other routes here
}

// Using a GlobalKey for NavigatorState to allow navigation from outside BuildContext,
// e.g. from the auth state listener.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class BetwizzApp extends ConsumerWidget { // Changed to ConsumerWidget
  const BetwizzApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef
    // Listen to auth state changes for navigation.
    // This is a common pattern for handling auth redirects.
    ref.listen<AsyncValue<AuthState>>(authNotifierProvider, (previous, next) {
      final authState = next.asData?.value;
      final currentContext = navigatorKey.currentContext;
      if (currentContext != null) {
        if (authState is Authenticated) {
          // Ensure we don't push multiple dashboards if already there or navigating away
          if (ModalRoute.of(currentContext)?.settings.name != AppRoutes.channelDashboard) {
             Navigator.of(currentContext).pushNamedAndRemoveUntil(AppRoutes.channelDashboard, (route) => false);
          }
        } else if (authState is Unauthenticated || authState is AuthError) {
           // Ensure we don't push multiple login screens
          if (ModalRoute.of(currentContext)?.settings.name != AppRoutes.login) {
            Navigator.of(currentContext).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
          }
        }
      }
    });

    return MaterialApp(
      navigatorKey: navigatorKey, // Assign the navigatorKey
      title: 'Betwizz',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,

      // The home will be determined by the initial state of authNotifierProvider,
      // or a loading screen while it resolves.
      home: ref.watch(authNotifierProvider).when(
            data: (authState) {
              if (authState is Authenticated) {
                return const ChannelDashboardScreen();
              }
              // For Unauthenticated, AuthInitial, AuthError states
              return const LoginScreen();
            },
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (err, stack) => Scaffold(
              body: Center(child: Text('Error loading app: $err')),
            ),
          ),

      // Routes are still useful for named navigation triggered from within the app
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.channelDashboard: (context) => const ChannelDashboardScreen(),
        AppRoutes.createChannel: (context) => const CreateChannelScreen(),
        AppRoutes.videoPlayerDemo: (context) => const VideoPlayerScreen(), // Add route for VideoPlayerScreen
        AppRoutes.receiptScan: (context) => const ReceiptScanScreen(),
        AppRoutes.aiDashboard: (context) => const AiDashboardScreen(),
      },
    );
  }
}
