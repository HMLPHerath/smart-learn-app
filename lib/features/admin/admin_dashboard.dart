import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../core/widgets/top_blue_header.dart';
import '../../di/injection.dart';
import '../../data/repositories/admin_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  AdminDashboardStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stats = await adminRepository.getDashboardStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      children: [
                        TopBlueHeader(
                          height: 235,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(.18),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: const Icon(
                                      Icons.admin_panel_settings_outlined,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Good Morning, Admin',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Admin Dashboard',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isWide = constraints.maxWidth > 680;

                                  return GridView.count(
                                    crossAxisCount: isWide ? 4 : 2,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: isWide ? 1.35 : 1.0,
                                    children: [
                                      _StatCard(
                                        title: 'Students',
                                        value: _stats?.totalStudents.toString() ?? '0',
                                        icon: Icons.groups_outlined,
                                      ),
                                      _StatCard(
                                        title: 'Parents',
                                        value: _stats?.totalParents.toString() ?? '0',
                                        icon: Icons.family_restroom_outlined,
                                      ),
                                      _StatCard(
                                        title: 'Teachers',
                                        value: _stats?.totalTeachers.toString() ?? '0',
                                        icon: Icons.school_outlined,
                                      ),
                                      _StatCard(
                                        title: 'Notices',
                                        value: _stats?.totalNotices.toString() ?? '0',
                                        icon: Icons.campaign_outlined,
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 18),
                              const _SectionCard(
                                title: 'Quick Actions',
                                child: _QuickActionsGrid(),
                              ),
                              const SizedBox(height: 18),
                              _SectionCard(
                                title: 'Recent Alerts',
                                child: _stats != null && _stats!.recentAlerts.isNotEmpty
                                    ? Column(
                                        children: _stats!.recentAlerts.map((notice) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: _AlertTile(
                                              title: notice['Subject'] ?? 'Notice',
                                              subtitle: notice['NoticeBody'] ?? '',
                                              icon: Icons.warning_amber_rounded,
                                            ),
                                          );
                                        }).toList(),
                                      )
                                    : const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text('No recent alerts available.'),
                                    ),
                              ),
                              const SizedBox(height: 18),
                              _SectionCard(
                                title: 'Latest Updates',
                                child: _stats != null && _stats!.latestUpdates.isNotEmpty
                                    ? Column(
                                        children: _stats!.latestUpdates.map((update) {
                                          final id = update['UserID'] ?? '';
                                          final email = update['Email'] ?? '';
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: _UpdateTile(
                                              title: 'New User Registered: $id',
                                              subtitle: email,
                                              status: update['AccountStatus'] ?? 'ACTIVE',
                                              statusColor: const Color(0xFFCBE8C7),
                                            ),
                                          );
                                        }).toList(),
                                      )
                                    : const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text('No latest updates.'),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFD7DDF4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(color: AppColors.mutedText, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': 'Admit Student',
        'icon': Icons.person_add_alt_1_outlined,
        'route': RouteNames.adminAdmitStudent,
      },
      {
        'title': 'Add Parent',
        'icon': Icons.family_restroom_outlined,
        'route': RouteNames.adminAddParent,
      },
      {
        'title': 'Add Teacher',
        'icon': Icons.school_outlined,
        'route': RouteNames.adminAddTeacher,
      },
      {
        'title': 'Manage People',
        'icon': Icons.groups_outlined,
        'route': RouteNames.adminShell,
      },
      {
        'title': 'Post Notice',
        'icon': Icons.campaign_outlined,
        'route': RouteNames.adminPostNotice,
      },
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push(item['route']! as String),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7DDF4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item['icon']! as IconData,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item['title']! as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AlertTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _AlertTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _innerBox(),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF5DE9B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.textBlack),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;

  const _UpdateTile({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _innerBox(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _StatusChip(text: status, color: statusColor),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textBlack,
        ),
      ),
    );
  }
}

BoxDecoration _box() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.borderBlue, width: 1.2),
    boxShadow: const [
      BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 4)),
    ],
  );
}

BoxDecoration _innerBox() {
  return BoxDecoration(
    color: const Color(0xFFF9F9F9),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.borderSoft),
  );
}
