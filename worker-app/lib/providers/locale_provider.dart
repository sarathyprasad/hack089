import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/localization/app_localizations.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  String get currentLanguageCode => _locale.languageCode;

  String get currentLanguageName {
    final match = AppLocalizations.supportedLanguages.firstWhere(
      (l) => l['code'] == _locale.languageCode,
      orElse: () => {'code': 'en', 'name': 'English', 'native': 'English'},
    );
    return match['native'] ?? match['name'] ?? 'English';
  }

  LocaleProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString('app_locale');
      if (savedCode != null && savedCode.isNotEmpty) {
        _locale = Locale(savedCode);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLocale(String languageCode) async {
    final code = languageCode.toLowerCase();
    _locale = Locale(code);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_locale', code);
    } catch (_) {}
  }
}

void showLanguageDialog(BuildContext context) {
  final currentLocale = Localizations.localeOf(context).languageCode;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.translate_rounded, color: Color(0xFF0284C7), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Choose Language / ଭାଷା ବାଛନ୍ତୁ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Select your preferred native language',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: AppLocalizations.supportedLanguages.length,
                  itemBuilder: (context, index) {
                    final item = AppLocalizations.supportedLanguages[index];
                    final code = item['code']!;
                    final isSelected = code == currentLocale;

                    return ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: isSelected ? const Color(0xFFE0F2FE) : null,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                        child: Text(
                          code.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      title: Text(
                        item['native'] ?? item['name']!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? const Color(0xFF0369A1) : const Color(0xFF1E293B),
                        ),
                      ),
                      subtitle: Text(
                        item['name']!,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0284C7), size: 20)
                          : null,
                      onTap: () {
                        final provider = Provider.of<LocaleProvider>(context, listen: false);
                        provider.setLocale(code);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
