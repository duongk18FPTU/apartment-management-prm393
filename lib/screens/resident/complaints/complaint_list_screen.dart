import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/complaint_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/complaint_status_chip.dart';
import '../../../widgets/loading_indicator.dart';

/// Resident — list of their complaints / feedback.
class ComplaintListScreen extends StatefulWidget {
  const ComplaintListScreen({super.key});

  @override
  State<ComplaintListScreen> createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final uid = context.read<AuthProvider>().userModel?.uid;
    if (uid == null) return;
    await context.read<ComplaintProvider>().loadResidentComplaints(uid);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComplaintProvider>();
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: const Text('Khiếu nại / Góp ý')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.complaintCreate),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Gửi mới'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: DesignTokens.secondary,
        child: provider.isLoading && provider.complaints.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  LoadingIndicator.circular(),
                ],
              )
            : provider.errorMessage != null && provider.complaints.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  const SizedBox(height: 80),
                  Text(provider.errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: ElevatedButton(
                      onPressed: _load,
                      child: const Text('Thử lại'),
                    ),
                  ),
                ],
              )
            : provider.complaints.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 100),
                  Icon(
                    Icons.feedback_outlined,
                    size: 56,
                    color: DesignTokens.neutralVariant,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Chưa có khiếu nại nào',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  88,
                ),
                itemCount: provider.complaints.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final item = provider.complaints[index];
                  return Material(
                    color: DesignTokens.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      onTap: () => context.push(
                        AppRoutes.complaintDetail.replaceFirst(':id', item.id),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                                ComplaintStatusChip(status: item.status),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              dateFmt.format(item.createdAt),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: DesignTokens.neutralVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
