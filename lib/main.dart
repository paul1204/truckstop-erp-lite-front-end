import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/ui/core/background_effects.dart';

// Import Feature views and state notifiers
import 'package:self_improvement_app/features/profile_switcher/profile_switcher_notifier.dart';
import 'package:self_improvement_app/features/profile_switcher/profile_switcher_view.dart';

import 'package:self_improvement_app/features/dashboard/dashboard_notifier.dart';
import 'package:self_improvement_app/features/dashboard/dashboard_view.dart';

import 'package:self_improvement_app/features/fuel_inventory/fuel_inventory_notifier.dart';
import 'package:self_improvement_app/features/fuel_inventory/fuel_inventory_view.dart';

import 'package:self_improvement_app/features/blackjack/blackjack_notifier.dart';
import 'package:self_improvement_app/features/blackjack/blackjack_view.dart';

import 'package:self_improvement_app/features/inventory/inventory_notifier.dart';
import 'package:self_improvement_app/features/inventory/inventory_view.dart';

import 'package:self_improvement_app/features/house_accounts/house_accounts_notifier.dart';
import 'package:self_improvement_app/features/house_accounts/house_accounts_view.dart';
import 'package:self_improvement_app/features/house_accounts/house_accounts_view_v2.dart';

import 'package:self_improvement_app/features/parking/parking_notifier.dart';
import 'package:self_improvement_app/features/parking/parking_view.dart';
import 'package:self_improvement_app/features/parking/parking_view_v2.dart';

import 'package:self_improvement_app/features/showers/showers_notifier.dart';
import 'package:self_improvement_app/features/showers/showers_view.dart';
import 'package:self_improvement_app/features/showers/showers_view_v2.dart';

import 'package:self_improvement_app/features/about/about_view.dart';
import 'package:self_improvement_app/features/sales/sales_view.dart';
import 'package:self_improvement_app/features/settings/theme_notifier.dart';
import 'package:self_improvement_app/features/settings/settings_view.dart';

void main() {
  runApp(const TruckStopApp());
}

class TruckStopApp extends StatefulWidget {
  const TruckStopApp({super.key});

  @override
  State<TruckStopApp> createState() => _TruckStopAppState();
}

class _TruckStopAppState extends State<TruckStopApp> {
  // Global ViewModels/Notifiers
  final ProfileNotifier _profileNotifier = ProfileNotifier();
  final ThemeNotifier _themeNotifier = ThemeNotifier();
  final DashboardNotifier _dashboardNotifier = DashboardNotifier();
  final FuelInventoryNotifier _fuelNotifier = FuelInventoryNotifier();
  final BlackjackNotifier _blackjackNotifier = BlackjackNotifier();
  final InventoryNotifier _inventoryNotifier = InventoryNotifier();
  final HouseAccountsNotifier _houseAccountsNotifier = HouseAccountsNotifier();
  final ParkingNotifier _parkingNotifier = ParkingNotifier();
  final ShowersNotifier _showersNotifier = ShowersNotifier();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_profileNotifier, _themeNotifier]),
      builder: (context, _) {
        final activeProfile = _profileNotifier.activeProfile;

        // Custom Theme Mode resolving
        ThemeMode themeMode = _themeNotifier.themeMode;
        if (activeProfile == AppProfile.profileB) {
          themeMode = ThemeMode.light; // B forces Redwood Light Creme theme
        }

        return MaterialApp(
          title: 'Truck Stop 1 LTE ERP',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: const Color(0xFF004B50),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: const Color(0xFF4DB6AC),
          ),
          home: Scaffold(
            body: AppShell(
              profileNotifier: _profileNotifier,
              themeNotifier: _themeNotifier,
              dashboardNotifier: _dashboardNotifier,
              fuelNotifier: _fuelNotifier,
              blackjackNotifier: _blackjackNotifier,
              inventoryNotifier: _inventoryNotifier,
              houseAccountsNotifier: _houseAccountsNotifier,
              parkingNotifier: _parkingNotifier,
              showersNotifier: _showersNotifier,
            ),
          ),
        );
      },
    );
  }
}

class AppShell extends StatefulWidget {
  final ProfileNotifier profileNotifier;
  final ThemeNotifier themeNotifier;
  final DashboardNotifier dashboardNotifier;
  final FuelInventoryNotifier fuelNotifier;
  final BlackjackNotifier blackjackNotifier;
  final InventoryNotifier inventoryNotifier;
  final HouseAccountsNotifier houseAccountsNotifier;
  final ParkingNotifier parkingNotifier;
  final ShowersNotifier showersNotifier;

  const AppShell({
    super.key,
    required this.profileNotifier,
    required this.themeNotifier,
    required this.dashboardNotifier,
    required this.fuelNotifier,
    required this.blackjackNotifier,
    required this.inventoryNotifier,
    required this.houseAccountsNotifier,
    required this.parkingNotifier,
    required this.showersNotifier,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String _activeTab = 'Dashboard';

  // Available tabs definitions
  final List<Map<String, dynamic>> _tabs = [
    {'name': 'Dashboard', 'icon': '📊'},
    {'name': 'Sales', 'icon': '💰'},
    {'name': 'Fuel Inventory', 'icon': '⛽'},
    {'name': 'Black Jack', 'icon': '♠️'},
    {'name': 'Inventory', 'icon': '📦'},
    {'name': 'House Accounts', 'icon': '🏠'},
    {'name': 'House Accounts V2', 'icon': '📇'},
    {'name': 'Parking', 'icon': '🅿️'},
    {'name': 'Parking V2', 'icon': '🚚'},
    {'name': 'Showers', 'icon': '🚿'},
    {'name': 'Showers V2', 'icon': '🧼'},
    {'name': 'About', 'icon': 'ℹ️'},
    {'name': 'Bliss', 'icon': '✨'},
    {'name': 'Settings', 'icon': '⚙️'},
  ];

  @override
  void initState() {
    super.initState();
    // 1. Listen for category changes in inventory notifier to keep browser URL synced
    widget.inventoryNotifier.addListener(_updateWebUrl);

    // 2. Parse initial tab/category query parameters from deep link URL (Uri.base)
    final uri = Uri.base;
    String? tabParam = uri.queryParameters['tab'];
    String? catParam = uri.queryParameters['category'];
    String? animParam = uri.queryParameters['animation'];

    // If query params are empty (typical in hash routing), parse them from the fragment
    if (tabParam == null && uri.fragment.isNotEmpty) {
      try {
        final fragmentUri = Uri.parse(uri.fragment);
        tabParam = fragmentUri.queryParameters['tab'];
        catParam ??= fragmentUri.queryParameters['category'];
        animParam ??= fragmentUri.queryParameters['animation'];
      } catch (_) {}
    }

    if (tabParam != null) {
      final match = _tabs.any((t) => t['name'].toString().toLowerCase() == tabParam!.toLowerCase());
      if (match) {
        _activeTab = _tabs.firstWhere((t) => t['name'].toString().toLowerCase() == tabParam!.toLowerCase())['name'];
      }
    }

    if (_activeTab == 'Inventory') {
      if (catParam != null && (catParam == 'packagedFood' || catParam == 'bottledBeverages')) {
        widget.inventoryNotifier.setCategory(catParam);
      }

      if (animParam != null) {
        final valid = ['Fade', 'Scale', 'Slide', 'Flip', 'Bounce'].contains(animParam);
        if (valid) {
          widget.inventoryNotifier.setAnimationType(animParam);
        }
      }
    }

    // 3. Keep web URL in sync
    _updateWebUrl();
  }

  @override
  void dispose() {
    widget.inventoryNotifier.removeListener(_updateWebUrl);
    super.dispose();
  }

  void _selectTab(String tabName) {
    setState(() {
      _activeTab = tabName;
    });
    _updateWebUrl();
  }

  void _updateWebUrl() {
    String location = '/?tab=$_activeTab';
    if (_activeTab == 'Inventory') {
      location += '&category=${widget.inventoryNotifier.category}';
      location += '&animation=${widget.inventoryNotifier.animationType}';
    }
    SystemNavigator.routeInformationUpdated(
      uri: Uri.parse(location),
    );
  }

  Widget _buildActiveTabContent(StyleTokens tokens) {
    switch (_activeTab) {
      case 'Dashboard':
        return DashboardView(
          notifier: widget.dashboardNotifier,
          tokens: tokens,
          onViewSalesTap: () => _selectTab('Sales'),
        );
      case 'Sales':
        return SalesView(tokens: tokens);
      case 'Fuel Inventory':
        return FuelInventoryView(notifier: widget.fuelNotifier, tokens: tokens);
      case 'Black Jack':
        return BlackjackView(notifier: widget.blackjackNotifier, tokens: tokens);
      case 'Inventory':
        return InventoryView(notifier: widget.inventoryNotifier, tokens: tokens);
      case 'House Accounts':
        return HouseAccountsView(notifier: widget.houseAccountsNotifier, tokens: tokens);
      case 'House Accounts V2':
        return HouseAccountsViewV2(notifier: widget.houseAccountsNotifier, tokens: tokens);
      case 'Parking':
        return ParkingView(notifier: widget.parkingNotifier, tokens: tokens);
      case 'Parking V2':
        return ParkingViewV2(notifier: widget.parkingNotifier, tokens: tokens);
      case 'Showers':
        return ShowersView(notifier: widget.showersNotifier, tokens: tokens);
      case 'Showers V2':
        return ShowersViewV2(notifier: widget.showersNotifier, tokens: tokens);
      case 'About':
        return AboutView(tokens: tokens);
      case 'Bliss':
        return const SizedBox.shrink();
      case 'Settings':
        return SettingsView(tokens: tokens, themeNotifier: widget.themeNotifier);
      default:
        return Center(child: Text('Page not found: $_activeTab'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Resolve theme brightness based on ThemeNotifier or profile override
    Brightness brightness = widget.themeNotifier.themeMode == ThemeMode.dark 
        ? Brightness.dark 
        : Brightness.light;
    if (widget.profileNotifier.activeProfile == AppProfile.profileB) {
      brightness = Brightness.light;
    }
    final tokens = StyleTokens(
      profile: widget.profileNotifier.activeProfile,
      brightness: brightness,
    );

    return Container(
      color: tokens.background,
      child: Column(
        children: [
          // 1. Header Row
          Container(
            height: 56,
            color: tokens.headerBg,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header Logo
                Row(
                  children: [
                    const Icon(Icons.local_shipping, color: Colors.tealAccent, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Truck Stop 1 LTE ERP',
                      style: TextStyle(
                        fontFamily: tokens.serifFont,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: tokens.headerText,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                // Profile Switcher dropdown
                ProfileSwitcher(
                  notifier: widget.profileNotifier,
                  tokens: tokens,
                ),
              ],
            ),
          ),

          // 2. Horizontal Scrollable Sticky Navigation Bar
          Container(
            height: 48,
            width: double.infinity,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: tokens.navBg,
              border: Border(
                bottom: BorderSide(color: tokens.border, width: 1),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _tabs.map((tab) {
                  final String tabName = tab['name'];
                  final String tabIcon = tab['icon'];
                  final bool isActive = _activeTab == tabName;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => _selectTab(tabName),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive
                              ? tokens.accent.withOpacity(0.08)
                              : Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: isActive ? tokens.accent : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(tabIcon, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              tabName,
                              style: TextStyle(
                                fontFamily: tokens.sansFont,
                                fontSize: 13,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                color: isActive ? tokens.accent : tokens.textMain.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 3. Main Content & Animated Background
          Expanded(
            child: FloatingBackground(
              tokens: tokens,
              child: _buildActiveTabContent(tokens),
            ),
          ),

          // 4. Footer Row
          Container(
            color: tokens.footerBg,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFooterLink('About ERP', tokens),
                      _buildFooterDivider(tokens),
                      _buildFooterLink('Contact Us', tokens),
                      _buildFooterDivider(tokens),
                      _buildFooterLink('Legal Notices', tokens),
                      _buildFooterDivider(tokens),
                      _buildFooterLink('Terms Of Use', tokens),
                      _buildFooterDivider(tokens),
                      _buildFooterLink('Privacy Policy', tokens),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Copyright © 2014, 2026 Truck Stop 1 LTE ERP and/or its affiliates. All rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: tokens.sansFont,
                    fontSize: 10,
                    color: tokens.footerText.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, StyleTokens tokens) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 11,
        color: tokens.footerText,
        decoration: TextDecoration.underline,
      ),
    );
  }

  Widget _buildFooterDivider(StyleTokens tokens) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        '|',
        style: TextStyle(fontSize: 10, color: tokens.footerText.withOpacity(0.5)),
      ),
    );
  }
}
