import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/timetable_models.dart';
import '../providers/providers.dart';
import '../widgets/color_picker.dart';

/// Add or edit a course: name, optional instructor/room, color.
class EditCourseScreen extends ConsumerStatefulWidget {
  final Course? existing;

  const EditCourseScreen({super.key, this.existing});

  @override
  ConsumerState<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends ConsumerState<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _instructor;
  late final TextEditingController _room;
  late int _color;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _name = TextEditingController(text: c?.name ?? '');
    _instructor = TextEditingController(text: c?.instructor ?? '');
    _room = TextEditingController(text: c?.room ?? '');
    _color = c?.color ?? CoursePalettePicker.palette.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _instructor.dispose();
    _room.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(timetableProvider.notifier);
    final instructor = _instructor.text.trim();
    final room = _room.text.trim();

    final course = (widget.existing ??
            Course(id: notifier.newId(), name: '', color: _color))
        .copyWith(
      name: _name.text.trim(),
      instructor: instructor.isEmpty ? null : instructor,
      room: room.isEmpty ? null : room,
      color: _color,
    );
    notifier.upsertCourse(course);
    Navigator.of(context).pop(course);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit course' : 'New course'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Course name',
                hintText: 'e.g. Calculus II',
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructor,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Instructor (optional)',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _room,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Room (optional)',
                prefixIcon: Icon(Icons.place_outlined),
              ),
            ),
            const SizedBox(height: 24),
            Text('Color', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            CoursePalettePicker(
              selectedColor: _color,
              onChanged: (v) => setState(() => _color = v),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(_isEditing ? 'Save changes' : 'Create course'),
            ),
          ],
        ),
      ),
    );
  }
}
