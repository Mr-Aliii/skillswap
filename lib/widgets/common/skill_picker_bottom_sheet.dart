import 'package:flutter/material.dart';
import 'package:skill_swap/core/constants/app_constants.dart';
import 'package:skill_swap/theme/app_colors.dart';

/// Bottom sheet that shows predefined skills grouped by category.
/// User can search, browse, and select up to [maxSelections] skills.
class SkillPickerBottomSheet extends StatefulWidget {
  const SkillPickerBottomSheet({
    super.key,
    required this.alreadySelected,
    this.maxSelections = AppConstants.maxSkillsPerCategory,
    this.isTeach = true,
  });

  /// Skills the user has already selected (pre-checked).
  final List<String> alreadySelected;
  final int maxSelections;
  final bool isTeach;

  /// Show the picker and return the final list of selected skills.
  static Future<List<String>> show(
    BuildContext context, {
    required List<String> alreadySelected,
    int maxSelections = AppConstants.maxSkillsPerCategory,
    bool isTeach = true,
  }) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SkillPickerBottomSheet(
        alreadySelected: alreadySelected,
        maxSelections: maxSelections,
        isTeach: isTeach,
      ),
    ).then((v) => v ?? alreadySelected);
  }

  @override
  State<SkillPickerBottomSheet> createState() => _SkillPickerBottomSheetState();
}

class _SkillPickerBottomSheetState extends State<SkillPickerBottomSheet> {
  late List<String> _selected;
  String _searchQuery = '';
  String _activeCategory = 'All';

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.alreadySelected);
  }

  List<String> get _filteredCategories {
    if (_searchQuery.isNotEmpty) {
      // Only show categories that have matching skills
      return AppConstants.predefinedSkills.entries
          .where((entry) => entry.value
              .any((s) => s.toLowerCase().contains(_searchQuery.toLowerCase())))
          .map((e) => e.key)
          .toList();
    }
    if (_activeCategory == 'All') {
      return AppConstants.skillCategories;
    }
    return [_activeCategory];
  }

  List<String> _skillsForCategory(String category) {
    final skills = AppConstants.predefinedSkills[category] ?? [];
    if (_searchQuery.isEmpty) return skills;
    return skills
        .where((s) => s.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (_selected.contains(skill)) {
        _selected.remove(skill);
      } else {
        if (_selected.length >= widget.maxSelections) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You can select up to ${widget.maxSelections} skills',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        _selected.add(skill);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.isTeach ? AppColors.primary : AppColors.accent;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    widget.isTeach
                        ? 'Select Skills You Teach'
                        : 'Select Skills You Want to Learn',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_selected.length}/${widget.maxSelections}',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Search skills...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () =>
                              setState(() => _searchQuery = ''),
                        )
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            const SizedBox(height: 12),
            // Category chips
            if (_searchQuery.isEmpty)
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _CategoryChip(
                      label: 'All',
                      selected: _activeCategory == 'All',
                      color: accentColor,
                      onTap: () =>
                          setState(() => _activeCategory = 'All'),
                    ),
                    ...AppConstants.skillCategories.map(
                      (c) => _CategoryChip(
                        label: c,
                        selected: _activeCategory == c,
                        color: accentColor,
                        onTap: () =>
                            setState(() => _activeCategory = c),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            // Skills grid
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: _filteredCategories.map((category) {
                  final skills = _skillsForCategory(category);
                  if (skills.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 8),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: accentColor,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: skills.map((skill) {
                          final isSelected = _selected.contains(skill);
                          return _SkillOptionChip(
                            label: skill,
                            selected: isSelected,
                            color: accentColor,
                            onTap: () => _toggleSkill(skill),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            // Done button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _selected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SkillOptionChip extends StatelessWidget {
  const _SkillOptionChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.grey.shade400,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.check_circle, size: 16, color: Colors.white),
              ),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey.shade700,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
