import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_screen.dart';
import '../features/auth/phone_verify_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/match/screens/home_screen.dart';
import '../features/match/screens/match_list_screen.dart';
import '../features/match/screens/match_create_screen.dart';
import '../features/match/screens/match_detail_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/notification_settings_screen.dart';
import 'splash_screen.dart';

/// 라우터 프로바이더
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/phone-verify',
        name: 'phone-verify',
        builder: (context, state) => const PhoneVerifyScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/match',
        name: 'match',
        builder: (context, state) => const MatchListScreen(),
      ),
      GoRoute(
        path: '/match/create',
        name: 'match-create',
        builder: (context, state) => const MatchCreateScreen(),
      ),
      GoRoute(
        path: '/match/:id',
        name: 'match-detail',
        builder: (context, state) {
          final matchId = state.pathParameters['id']!;
          return MatchDetailScreen(matchId: matchId);
        },
      ),
      GoRoute(
        path: '/chat/:id',
        name: 'chat',
        builder: (context, state) {
          final matchId = state.pathParameters['id']!;
          return ChatScreen(matchId: matchId);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/notifications',
        name: 'notification-settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
    ],
  );
});


