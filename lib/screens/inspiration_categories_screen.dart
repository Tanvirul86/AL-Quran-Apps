import 'package:flutter/material.dart';
import '../models/inspiration_models.dart';
import '../services/inspiration_service.dart';
import '../theme/app_theme.dart';
import 'inspiration_content_screen.dart';

class InspirationCategoriesScreen extends StatefulWidget {
  const InspirationCategoriesScreen({super.key});

  @override
  State<InspirationCategoriesScreen> createState() => _InspirationCategoriesScreenState();
}

class _InspirationCategoriesScreenState extends State<InspirationCategoriesScreen> {
  final List<InspirationCategory> categories = InspirationService.getCategories();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.forestBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.forestPrimary,
        elevation: 0,
        title: const Text(
          'Islamic Inspiration',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.forestBackground,
              AppTheme.forestSurface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(category);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(InspirationCategory category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InspirationContentScreen(
              category: category,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.islamicGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppTheme.elevatedShadow],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category.iconPath,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 8),
              
              // Category name
              Flexible(
                child: Text(
                  category.nameEn,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Content count
              Text(
                '${category.contents.length} ${category.contents.length == 1 ? 'item' : 'items'}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}