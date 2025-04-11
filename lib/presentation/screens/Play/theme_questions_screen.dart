import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_toggle.dart';
import 'theme_selection.dart';
class ThemeQuestionsScreen extends StatefulWidget {
  const ThemeQuestionsScreen({super.key});

  @override
  State<ThemeQuestionsScreen> createState() => _ThemeQuestionsScreenState();
}

class _ThemeQuestionsScreenState extends State<ThemeQuestionsScreen> {
  Map<String, bool> _categories = {'Select All': false};
  final Map<String, IconData> _categoryIcons = {
    'Select All': Icons.select_all,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategoriesFromFirestore();
  }

  Future<void> _loadCategoriesFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Quiz').get();
      final Set<String> fetchedThemes = {};

      for (var doc in snapshot.docs) {
        final themes = doc.data()['themes'] as List<dynamic>?;
        if (themes != null) {
          for (var themeData in themes) {
            final mainTheme = themeData['main_theme'];
            if (mainTheme is String) {
              fetchedThemes.add(mainTheme);
            }
          }
        }
      }

      final savedSelections = await ThemeSelectionManager.getSelectedThemes();

      setState(() {
        for (final theme in fetchedThemes) {
          _categories[theme] = savedSelections.contains(theme);
          _categoryIcons[theme] = Icons.category;
        }

        // Check if all individual themes are selected
        final allSelected = _categories.entries.every((e) => e.value);
        _categories['Select All'] = allSelected;

        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _toggleCategory(String category, bool value) {
    setState(() {
      if (category == 'Select All') {
        _categories.updateAll((key, _) => value);
      } else {
        _categories[category] = value;
        final allSelected = _categories.entries
            .where((e) => e.key != 'Select All')
            .every((e) => e.value);
        _categories['Select All'] = allSelected;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Theme Questions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Colors.white,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.question_mark,
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select Question Categories',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose which categories of questions to include in your game',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.separated(
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final category = _categories.keys.elementAt(index);
                      final isSelected = _categories[category]!;
                      return CategoryToggle(
                        category: category,
                        isSelected: isSelected,
                        icon: _categoryIcons[category] ?? Icons.category,
                        onToggle: (value) => _toggleCategory(category, value),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Updated save button in ThemeQuestionsScreen
// Inside ThemeQuestionsScreen's build method, replace the ElevatedButton with:

                ElevatedButton(
                  onPressed: () {
                    final selected = _categories.entries
                        .where((e) => e.value && e.key != 'Select All')
                        .map((e) => e.key)
                        .toList();

                    // If nothing is selected, default to 'Select All'
                    final themesToSave = selected.isEmpty ? ['Select All'] : selected;

                    // Save selected themes to our manager
                    ThemeSelectionManager.updateSelectedThemes(themesToSave);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          selected.isEmpty
                              ? 'All themes will be included'
                              : 'Selected themes: ${selected.join(", ")}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    );

                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: const Text(
                    'SAVE SELECTIONS',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
