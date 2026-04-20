import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/routing/app_routes.dart';
import '../../core/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_shimmer.dart';
import 'services/home_service.dart';
import 'models/home_data_model.dart';
import '../../core/localization/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late Future<HomeDataModel> _homeFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final future = HomeService().getHomeData();
    future.then((data) {
      if (data.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data.error}')),
        );
      }

      if (!mounted) return;
      final appState = context.read<AppState>();
      if (data.doctorName.isNotEmpty && appState.doctorName.isEmpty) {
        appState.updateDoctorProfile(name: data.doctorName);
      }
    });
    setState(() {
      _homeFuture = future;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) context.go(AppRoutes.history);
          if (index == 2) context.go(AppRoutes.profile);
          if (index == 3) context.go(AppRoutes.settings);
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard_rounded), label: 'home'.tr(context)),
          BottomNavigationBarItem(icon: const Icon(Icons.history_rounded), label: 'history'.tr(context)),
          BottomNavigationBarItem(icon: const Icon(Icons.person_rounded), label: 'profile'.tr(context)),
          BottomNavigationBarItem(icon: const Icon(Icons.settings_rounded), label: 'settings'.tr(context)),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<HomeDataModel>(
          future: _homeFuture,
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            final homeData = snapshot.data ??
                HomeDataModel(
                  doctorName: context.read<AppState>().doctorName,
                  doctorImage: null,
                  totalPatients: 0,
                  totalReports: 0,
                  recentAnalyses: <AnalysisItemModel>[],
                );

            return RefreshIndicator(
              onRefresh: () async {
                _refresh();
                await _homeFuture;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, homeData, isLoading),
                    const SizedBox(height: 32),
                    _buildSearchSection(),
                    const SizedBox(height: 32),
                    _buildStatsGrid(context, homeData, isLoading),
                    const SizedBox(height: 32),
                    _buildQuickActions(context),
                    const SizedBox(height: 32),
                    _buildInsightsSection(isLoading),
                    const SizedBox(height: 32),
                    _buildProTip(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeDataModel data, bool isLoading) {
    return Row(
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          borderRadius: 30,
          showBorder: false,
          child: SizedBox(
            width: 60,
            height: 60,
            child: Consumer<AppState>(
              builder: (context, appState, _) => ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: appState.profileImageFile != null
                    ? Image.file(appState.profileImageFile!, fit: BoxFit.cover)
                    : (data.doctorImage != null && data.doctorImage!.isNotEmpty
                        ? Image.network(data.doctorImage!, fit: BoxFit.cover)
                        : const Icon(Icons.person_rounded, size: 30, color: AppColors.primary)),
              ),
            ),
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading)
                const AppShimmer(width: 150, height: 24)
              else
                Consumer<AppState>(
                  builder: (context, appState, _) => Text(
                    'welcome'.tr(context) + appState.doctorName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ).animate().fadeIn().slideX(begin: -0.1),
              const SizedBox(height: 4),
              Text(
                'ready_analysis'.tr(context),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              ).animate().fadeIn(delay: 100.ms),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('find_patient'.tr(context), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'search_hint'.tr(context),
              prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.primary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildStatsGrid(BuildContext context, HomeDataModel data, bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => context.push(AppRoutes.patients).then((_) => _refresh()),
            borderRadius: BorderRadius.circular(20),
            child: _buildStatCard(
              'patients'.tr(context),
              data.totalPatients.toString(),
              'total_records'.tr(context),
              Icons.people_alt_rounded,
              isLoading,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'reports'.tr(context),
            data.totalReports.toString(),
            'analyses_done'.tr(context),
            Icons.description_rounded,
            isLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String sub, IconData icon, bool isLoading) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const AppShimmer(width: 60, height: 32)
          else
            Text(value, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28)),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(sub, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'add_patient'.tr(context),
                icon: Icons.person_add_rounded,
                height: 50,
                onPressed: () => context.push(AppRoutes.addPatient).then((_) => _refresh()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                text: 'analyze'.tr(context),
                icon: Icons.biotech_rounded,
                height: 50,
                onPressed: () => context.push(AppRoutes.upload).then((_) => _refresh()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'manage_patients'.tr(context),
                icon: Icons.manage_accounts_rounded,
                variant: AppButtonVariant.secondary,
                height: 50,
                onPressed: () => context.push(AppRoutes.patients).then((_) => _refresh()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                text: 'dicom_converter'.tr(context),
                icon: Icons.video_settings_rounded,
                variant: AppButtonVariant.secondary,
                height: 50,
                onPressed: () => context.push(AppRoutes.dicomConverter),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildInsightsSection(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('insights'.tr(context), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildInsightCard('Case Trends', 'Stenosis detection increased by 5%', Icons.trending_up, AppColors.danger),
              const SizedBox(width: 12),
              _buildInsightCard('System', 'AI analysis latency is optimal (0.8s)', Icons.bolt, AppColors.success),
              const SizedBox(width: 12),
              _buildInsightCard('Pending', '3 reports awaiting your review', Icons.fact_check, AppColors.warning),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildInsightCard(String title, String desc, IconData icon, Color color) {
    return AppCard(
      width: 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(desc, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildProTip() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pro Tip', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text(
                  'Upload DICOM files directly for better AI accuracy.',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}