import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/core/constants/premium_plans.dart';
import 'package:skill_swap/core/extensions/context_extensions.dart';
import 'package:skill_swap/models/premium_plan_model.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/providers/premium_provider.dart';
import 'package:skill_swap/theme/app_colors.dart';
import 'package:skill_swap/widgets/common/gradient_button.dart';
import 'package:skill_swap/widgets/premium/premium_badge_chip.dart';
import 'package:skill_swap/widgets/premium/verified_badge.dart';

/// Premium badge purchase — weekly, monthly, yearly plans.
class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  static const _benefits = [
    (Icons.verified, 'Verified badge on your profile'),
    (Icons.push_pin, 'Profile pinned at the top in Discover'),
    (Icons.visibility, 'Stand out in search & recommendations'),
    (Icons.star, 'Premium member badge on cards'),
    (Icons.bolt, 'Priority visibility to skill swappers'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedPremiumPlanProvider);
    final purchaseState = ref.watch(premiumPurchaseProvider);
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;
    final isPremium = profile?.showVerifiedBadge ?? false;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFB45309)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 48),
                    Icon(Icons.workspace_premium, size: 56, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'SkillSwap Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Get verified & reach the top',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isPremium) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Row(
                        children: [
                          const VerifiedBadge(size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'You are Premium!',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Plan: ${profile!.premiumPlan ?? 'active'} • '
                                  'Expires: ${_formatDate(profile.premiumExpiresAt)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PremiumBadgeChip(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text(
                    'Premium Benefits',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._benefits.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(b.$1, color: const Color(0xFFD97706), size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Text(b.$2)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose Your Plan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...PremiumPlans.plans.map(
                    (plan) => _PlanCard(
                      plan: plan,
                      selected: selected == plan.type,
                      onTap: () => ref
                          .read(selectedPremiumPlanProvider.notifier)
                          .state = plan.type,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: isPremium ? 'Extend Premium' : 'Get Premium Badge',
                    icon: Icons.workspace_premium,
                    isLoading: purchaseState.isLoading,
                    onPressed: purchaseState.isLoading
                        ? null
                        : () => _purchase(context, ref, selected),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Payment integration coming soon. MVP simulates purchase & updates your profile.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: context.theme.hintColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _purchase(
    BuildContext context,
    WidgetRef ref,
    PremiumPlanType plan,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final p = PremiumPlans.planFor(plan);
        return AlertDialog(
          title: const Text('Confirm Purchase'),
          content: Text(
            'Buy Premium Badge (${p.title}) for ${p.price}?\n\n'
            'You will get a verified icon and top profile visibility.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Buy Now'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !context.mounted) return;

    try {
      await ref.read(premiumPurchaseProvider.notifier).purchase(plan);
      if (context.mounted) {
        context.showSnack('Premium activated! Verified badge is live.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        context.showSnack('Purchase failed: $e', isError: true);
      }
    }
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final PremiumPlanModel plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFF59E0B) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? const Color(0xFFF59E0B).withValues(alpha: 0.08)
              : Theme.of(context).cardTheme.color,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? const Color(0xFFD97706) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (plan.isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'POPULAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      if (plan.saveLabel != null && !plan.isPopular) ...[
                        const SizedBox(width: 8),
                        Text(
                          plan.saveLabel!,
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    plan.pricePerWeek,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              plan.price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFFD97706),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
