import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'beat_analysis.dart';
import 'json_file_store.dart';
import 'local_download_manager.dart';
import 'local_library_repository.dart';
import 'youtube_gateway.dart';

/// Everything the app keeps on this device, opened once at startup.
class LocalServices {
  LocalServices._(
    this.gateway,
    this.library,
    this.downloads,
    this.beats,
    this.root,
  );

  final YoutubeGateway gateway;
  final LocalLibraryRepository library;
  final LocalDownloadManager downloads;
  final BeatAnalysis beats;
  final Directory root;

  static Future<LocalServices> open() async {
    final root = Directory(
      '${(await getApplicationSupportDirectory()).path}/ongaku',
    );
    await root.create(recursive: true);
    final gateway = YoutubeGateway();
    final library =
        await LocalLibraryRepository.open(
            JsonFileStore(File('${root.path}/library.json')),
          )
          ..compact();
    final downloads = await LocalDownloadManager.open(
      gateway,
      JsonFileStore(File('${root.path}/downloads.json')),
      Directory('${root.path}/downloads'),
    );
    final beats = BeatAnalysis(
      gateway,
      Directory('${root.path}/beats'),
      localFile: downloads.fileFor,
    );
    return LocalServices._(gateway, library, downloads, beats, root);
  }
}
