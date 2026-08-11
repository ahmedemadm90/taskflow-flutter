import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.model.dart';
import '../providers/task_provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.loadTasks,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, provider)),
              SliverToBoxAdapter(child: _buildProgressCard(context, provider)),
              SliverToBoxAdapter(child: _buildSearchAndFilters(context, provider)),
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.visibleTasks.isEmpty)
                SliverFillRemaining(child: _EmptyState(onAdd: () => _openTaskSheet(context)))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                  sliver: SliverList.builder(
                    itemCount: provider.visibleTasks.length,
                    itemBuilder: (context, index) {
                      final task = provider.visibleTasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TaskCard(
                          task: task,
                          onToggle: () => provider.toggleTask(task.id),
                          onDelete: () => _confirmDelete(context, task),
                          onEdit: () => _openTaskSheet(context, task: task),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New task'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TaskProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF5157E8), Color(0xFF8E64F5)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good morning, Ahmed', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${provider.openCount} open tasks to focus on',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings are coming in the next release.')),
            ),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, TaskProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF22264A), Color(0xFF474CB4)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x2222264A), blurRadius: 18, offset: Offset(0, 10))],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            height: 82,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 82,
                  height: 82,
                  child: CircularProgressIndicator(
                    value: provider.completionRate,
                    strokeWidth: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                Text(
                  '${(provider.completionRate * 100).round()}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Today\'s focus', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 5),
                Text(
                  '${provider.completedCount} of ${provider.tasks.length} tasks complete',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const SizedBox(height: 5),
                const Text('Small progress compounds into meaningful results.', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, TaskProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: provider.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search tasks, tags, or notes',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        provider.setSearchQuery('');
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear_rounded),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              children: [
                _FilterChip(label: 'All', value: TaskFilter.all, provider: provider),
                _FilterChip(label: 'Open', value: TaskFilter.open, provider: provider),
                _FilterChip(label: 'Completed', value: TaskFilter.completed, provider: provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openTaskSheet(BuildContext context, {Task? task}) async {
    final result = await showModalBottomSheet<TaskFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => _TaskFormSheet(task: task),
    );
    if (!context.mounted || result == null) return;
    final provider = context.read<TaskProvider>();
    if (task == null) {
      await provider.addTask(
        title: result.title,
        description: result.description,
        dueDate: result.dueDate,
        priority: result.priority,
        tags: result.tags,
      );
    } else {
      await provider.updateTask(task.copyWith(
        title: result.title,
        description: result.description,
        dueDate: result.dueDate,
        priority: result.priority,
        tags: result.tags,
      ));
    }
  }

  Future<void> _confirmDelete(BuildContext context, Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('“${task.title}” will be removed from your list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
        ],
      ),
    );
    if (shouldDelete == true && context.mounted) {
      await context.read<TaskProvider>().deleteTask(task.id);
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.value, required this.provider});

  final String label;
  final TaskFilter value;
  final TaskProvider provider;

  @override
  Widget build(BuildContext context) {
    final selected = provider.filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => provider.setFilter(value),
      selectedColor: const Color(0xFFDCDFFF),
      labelStyle: TextStyle(color: selected ? const Color(0xFF373AB4) : Colors.black54, fontWeight: FontWeight.w600),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.onToggle, required this.onDelete, required this.onEdit});

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final priorityColor = switch (task.priority) {
      TaskPriority.high => const Color(0xFFE65C62),
      TaskPriority.medium => const Color(0xFFE39A33),
      TaskPriority.low => const Color(0xFF45A985),
    };
    final dueText = task.dueDate.difference(DateTime.now()).inDays <= 0 ? 'Due today' : 'Due in ${task.dueDate.difference(DateTime.now()).inDays} days';

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(value: task.isCompleted, onChanged: (_) => onToggle(), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
            const SizedBox(width: 4),
            Expanded(
              child: InkWell(
                onTap: onEdit,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, decoration: task.isCompleted ? TextDecoration.lineThrough : null, color: task.isCompleted ? Colors.black45 : Colors.black87)),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, height: 1.3)),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MetaTag(icon: Icons.schedule_rounded, label: dueText),
                        _MetaTag(icon: Icons.flag_rounded, label: task.priority.name, color: priorityColor),
                        ...task.tags.take(2).map((tag) => _MetaTag(icon: Icons.tag_rounded, label: tag)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  const _MetaTag({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.black54;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: effectiveColor.withValues(alpha: .10), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 13, color: effectiveColor), const SizedBox(width: 4), Text(label, style: TextStyle(fontSize: 11, color: effectiveColor, fontWeight: FontWeight.w600))]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.task_alt_rounded, size: 68, color: Color(0xFF9A9EEA)),
          const SizedBox(height: 16),
          Text('No tasks here', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Create a task or adjust your filters to keep moving forward.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 18),
          FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Create a task')),
        ]),
      ),
    );
  }
}

class TaskFormResult {
  const TaskFormResult({required this.title, required this.description, required this.dueDate, required this.priority, required this.tags});
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final List<String> tags;
}

class _TaskFormSheet extends StatefulWidget {
  const _TaskFormSheet({this.task});
  final Task? task;

  @override
  State<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<_TaskFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagsController;
  late DateTime _dueDate;
  late TaskPriority _priority;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _tagsController = TextEditingController(text: task?.tags.join(', ') ?? '');
    _dueDate = task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _priority = task?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.task == null ? 'Create task' : 'Edit task', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          TextField(controller: _titleController, autofocus: true, decoration: const InputDecoration(labelText: 'Title', hintText: 'What needs to be done?')),
          const SizedBox(height: 14),
          TextField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes', hintText: 'Add context or a definition of done')),
          const SizedBox(height: 14),
          TextField(controller: _tagsController, decoration: const InputDecoration(labelText: 'Tags', hintText: 'backend, client, urgent')),
          const SizedBox(height: 16),
          DropdownButtonFormField<TaskPriority>(
            initialValue: _priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: TaskPriority.values.map((priority) => DropdownMenuItem(value: priority, child: Text(priority.name.toUpperCase()))).toList(),
            onChanged: (value) => setState(() => _priority = value ?? TaskPriority.medium),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _selectDate,
            icon: const Icon(Icons.calendar_today_rounded),
            label: Text('Due ${_dueDate.day}/${_dueDate.month}/${_dueDate.year}'),
          ),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: _submit, child: Text(widget.task == null ? 'Create task' : 'Save changes'))),
        ]),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 3650)), initialDate: _dueDate);
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A task title is required.')));
      return;
    }
    Navigator.pop(context, TaskFormResult(title: title, description: _descriptionController.text, dueDate: _dueDate, priority: _priority, tags: _tagsController.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList()));
  }
}
