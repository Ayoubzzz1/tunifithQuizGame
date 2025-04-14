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
    'Movies': Icons.movie_outlined,
    'Sports': Icons.sports_soccer_outlined,
    'Science': Icons.science_outlined,
    'History': Icons.history_edu_outlined,
    'Geography': Icons.public_outlined,
    'Music': Icons.music_note_outlined,
    'Art': Icons.palette_outlined,
    'Food': Icons.restaurant_outlined,
    'Technology': Icons.devices_outlined,
    'Literature': Icons.book_outlined,
  };
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCategoriesFromFirestore();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          // Use specific icon if available, otherwise default to category icon
          if (!_categoryIcons.containsKey(theme)) {
            _categoryIcons[theme] = Icons.category_outlined;
          }
        }

        // Check if all individual themes are selected
        final allSelected = _categories.entries
            .where((e) => e.key != 'Select All')
            .every((e) => e.value);
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
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Theme Questions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: theme.primaryColor,
          strokeWidth: 3,
        ),
      )
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor,
              theme.primaryColor.withOpacity(0.7),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 24,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    _buildHeaderIcon(theme),
                    const SizedBox(height: 20),
                    const Text(
                      'Select Question Categories',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose categories to include in your game',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Categories Grid
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Select All Option
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 20,
                          bottom: 8,
                        ),
                        child: _buildSelectAllToggle(theme),
                      ),

                      const Divider(height: 24),

                      // Grid of Category Toggles
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildCategoriesGrid(),
                        ),
                      ),

                      // Save Button
                      _buildSaveButton(theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(ThemeData theme) {
    return Hero(
      tag: 'theme_icon',
      child: Container(
        width: 90,
        height: 90,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.category,
            size: 45,
            color: theme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectAllToggle(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.select_all,
            color: theme.primaryColor,
            size: 26,
          ),
        ),
        title: const Text(
          'Select All Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Switch(
          value: _categories['Select All']!,
          onChanged: (value) => _toggleCategory('Select All', value),
          activeColor: theme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final categoriesList = _categories.entries
        .where((e) => e.key != 'Select All')
        .toList();

    return GridView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categoriesList.length,
      itemBuilder: (context, index) {
        final entry = categoriesList[index];
        final category = entry.key;
        final isSelected = entry.value;

        return _buildCategoryCard(
          category: category,
          isSelected: isSelected,
          icon: _categoryIcons[category] ?? Icons.category_outlined,
        );
      },
    );
  }

  Widget _buildCategoryCard({
    required String category,
    required bool isSelected,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _toggleCategory(category, !isSelected),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.15)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.primaryColor.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? theme.primaryColor : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? theme.primaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.primaryColor,
              Color.lerp(theme.primaryColor, Colors.black, 0.2)!,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            final selected = _categories.entries
                .where((e) => e.value && e.key != 'Select All')
                .map((e) => e.key)
                .toList();

            // If nothing is selected, default to 'Select All'
            final themesToSave = selected.isEmpty
                ? _categories.keys.where((key) => key != 'Select All').toList()
                : selected;

            // Save selected themes to our manager
            ThemeSelectionManager.updateSelectedThemes(themesToSave);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  selected.isEmpty
                      ? 'All themes will be included'
                      : '${selected.length} themes selected',
                  style: const TextStyle(fontSize: 16),
                ),
                backgroundColor: theme.primaryColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(12),
              ),
            );

            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.save_rounded, size: 24),
              SizedBox(width: 12),
              Text(
                'SAVE SELECTIONS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}