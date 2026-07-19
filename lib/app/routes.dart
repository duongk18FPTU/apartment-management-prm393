import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/admin/admin_home_screen.dart';
import '../screens/admin/user_management/user_create_screen.dart';
import '../screens/admin/user_management/user_edit_screen.dart';
import '../screens/admin/user_management/user_list_screen.dart';
import '../screens/auth/change_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/resident/complaints/complaint_create_screen.dart';
import '../screens/resident/complaints/complaint_detail_screen.dart';
import '../screens/resident/complaints/complaint_list_screen.dart';
import '../screens/resident/home/resident_home_screen.dart';
import '../screens/resident/my_requests/request_create_screen.dart';
import '../screens/resident/my_requests/request_detail_screen.dart';
import '../screens/resident/my_requests/request_list_screen.dart';
import '../screens/staff/complaint_management/complaint_manage_screen.dart';
import '../screens/staff/request_management/request_manage_screen.dart';
import '../screens/staff/staff_home_screen.dart';
import '../screens/staff/bill_management/bill_list_screen.dart';
import '../screens/staff/bill_management/bill_create_screen.dart';
import '../screens/staff/bill_management/bill_detail_screen.dart';
import '../screens/resident/my_bills/my_bills_screen.dart';
import '../screens/resident/my_bills/bill_payment_screen.dart';
import '../screens/resident/my_bills/payment_history_screen.dart';
import '../screens/resident/visitors/register_visitor_screen.dart';
import '../screens/staff/visitor_management/visitor_list_screen.dart';
import '../screens/admin/apartment_management/apartment_list_screen.dart';
import '../screens/admin/apartment_management/apartment_form_screen.dart';
import '../screens/admin/apartment_management/apartment_detail_screen.dart';
import '../screens/admin/resident_management/resident_list_screen.dart';
import '../screens/admin/resident_management/resident_form_screen.dart';
import '../screens/admin/resident_management/resident_profile_screen.dart';
import '../providers/apartment_provider.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

/// Builds and returns the app-wide [GoRouter] instance.
GoRouter buildAppRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authProvider,
    debugLogDiagnostics: true,
    redirect: _redirect,
    routes: _routes,
    errorBuilder: (context, state) => _RouterErrorScreen(error: state.error),
  );
}

String? _redirect(BuildContext context, GoRouterState state) {
  final auth = context.read<AuthProvider>();
  final location = state.matchedLocation;

  if (auth.status == AuthStatus.initial || auth.status == AuthStatus.loading) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  final isAuthenticated = auth.isAuthenticated;
  final isOnSplash = location == AppRoutes.splash;
  final isOnLogin = location == AppRoutes.login;

  if (!isAuthenticated) {
    if (isOnSplash || isOnLogin) return null;
    return AppRoutes.login;
  }

  if (isOnSplash || isOnLogin) {
    return _homeForRole(auth.role);
  }

  if (auth.role == UserRole.resident && location.startsWith('/admin')) {
    return AppRoutes.residentHome;
  }
  if (auth.role == UserRole.resident && location.startsWith('/staff')) {
    return AppRoutes.residentHome;
  }

  if (auth.role == UserRole.staff && location.startsWith('/admin')) {
    return AppRoutes.staffHome;
  }

  return null;
}

String _homeForRole(UserRole? role) {
  switch (role) {
    case UserRole.admin:
      return AppRoutes.adminHome;
    case UserRole.staff:
      return AppRoutes.staffHome;
    case UserRole.resident:
    case null:
      return AppRoutes.residentHome;
  }
}

final List<RouteBase> _routes = [
  GoRoute(
    path: AppRoutes.splash,
    name: 'splash',
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: AppRoutes.login,
    name: 'login',
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: AppRoutes.changePassword,
    name: 'changePassword',
    builder: (context, state) => const ChangePasswordScreen(),
  ),
  GoRoute(
    path: AppRoutes.adminHome,
    name: 'adminHome',
    builder: (context, state) => const AdminHomeScreen(),
  ),

  // Member 1 — User Management
  GoRoute(
    path: AppRoutes.userList,
    name: 'userList',
    builder: (context, state) => const UserListScreen(),
  ),
  GoRoute(
    path: AppRoutes.userCreate,
    name: 'userCreate',
    builder: (context, state) => const UserCreateScreen(),
  ),
  GoRoute(
    path: AppRoutes.userEdit,
    name: 'userEdit',
    builder: (context, state) =>
        UserEditScreen(userId: state.pathParameters['id']!),
  ),

  // Member 2 — Apartment Management (Admin)
  GoRoute(
    path: AppRoutes.apartmentList,
    name: 'apartmentList',
    builder: (context, state) => const ApartmentListScreen(),
  ),
  GoRoute(
    path: AppRoutes.apartmentForm,
    name: 'apartmentForm',
    builder: (context, state) => const ApartmentFormScreen(),
  ),
  GoRoute(
    path: AppRoutes.apartmentDetail,
    name: 'apartmentDetail',
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      final apartmentProvider = context.read<ApartmentProvider>();
      final apartment = apartmentProvider.apartments.firstWhere(
        (a) => a.id == id,
      );
      return ApartmentDetailScreen(apartment: apartment);
    },
  ),

  // Member 2 — Resident Management (Admin)
  GoRoute(
    path: AppRoutes.residentList,
    name: 'residentList',
    builder: (context, state) => const ResidentListScreen(),
  ),
  GoRoute(
    path: AppRoutes.residentForm,
    name: 'residentForm',
    builder: (context, state) => const ResidentFormScreen(),
  ),
  GoRoute(
    path: AppRoutes.residentProfile,
    name: 'residentProfile',
    builder: (context, state) {
      final resident = state.extra as UserModel;
      return ResidentProfileScreen(resident: resident);
    },
  ),

  GoRoute(
    path: AppRoutes.staffHome,
    name: 'staffHome',
    builder: (context, state) => const StaffHomeScreen(),
  ),
  GoRoute(
    path: AppRoutes.residentHome,
    name: 'residentHome',
    builder: (context, state) => const ResidentHomeScreen(),
  ),

  // Member 3 — Maintenance Request
  GoRoute(
    path: AppRoutes.requestList,
    name: 'requestList',
    builder: (context, state) => const RequestListScreen(),
  ),
  GoRoute(
    path: AppRoutes.requestCreate,
    name: 'requestCreate',
    builder: (context, state) => const RequestCreateScreen(),
  ),
  GoRoute(
    path: AppRoutes.requestManage,
    name: 'requestManage',
    builder: (context, state) => const RequestManageScreen(),
  ),
  GoRoute(
    path: AppRoutes.requestDetail,
    name: 'requestDetail',
    builder: (context, state) {
      final id = state.pathParameters['id'] ?? '';
      return RequestDetailScreen(requestId: id);
    },
  ),

  // Staff Bill Management (Sprint 1)
  GoRoute(
    path: AppRoutes.staffBills,
    name: 'staffBills',
    builder: (context, state) => const BillListScreen(),
  ),
  GoRoute(
    path: AppRoutes.staffBillCreate,
    name: 'staffBillCreate',
    builder: (context, state) => const BillCreateScreen(),
  ),
  GoRoute(
    path: AppRoutes.staffBillDetail,
    name: 'staffBillDetail',
    builder: (context, state) {
      final billId = state.pathParameters['id']!;
      return BillDetailScreen(billId: billId);
    },
  ),

  // Member 3 — Complaint / Feedback
  GoRoute(
    path: AppRoutes.complaintList,
    name: 'complaintList',
    builder: (context, state) => const ComplaintListScreen(),
  ),
  GoRoute(
    path: AppRoutes.complaintCreate,
    name: 'complaintCreate',
    builder: (context, state) => const ComplaintCreateScreen(),
  ),
  GoRoute(
    path: AppRoutes.complaintManage,
    name: 'complaintManage',
    builder: (context, state) => const ComplaintManageScreen(),
  ),
  GoRoute(
    path: AppRoutes.complaintDetail,
    name: 'complaintDetail',
    builder: (context, state) {
      final id = state.pathParameters['id'] ?? '';
      return ComplaintDetailScreen(complaintId: id);
    },
  ),

  // Resident Bills & Payment (Sprint 2)
  GoRoute(
    path: AppRoutes.residentBills,
    name: 'residentBills',
    builder: (context, state) => const MyBillsScreen(),
  ),
  GoRoute(
    path: AppRoutes.residentBillPay,
    name: 'residentBillPay',
    builder: (context, state) {
      final billId = state.pathParameters['id']!;
      return BillPaymentScreen(billId: billId);
    },
  ),
  GoRoute(
    path: AppRoutes.residentPaymentHistory,
    name: 'residentPaymentHistory',
    builder: (context, state) => const PaymentHistoryScreen(),
  ),

  // Member 5 — Visitors
  GoRoute(
    path: AppRoutes.residentVisitorRegister,
    name: 'residentVisitorRegister',
    builder: (context, state) => const RegisterVisitorScreen(),
  ),
  GoRoute(
    path: AppRoutes.staffVisitors,
    name: 'staffVisitors',
    builder: (context, state) => const VisitorListScreen(embedded: false),
  ),
];

class _RouterErrorScreen extends StatelessWidget {
  const _RouterErrorScreen({required this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64),
              const SizedBox(height: 16),
              Text(
                '404 — Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.splash),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
