import 'dart:io';

import 'package:evolution_cam/configs/supabase_config.dart';
import 'package:evolution_cam/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Coleções, imagens e categorias. Os mapas devolvidos mantêm as chaves que
/// os ecrãs já usavam (`titulo`, `categoria`, `imgs`, `updatedAt`...).
class CollectionService {
  CollectionService._();
  static final instance = CollectionService._();

  static const _signedUrlSeconds = 60 * 60;

  SupabaseClient get _client => Supabase.instance.client;
  StorageFileApi get _storage => _client.storage.from(SupabaseConfig.bucket);

  // Coleções ----------------------------------------------------------------

  /// Lista as coleções do utilizador, mais recentes primeiro.
  /// Cada item traz `imgCount` em vez da lista de imagens.
  Future<List<Map<String, dynamic>>> list() async {
    final rows = await _client
        .from('collections')
        .select('*, images(count)')
        .order('updated_at', ascending: false);
    return rows.map<Map<String, dynamic>>((row) {
      final counts = row['images'] as List?;
      final count = counts != null && counts.isNotEmpty
          ? (counts.first['count'] as int? ?? 0)
          : 0;
      return {..._mapCollection(row), 'imgCount': count};
    }).toList();
  }

  Future<int> count() async {
    final rows = await _client.from('collections').select('id');
    return rows.length;
  }

  /// Uma coleção com as imagens já com URL assinado, ou `null` se não existir.
  Future<Map<String, dynamic>?> get(String id) async {
    final row = await _client
        .from('collections')
        .select('*, images(*)')
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;

    final images = List<Map<String, dynamic>>.from(row['images'] as List)
      ..sort((a, b) {
        final byPosition =
            (a['position'] as int).compareTo(b['position'] as int);
        return byPosition != 0
            ? byPosition
            : (a['created_at'] as String).compareTo(b['created_at'] as String);
      });

    final urls = await _signedUrls(images.map((i) => i['path'] as String));
    return {
      ..._mapCollection(row),
      'imgs': images
          .map((i) => {
                'id': i['id'],
                'path': i['path'],
                'name': i['name'],
                'position': i['position'],
                'createdAt':
                    DateTime.parse(i['created_at'] as String).toLocal(),
                'url': urls[i['path']] ?? '',
              })
          .toList(),
    };
  }

  Future<void> create({required String title, required String category}) async {
    await _client
        .from('collections')
        .insert({'title': title, 'category': category});
  }

  Future<void> update(
    String id, {
    required String title,
    required String category,
  }) async {
    await _client.from('collections').update({
      'title': title,
      'category': category,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  /// Apaga a coleção e os ficheiros dela no Storage.
  Future<void> delete(String id) async {
    final images =
        await _client.from('images').select('path').eq('collection_id', id);
    final paths = images.map<String>((i) => i['path'] as String).toList();
    if (paths.isNotEmpty) await _storage.remove(paths);
    await _client.from('collections').delete().eq('id', id);
  }

  // Imagens -----------------------------------------------------------------

  Future<void> addImage(String collectionId, File file) async {
    final ext = _extension(file.path);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${AuthService.instance.userId}/$collectionId/$stamp.$ext';

    final last = await _client
        .from('images')
        .select('position')
        .eq('collection_id', collectionId)
        .order('position', ascending: false)
        .limit(1);
    final position = last.isEmpty ? 0 : (last.first['position'] as int) + 1;

    await _storage.uploadBinary(
      path,
      await file.readAsBytes(),
      fileOptions: FileOptions(contentType: _mimeType(ext), upsert: false),
    );
    try {
      await _client.from('images').insert({
        'collection_id': collectionId,
        'path': path,
        'name': '$stamp.$ext',
        'position': position,
      });
    } catch (_) {
      await _storage.remove([path]); // não deixar ficheiro órfão
      rethrow;
    }
  }

  Future<void> deleteImage(Map<String, dynamic> image) async {
    await _client.from('images').delete().eq('id', image['id']);
    try {
      await _storage.remove([image['path'] as String]);
    } catch (_) {
      // a linha já foi apagada; o ficheiro órfão não afeta a app
    }
  }

  // Categorias --------------------------------------------------------------

  Future<List<String>> categories() async {
    final row = await _client
        .from('profiles')
        .select('categories')
        .eq('id', AuthService.instance.userId)
        .maybeSingle();
    return List<String>.from(row?['categories'] as List? ?? const []);
  }

  Future<void> saveCategories(List<String> categories) async {
    await _client.from('profiles').update({'categories': categories}).eq(
        'id', AuthService.instance.userId);
  }

  // Auxiliares --------------------------------------------------------------

  Map<String, dynamic> _mapCollection(Map<String, dynamic> row) => {
        'id': row['id'],
        'titulo': row['title'],
        'categoria': row['category'],
        'createdAt': DateTime.parse(row['created_at'] as String).toLocal(),
        'updatedAt': DateTime.parse(row['updated_at'] as String).toLocal(),
        'imgs': <Map<String, dynamic>>[],
      };

  Future<Map<String, String>> _signedUrls(Iterable<String> paths) async {
    final list = paths.toList();
    if (list.isEmpty) return {};
    final signed =
        await _storage.createSignedUrlsResult(list, _signedUrlSeconds);
    return {
      for (final s in signed)
        if (s is SignedUrlSuccess) s.path: s.signedUrl,
    };
  }

  String _extension(String filePath) {
    final dot = filePath.lastIndexOf('.');
    final ext = dot == -1 ? '' : filePath.substring(dot + 1).toLowerCase();
    return const {'jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'}.contains(ext)
        ? ext
        : 'jpg';
  }

  String _mimeType(String ext) => switch (ext) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'heic' => 'image/heic',
        'heif' => 'image/heif',
        _ => 'image/jpeg',
      };
}
