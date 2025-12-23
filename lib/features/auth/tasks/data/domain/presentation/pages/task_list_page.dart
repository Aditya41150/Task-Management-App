import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../../../main.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import 'add_task_bottom_sheet.dart';

class TaskListPage extends ConsumerWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(filteredTasksProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // HEADER SECTION
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(top: 50, bottom: 25, left: 20, right: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF7E72F2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.grid_view_rounded,
                        color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          onChanged: (val) =>
                              ref.read(searchProvider.notifier).state = val,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: "Search tasks...",
                            hintStyle: TextStyle(color: Colors.white70),
                            prefixIcon: Icon(Icons.search,
                                color: Colors.white70, size: 18),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                        themeMode == ThemeMode.dark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        ref.read(themeNotifierProvider.notifier).state =
                            themeMode == ThemeMode.dark
                                ? ThemeMode.light
                                : ThemeMode.dark;
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () => FirebaseAuth.instance.signOut(),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                  DateFormat('EEEE, d MMMM').format(DateTime.now()),
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 14),
                ),
                const Text(
                  "My Tasks",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // TASK LIST SECTIONS OR EMPTY STATE
          Expanded(
            child: tasks.isEmpty
                ? _buildEmptyState(isDark)
                : ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    children: [
                      _buildSection("Today", _getTasksFor(tasks, 0), isDark),
                      _buildSection("Tomorrow", _getTasksFor(tasks, 1), isDark),
                      _buildSection(
                          "Later this week", _getTasksFor(tasks, 2), isDark),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7E72F2),
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () => _showAddTaskSheet(context),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off_rounded,
            size: 100, color: isDark ? Colors.white10 : Colors.grey.shade200),
        const SizedBox(height: 20),
        Text(
          "No tasks found",
          style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        const Text(
          "Try a different search term",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskBottomSheet(),
    );
  }

  Widget _buildSection(String title, List tasks, bool isDark) {
    if (tasks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87),
          ),
        ),
        ...tasks.map((t) => TaskTile(task: t)),
        const SizedBox(height: 10),
      ],
    );
  }

  List _getTasksFor(List tasks, int offset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = today.add(Duration(days: offset));

    return tasks.where((t) {
      final tDate = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      if (offset < 2) return tDate.isAtSameMomentAs(targetDate);
      return tDate.isAfter(today.add(const Duration(days: 1)));
    }).toList();
  }
}
