import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SplashStatus {
  admin,
  member,
  notLoggedIn,
  noInternet,
}

final splashProvider = FutureProvider<SplashStatus>((ref) async {
  await Future.delayed(const Duration(seconds: 2));

  // Step 1: Check network type
  final connectivity = await Connectivity().checkConnectivity();

  if (connectivity == ConnectivityResult.none) {
    return SplashStatus.noInternet;
  }

  // Step 2: Real internet check (IMPORTANT)
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isEmpty || result[0].rawAddress.isEmpty) {
      return SplashStatus.noInternet;
    }
  } catch (_) {
    return SplashStatus.noInternet;
  }

  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    return SplashStatus.notLoggedIn;
  }

  final response = await supabase
      .from('users')
      .select('role')
      .eq('id', user.id)
      .single();

  final role = response['role'];

  if (role == 'admin') {
    return SplashStatus.admin;
  } else {
    return SplashStatus.member;
  }
});