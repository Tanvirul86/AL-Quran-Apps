import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/enhanced_reciter_service.dart';
import '../models/reciter.dart';

/// Reciter Selector - Choose from 15 world-renowned reciters for streaming
class ReciterSelectorScreen extends StatefulWidget {
  const ReciterSelectorScreen({super.key});

  @override
  State<ReciterSelectorScreen> createState() => _ReciterSelectorScreenState();
}

class _ReciterSelectorScreenState extends State<ReciterSelectorScreen> {
  late EnhancedReciterService _reciterService;
  String _selectedReciterId = '';

  static const List<String> _supportedAyahReciters = [
    'mishary_alafasy',
    'abdul_basit_murattal',
    'mahmoud_hussary',
    'saad_alghamdi',
    'abdurrahman_sudais',
  ];

  @override
  void initState() {
    super.initState();
    _reciterService = EnhancedReciterService();
    _loadSavedReciter();
  }

  Future<void> _loadSavedReciter() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('selected_reciter_id') ?? 'mishary_alafasy';
    final normalized = _supportedAyahReciters.contains(saved)
        ? saved
        : 'mishary_alafasy';

    if (normalized != saved) {
      await prefs.setString('selected_reciter_id', normalized);
    }

    if (mounted) {
      setState(() {
        _selectedReciterId = normalized;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Reciter'),
        elevation: 0,
      ),
      body: FutureBuilder<List<Reciter>>(
        future: _reciterService.getAllReciters(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reciters = snapshot.data!
              .where((r) => _supportedAyahReciters.contains(r.id))
              .toList();

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: const Text(
                  'These reciters are verified for ayah-by-ayah playback in this screen.',
                  style: TextStyle(fontSize: 12.5, color: Colors.blueGrey),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reciters.length,
                  itemBuilder: (context, index) {
                    final reciter = reciters[index];
                    return _buildReciterCard(reciter);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReciterCard(Reciter reciter) {
    final isSelected = _selectedReciterId == reciter.id;

    return Card(
      elevation: isSelected ? 8 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.green : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _selectReciter(reciter),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Reciter Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: reciter.imageUrl != null
                        ? NetworkImage(reciter.imageUrl!)
                        : null,
                    child: reciter.imageUrl == null
                        ? Text(
                            reciter.name[0],
                            style: const TextStyle(fontSize: 24),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),

                  // Name and Country
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reciter.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.flag, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(reciter.country ?? 'Unknown'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Selected Check
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.green, size: 32),
                ],
              ),

              // Bio
              if (reciter.bio != null) ...[
                const SizedBox(height: 12),
                Text(
                  reciter.bio!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Recitation Style Chips
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(reciter.style.toUpperCase()),
                    labelStyle: const TextStyle(fontSize: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  if (isSelected)
                    const Chip(
                      label: Text('Selected'),
                      labelStyle: TextStyle(fontSize: 12, color: Colors.white),
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Info message
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '✓ Audio streams online while playing',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectReciter(Reciter reciter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_reciter_id', reciter.id);
    
    setState(() {
      _selectedReciterId = reciter.id;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${reciter.name} selected'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Auto-close after selection
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}

