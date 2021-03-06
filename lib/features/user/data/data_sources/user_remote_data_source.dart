import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hotfoot/features/user/data/models/user_model.dart';
import 'package:hotfoot/features/user/domain/entities/user_entity.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:hotfoot/core/util/util.dart';

abstract class IUserRemoteDataSource {
  Future<UserModel> getUserFromFirebase();

  Future<String> getUserId();

  Future<UserModel> getUserInfo();

  Future<UserModel> insertOrUpdateUser({@required UserModel userModel});

  Future<UserModel> getUserInfoById({@required String userId});

  Future<File> insertOrUpdateUserPhoto({@required File userPhotoFile});

  Future<File> getUserPhoto([String userId]);

  Future<UserModel> insertOrUpdateUserById(
      {@required String userId, @required UserModel userModel});
}

class UserRemoteDataSource implements IUserRemoteDataSource {
  static const String _TEMP_PHOTOS_DIR = 'user_photos';

  final String _photosDir;
  final Firestore firestore;
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage firebaseStorage;

  UserRemoteDataSource({
    @required this.firestore,
    @required this.firebaseAuth,
    @required this.firebaseStorage,
    @required Directory tempPhotosDir,
  })  : assert(firestore != null),
        assert(firebaseAuth != null),
        assert(firebaseStorage != null),
        this._photosDir = join(tempPhotosDir.path, _TEMP_PHOTOS_DIR);
  
  @override
  Future<UserModel> getUserFromFirebase() async {

    final firebaseUser = await firebaseAuth.currentUser();
    UserModel userModel = UserModel(
      email: firebaseUser.email,
      id: firebaseUser.uid,
      name: HotfootUtil.parseBisonEmail(firebaseUser.email),
      // Initialize the user to be a customer
      type: UserType.CUSTOMER,
      isEmailVerified: firebaseUser.isEmailVerified,
      photoUrl: null,
      funds: 0,
    );
    return userModel;
  }

  @override
  Future<UserModel> getUserInfo() async {
    final user = await (firebaseAuth.currentUser());
    final userId = user.uid;
    UserModel userModel = await getUserInfoById(userId: userId);
    // TODO: (ruel gordon) This should only be called once preferably in the same listener that will do the auto login after verification
    // When a user first logs in firestore will say email verified is false
    // it does not break naything right now but I just want to keep the information
    // cleaan and true for clarity, if there is a better place you would like this updated
    // you can do so or let me know, just trying to progress and finish other features now
    if (userModel.isEmailVerified == false) {
      await firestore
          .collection('users')
          .document(userId)
          .setData(userModel.copyWith(isEmailVerified: true).toJson());

      return userModel.copyWith(isEmailVerified: true);
    } else {
      return userModel;
    }
  }

  @override
  Future<UserModel> insertOrUpdateUser({UserModel userModel}) async {
    final user = await (firebaseAuth.currentUser());
    final userId = user.uid;
    return await insertOrUpdateUserById(userId: userId, userModel: userModel);
  }

  @override
  Future<String> getUserId() async {
    return (await firebaseAuth.currentUser()).uid;
  }

  @override
  Future<UserModel> getUserInfoById({String userId}) async {
    print('Got USER ID: $userId');
    final userData =
        await (firestore.collection('users').document(userId).get());
    final userJson = userData.data;
    print('Pulled user info: ${json.encode(userJson)}');
    return UserModel.fromJson(userJson);
  }

  Future<File> insertOrUpdateUserPhoto({File userPhotoFile}) async {
    final userId = await getUserId();

    StorageReference storageReference =
        FirebaseStorage().ref().child('photos').child(userId);
    print('STORAGE REFERENCE: ${storageReference.path}');
    StorageUploadTask uploadTask = storageReference.putFile(userPhotoFile);
    await uploadTask.onComplete;

    String photoUrl = await storageReference.getDownloadURL();
    await firestore
        .collection('users')
        .document(userId)
        .updateData({'photoUrl': photoUrl});

    return userPhotoFile;
  }

  @override
  Future<UserModel> insertOrUpdateUserById(
      {String userId, UserModel userModel}) async {
    print('InsertOrUpdate USER ID: $userId');
    await firestore
        .collection('users')
        .document(userId)
        .setData(userModel.toJson());
    return userModel;
  }

  @override
  Future<File> getUserPhoto([String userId]) async {
    final id = userId ?? await getUserId();
    StorageReference ref = firebaseStorage.ref().child('photos').child(id);
    print('Storage Ref: ${ref.path}');
    final File tempPhotoFile = File('$_photosDir/temp$id.png');
    if (tempPhotoFile.existsSync()) {
      await tempPhotoFile.delete();
    }
    await tempPhotoFile.create(recursive: true);
    final StorageFileDownloadTask downloadTask = ref.writeToFile(tempPhotoFile);
    int downloadedBytes = (await downloadTask.future).totalByteCount;

    if (downloadedBytes == 0) {
      print('NOTHING DONWLOADED');
    }

    final size = tempPhotoFile.lengthSync();
    print('PHOTO SIZE DATA SOURCE: $size');

    return tempPhotoFile;
  }
}
