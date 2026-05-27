import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/settings/repositories/backup_repository.dart';
import 'package:smarterp/modules/settings/repositories/notification_repository.dart';
import 'package:smarterp/modules/settings/services/preferences_service.dart';

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String type;
  final String? actionRoute;
  final dynamic source;

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.actionRoute,
    this.source,
  });
}

class SettingsSearchService {
  final NotificationRepository _notificationRepository;
  final BackupRepository _backupRepository;
  final PreferencesService _preferencesService;

  SettingsSearchService({
    required NotificationRepository notificationRepository,
    required BackupRepository backupRepository,
    required PreferencesService preferencesService,
  })  : _notificationRepository = notificationRepository,
        _backupRepository = backupRepository,
        _preferencesService = preferencesService;

  Future<List<SearchResult>> searchAll(String query) async {
    if (query.trim().isEmpty) return [];

    final q = query.toLowerCase().trim();
    final results = <SearchResult>[];

    final futures = await Future.wait([
      _searchNotifications(q),
      _searchBackups(q),
      _searchPreferences(q),
    ]);

    for (final r in futures) {
      results.addAll(r);
    }

    results.sort((a, b) => a.title.compareTo(b.title));
    Logger.debug('Search "$query" returned ${results.length} results');
    return results;
  }

  Future<List<SearchResult>> searchByType(String query, String type) async {
    if (query.trim().isEmpty) return [];

    final q = query.toLowerCase().trim();
    switch (type) {
      case 'notifications':
        return _searchNotifications(q);
      case 'backups':
        return _searchBackups(q);
      case 'preferences':
        return _searchPreferences(q);
      default:
        return [];
    }
  }

  Future<List<SearchResult>> _searchNotifications(String q) async {
    try {
      final all = await _notificationRepository.getAll();
      final results = <SearchResult>[];

      for (final n in all) {
        if (n.title.toLowerCase().contains(q) ||
            n.message.toLowerCase().contains(q) ||
            n.category.name.toLowerCase().contains(q)) {
          results.add(SearchResult(
            id: n.id,
            title: n.title,
            subtitle: n.message,
            type: 'notification',
            actionRoute: '/settings/notifications',
            source: n,
          ));
        }
      }
      return results;
    } catch (e) {
      return [];
    }
  }

  Future<List<SearchResult>> _searchBackups(String q) async {
    try {
      final all = await _backupRepository.getAll();
      final results = <SearchResult>[];

      for (final b in all) {
        if (b.name.toLowerCase().contains(q) ||
            b.description.toLowerCase().contains(q) ||
            b.type.name.toLowerCase().contains(q) ||
            b.status.name.toLowerCase().contains(q)) {
          results.add(SearchResult(
            id: b.id,
            title: b.name,
            subtitle: '${b.type.name} • ${b.formattedSize} • ${b.statusLabel}',
            type: 'backup',
            source: b,
          ));
        }
      }
      return results;
    } catch (e) {
      return [];
    }
  }

  Future<List<SearchResult>> _searchPreferences(String q) async {
    try {
      final results = <SearchResult>[];
      final prefs = await _preferencesService.getPreferences();
      final favorites = prefs.favoriteModules;

      for (final fav in favorites) {
        if (fav.toLowerCase().contains(q)) {
          results.add(SearchResult(
            id: fav,
            title: fav,
            subtitle: 'Favorite',
            type: 'preference',
            source: fav,
          ));
        }
      }
      return results;
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.trim().isEmpty) return [];

    final q = query.toLowerCase().trim();
    final suggestions = <String>{
      'notifications',
      'backups',
      'preferences',
      'settings',
    };

    final notifications = await _notificationRepository.getRecent(5);
    for (final n in notifications) {
      if (n.title.toLowerCase().contains(q)) {
        suggestions.add(n.title);
      }
    }

    final backups = await _backupRepository.getRecent(5);
    for (final b in backups) {
      if (b.name.toLowerCase().contains(q)) {
        suggestions.add(b.name);
      }
    }

    return suggestions.where((s) => s.toLowerCase().contains(q)).take(8).toList();
  }
}
