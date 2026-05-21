import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skill_swap/config/app_config.dart';
import 'package:skill_swap/core/constants/app_constants.dart';
import 'package:skill_swap/core/extensions/context_extensions.dart';
import 'package:skill_swap/providers/profile_provider.dart';
import 'package:skill_swap/widgets/common/app_text_field.dart';
import 'package:skill_swap/widgets/common/gradient_button.dart';
import 'package:skill_swap/widgets/common/skill_chip.dart';

/// Edit profile: photo, bio, skills, experience level.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  final _skillTeachController = TextEditingController();
  final _skillLearnController = TextEditingController();
  String _experienceLevel = 'Intermediate';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(profileEditProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _experienceLevel = user?.experienceLevel ?? 'Intermediate';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _skillTeachController.dispose();
    _skillLearnController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xfile == null) return;
    if (AppConfig.useDemoMode) {
      if (mounted) context.showSnack('Photo updated (demo mode)');
      return;
    }
    await ref.read(profileEditProvider.notifier).uploadPhoto(File(xfile.path));
    if (mounted) context.showSnack('Photo uploaded');
  }

  void _addSkillTeach() {
    final skill = _skillTeachController.text.trim();
    if (skill.isEmpty) return;
    final user = ref.read(profileEditProvider);
    if (user == null) return;
    ref.read(profileEditProvider.notifier).updateLocal(
          user.copyWith(skillsTeach: [...user.skillsTeach, skill]),
        );
    _skillTeachController.clear();
    setState(() {});
  }

  void _addSkillLearn() {
    final skill = _skillLearnController.text.trim();
    if (skill.isEmpty) return;
    final user = ref.read(profileEditProvider);
    if (user == null) return;
    ref.read(profileEditProvider.notifier).updateLocal(
          user.copyWith(skillsLearn: [...user.skillsLearn, skill]),
        );
    _skillLearnController.clear();
    setState(() {});
  }

  Future<void> _save() async {
    final user = ref.read(profileEditProvider);
    if (user == null) return;
    setState(() => _saving = true);
    ref.read(profileEditProvider.notifier).updateLocal(
          user.copyWith(
            name: _nameController.text.trim(),
            bio: _bioController.text.trim(),
            experienceLevel: _experienceLevel,
          ),
        );
    await ref.read(profileEditProvider.notifier).save();
    setState(() => _saving = false);
    if (mounted) {
      context.showSnack('Profile saved');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(profileEditProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0] : '?',
                            style: const TextStyle(fontSize: 36),
                          ),
                        ),
                        const Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 16,
                            child: Icon(Icons.camera_alt, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    controller: _nameController,
                    label: 'Name',
                    prefixIcon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _bioController,
                    label: 'Bio',
                    maxLines: 3,
                    prefixIcon: Icons.info_outline,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _experienceLevel,
                    decoration:
                        const InputDecoration(labelText: 'Experience Level'),
                    items: AppConstants.experienceLevels
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _experienceLevel = v!),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Skills I Teach',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: user.skillsTeach
                        .map(
                          (s) => SkillChip(
                            label: s,
                            onDeleted: () {
                              ref
                                  .read(profileEditProvider.notifier)
                                  .updateLocal(
                                    user.copyWith(
                                      skillsTeach: user.skillsTeach
                                          .where((x) => x != s)
                                          .toList(),
                                    ),
                                  );
                              setState(() {});
                            },
                          ),
                        )
                        .toList(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _skillTeachController,
                          decoration:
                              const InputDecoration(hintText: 'Add skill'),
                        ),
                      ),
                      IconButton(
                        onPressed: _addSkillTeach,
                        icon: const Icon(Icons.add_circle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Skills I Want to Learn',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: user.skillsLearn
                        .map(
                          (s) => SkillChip(
                            label: s,
                            isTeach: false,
                            onDeleted: () {
                              ref
                                  .read(profileEditProvider.notifier)
                                  .updateLocal(
                                    user.copyWith(
                                      skillsLearn: user.skillsLearn
                                          .where((x) => x != s)
                                          .toList(),
                                    ),
                                  );
                              setState(() {});
                            },
                          ),
                        )
                        .toList(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _skillLearnController,
                          decoration:
                              const InputDecoration(hintText: 'Add skill'),
                        ),
                      ),
                      IconButton(
                        onPressed: _addSkillLearn,
                        icon: const Icon(Icons.add_circle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  GradientButton(
                    label: 'Save Profile',
                    isLoading: _saving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }
}
