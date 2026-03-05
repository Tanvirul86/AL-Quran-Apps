import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../models/bookmark_folder.dart';
import '../widgets/empty_state_widget.dart';

class BookmarkFoldersScreen extends StatefulWidget {
  const BookmarkFoldersScreen({super.key});

  @override
  State<BookmarkFoldersScreen> createState() => _BookmarkFoldersScreenState();
}

class _BookmarkFoldersScreenState extends State<BookmarkFoldersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookmarkProvider>(context, listen: false).loadFolders();
    });
  }

  void _showCreateFolderDialog([BookmarkFolder? editFolder]) {
    final nameController = TextEditingController(text: editFolder?.name ?? '');
    final descController = TextEditingController(text: editFolder?.description ?? '');
    Color selectedColor = editFolder != null
        ? Color(editFolder.colorValue)
        : Colors.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(editFolder == null ? 'Create Folder' : 'Edit Folder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Folder name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Folder Name',
                    hintText: 'e.g., Favorites',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                
                // Description
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'e.g., My favorite ayahs',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                // Color picker
                const Text(
                  'Folder Color',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.pink,
                    Colors.teal,
                    Colors.red,
                    Colors.indigo,
                  ].map((color) {
                    final isSelected = selectedColor.value == color.value;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a folder name')),
                  );
                  return;
                }

                final provider = Provider.of<BookmarkProvider>(context, listen: false);
                
                if (editFolder == null) {
                  // Create new folder
                  await provider.createFolder(
                    name: name,
                    description: descController.text.trim(),
                    colorValue: selectedColor.value,
                  );
                } else {
                  // Update existing folder
                  final updated = BookmarkFolder(
                    id: editFolder.id,
                    name: name,
                    description: descController.text.trim(),
                    colorValue: selectedColor.value,
                    createdAt: editFolder.createdAt,
                    updatedAt: DateTime.now(),
                  );
                  await provider.updateFolder(updated);
                }

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(editFolder == null
                          ? 'Folder created successfully'
                          : 'Folder updated successfully'),
                    ),
                  );
                }
              },
              child: Text(editFolder == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BookmarkFolder folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text('Are you sure you want to delete "${folder.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<BookmarkProvider>(context, listen: false)
                  .deleteFolder(folder.id!);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Folder deleted')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark Folders'),
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, provider, child) {
          final folders = provider.folders;

          if (folders.isEmpty) {
            return EmptyStates.noBookmarks(
              context,
              onAction: () => _showCreateFolderDialog(),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              final color = Color(folder.colorValue);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    // Navigate to folder details/bookmarks
                    // TODO: Implement folder bookmarks screen
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Color indicator
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.folder,
                            color: color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Folder info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                folder.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (folder.description?.isNotEmpty ?? false) ...[
                                const SizedBox(height: 4),
                                Text(
                                  folder.description!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        // Actions
                        PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showCreateFolderDialog(folder);
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(folder);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateFolderDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Folder'),
      ),
    );
  }
}
