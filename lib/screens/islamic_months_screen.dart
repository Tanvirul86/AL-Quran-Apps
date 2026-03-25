import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/islamic_month_models.dart';
import '../services/islamic_months_service.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';

class IslamicMonthsScreen extends StatelessWidget {
  const IslamicMonthsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final months = IslamicMonthsService.getIslamicMonths();

    return Scaffold(
      backgroundColor: AppTheme.forestBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.forestPrimary,
        elevation: 0,
        title: const Text(
          'Islamic Months',
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.forestBackground,
              AppTheme.forestSurface,
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: months.length,
          itemBuilder: (context, index) {
            final month = months[index];
            return _buildMonthCard(context, month);
          },
        ),
      ),
    );
  }

  Widget _buildMonthCard(BuildContext context, IslamicMonth month) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showMonthDetails(context, month),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppTheme.forestSurface,
                  AppTheme.primaryGreen.withOpacity(0.08),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryGreen,
                            AppTheme.darkGreen,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          month.number.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            month.nameAr,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkGreen,
                              fontFamily: Provider.of<SettingsProvider>(context, listen: false).arabicFontFamily,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${month.nameEn} • ${month.nameBn}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.primaryGreen.withOpacity(0.5),
                      size: 18,
                    ),
                  ],
                ),
                if (month.events.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentGold.withOpacity(0.15),
                          AppTheme.accentGold.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.accentGold.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.event_note,
                          size: 18,
                          color: Color(0xFFD4A843),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${month.events.length} Important Event${month.events.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFC09838),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMonthDetails(BuildContext context, IslamicMonth month) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Month Header
                      Center(
                        child: Column(
                          children: [
                            Text(
                              month.nameAr,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkGreen,
                                fontFamily: Provider.of<SettingsProvider>(context, listen: false).arabicFontFamily,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              month.nameEn,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              month.nameBn,
                              style: TextStyle(
                                fontSize: 18,
                                color: AppTheme.primaryGreen.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      _buildAuthenticityNote(),

                      const SizedBox(height: 18),

                      // Significance
                      _buildSectionTitle('Significance'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.forestSurface,
                              AppTheme.primaryGreen.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.primaryGreen.withOpacity(0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGreen.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              month.significance,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              month.significanceBn,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (month.events.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        _buildSectionTitle('Important Events'),
                        const SizedBox(height: 12),
                        ...month.events.map((event) => _buildEventCard(event)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 24,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryGreen,
                AppTheme.darkGreen,
              ],
            ),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGreen,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(ImportantEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                AppTheme.accentGold.withOpacity(0.06),
                AppTheme.accentGold.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: AppTheme.accentGold.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.accentGold,
                          Color(0xFFC09838),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentGold.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          event.isHighImportance ? Icons.star : Icons.calendar_today,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${event.day}${_getDaySuffix(event.day)} Day',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildEvidenceBadge(_resolveEvidenceTier(event)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                event.titleEn,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                event.titleBn,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                event.descriptionEn,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event.descriptionBn,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppTheme.primaryGreen.withOpacity(0.9),
                ),
              ),
              if (event.quranRef != null || event.hadithRef != null) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (event.quranRef != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'Qur\'an: ${event.quranRef}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    if (event.hadithRef != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'Hadith: ${event.hadithRef}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Widget _buildAuthenticityNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.25),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_outlined, size: 18, color: AppTheme.primaryGreen),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Authenticity note: Quran and Sahih Hadith references are strongest. Historical reports and scholarly notes are included with clear labels.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: Color(0xFF1B5E20),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceBadge(EvidenceTier tier) {
    late final Color bg;
    late final Color border;
    late final Color text;
    late final String label;

    switch (tier) {
      case EvidenceTier.quran:
        bg = Colors.green.withOpacity(0.14);
        border = Colors.green.withOpacity(0.36);
        text = const Color(0xFF1B5E20);
        label = 'Quran';
        break;
      case EvidenceTier.sahihHadith:
        bg = Colors.blue.withOpacity(0.12);
        border = Colors.blue.withOpacity(0.32);
        text = const Color(0xFF0D47A1);
        label = 'Sahih Hadith';
        break;
      case EvidenceTier.hasanHadith:
        bg = Colors.teal.withOpacity(0.12);
        border = Colors.teal.withOpacity(0.32);
        text = const Color(0xFF00695C);
        label = 'Hasan Hadith';
        break;
      case EvidenceTier.historical:
        bg = Colors.brown.withOpacity(0.10);
        border = Colors.brown.withOpacity(0.28);
        text = const Color(0xFF5D4037);
        label = 'Historical';
        break;
      case EvidenceTier.scholarly:
        bg = Colors.deepPurple.withOpacity(0.10);
        border = Colors.deepPurple.withOpacity(0.28);
        text = const Color(0xFF4527A0);
        label = 'Scholarly';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  EvidenceTier _resolveEvidenceTier(ImportantEvent event) {
    if (event.evidenceTier != EvidenceTier.historical) {
      return event.evidenceTier;
    }

    if (event.quranRef != null && event.quranRef!.trim().isNotEmpty) {
      return EvidenceTier.quran;
    }

    final hadith = (event.hadithRef ?? '').toLowerCase();
    if (hadith.contains('sahih')) {
      return EvidenceTier.sahihHadith;
    }
    if (hadith.contains('hasan')) {
      return EvidenceTier.hasanHadith;
    }
    if (hadith.contains('scholar') || hadith.contains('tahqiq')) {
      return EvidenceTier.scholarly;
    }
    if (hadith.contains('historical') || hadith.contains('sirah')) {
      return EvidenceTier.historical;
    }

    return EvidenceTier.historical;
  }
}
