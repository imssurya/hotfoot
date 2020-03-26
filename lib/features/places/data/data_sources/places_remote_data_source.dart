import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hotfoot/features/places/data/models/place_model.dart';

//import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:path/path.dart';

abstract class IPlacesRemoteDataSource {
  Future<List<String>> getPlacesIds();

  Future<PlaceModel> getPlaceById({@required String id});

  Future<File> getPhoto({@required String id});
}

class PlacesRemoteDataSource implements IPlacesRemoteDataSource {
  static const String _TEMP_PHOTOS_DIR = 'photos';
  final String _tempPhotosDir;
  final Firestore firestore;
  final FirebaseStorage firebaseStorage;

//  final http.Client httpClient;
  final CollectionReference _placesCollection;
  final DefaultCacheManager cacheManager;

  PlacesRemoteDataSource({
    @required this.firestore,
    @required this.firebaseStorage,
//    @required this.httpClient,
    @required Directory tempPhotosDir,
    @required this.cacheManager,
  })  : assert(firestore != null),
        assert(firebaseStorage != null),
//        assert(httpClient != null),
        assert(tempPhotosDir != null),
        assert(cacheManager != null),
        this._placesCollection = firestore.collection('places'),
        this._tempPhotosDir = join(tempPhotosDir.path, _TEMP_PHOTOS_DIR);

  @override
  Future<PlaceModel> getPlaceById({String id}) async {
    final placeJson = (await _placesCollection.document(id).get()).data;
    return PlaceModel.fromJson(placeJson);
  }

  @override
  Future<List<String>> getPlacesIds() async {
    print('Getting place ids from firestore');
    final QuerySnapshot placesSnapshot = await _placesCollection.getDocuments();
    List<String> placesIds = List<String>();

    placesSnapshot.documents.forEach((document) {
      placesIds.add(document.documentID);
    });

    print('got place ids from firestore');
    print('Number of places ${placesIds.length}');

    return placesIds;
  }

  @override
  Future<File> getPhoto({String id}) async {
//    final fileInfo = await cacheManager.downloadFile(url);
//    return fileInfo.file;
    StorageReference ref = firebaseStorage.ref().child('photos').child(id);
    print('Storage Ref: ${ref.path}');
//    final String photoUrl = await storageReference.getDownloadURL();
//    final http.Response downloadPhotoData = await http.get(photoUrl);
    final File tempPhotoFile = File('$_tempPhotosDir/temp$id.png');
    if (tempPhotoFile.existsSync()) {
      await tempPhotoFile.delete();
    }
    await tempPhotoFile.create(recursive: true);
    final StorageFileDownloadTask downloadTask = ref.writeToFile(tempPhotoFile);
    int downloadedBytes = (await downloadTask.future).totalByteCount;

    if (downloadedBytes == 0) {
      print('NOTHING DONWLOADED');
    }

    return tempPhotoFile;
  }
}
