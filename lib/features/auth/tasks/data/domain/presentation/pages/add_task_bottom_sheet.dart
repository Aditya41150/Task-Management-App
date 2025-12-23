import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../entities/task.dart';
import '../../../models/task_model.dart';
import '../providers/task_provider.dart';

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  Priority _selectedPriority = Priority.low;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // FIX: Detect if we are in dark mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 25,
        right: 25,
        top: 25,
      ),
      decoration: BoxDecoration(
        // Use theme cardColor so it turns dark grey in dark mode
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create New Task",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              // FIX: Adaptive text color
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            autofocus: true,
            // FIX: Ensure typed text is visible
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: "What are you planning?",
              hintStyle:
                  TextStyle(color: isDark ? Colors.white54 : Colors.grey),
              filled: true,
              // FIX: Adaptive input background
              fillColor:
                  isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text("Priority Level",
              style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: Priority.values.map((p) {
              final isSelected = _selectedPriority == p;
              return GestureDetector(
                onTap: () => setState(() => _selectedPriority = p),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF7E72F2)
                        : (isDark ? Colors.white10 : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    p.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.grey.shade600),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  icon: const Icon(Icons.calendar_today,
                      size: 20, color: Color(0xFF7E72F2)),
                  label: Text(
                    DateFormat('MMM d, yyyy').format(_selectedDate),
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        isDark ? Colors.white10 : Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E72F2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Create Task",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) return;
    final newTask = TaskModel(
      id: '',
      title: _titleController.text.trim(),
      dueDate: _selectedDate,
      priority: _selectedPriority,
      isCompleted: false,
    );
    ref.read(taskRepositoryProvider).addTask(newTask);
    Navigator.pop(context);
  }
}
