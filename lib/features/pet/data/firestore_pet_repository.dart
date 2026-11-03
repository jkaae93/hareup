import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_firebase_core/firebase_failure.dart';

import '../../shared_data/data/group_media_storage.dart';
import '../domain/pet.dart';
import 'pet_dto.dart';

/// Firebase implementation for one explicitly selected family group.
class FirestorePetRepository implements PetRepository {
  FirestorePetRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required this.groupId,
  }) : _firestore = firestore,
       _media = GroupMediaStorage(storage);

  final FirebaseFirestore _firestore;
  final GroupMediaStorage _media;
  final String groupId;

  CollectionReference<Map<String, dynamic>> get _pets =>
      _firestore.collection('groups').doc(groupId).collection('pets');

  @override
  Future<Result<List<Pet>>> list() async {
    try {
      final snapshot = await _pets.orderBy('name').get();
      final pets = <Pet>[];
      for (final document in snapshot.docs) {
        final pet = PetDto.fromJson(document.data()).toDomain();
        final photoPath = document.data()['photoPath'] as String?;
        if (photoPath == null) {
          pets.add(pet);
        } else {
          final bytes = await _media.get(photoPath);
          pets.add(
            Pet(
              id: pet.id,
              name: pet.name,
              species: pet.species,
              profile: PetProfile(
                ageMonths: pet.profile.ageMonths,
                sex: pet.profile.sex,
                weightKg: pet.profile.weightKg,
                photoBytes: bytes,
              ),
            ),
          );
        }
      }
      return Success(List.unmodifiable(pets));
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }

  @override
  Future<Result<void>> save(Pet pet) async {
    String? newPhotoPath;
    try {
      final document = _pets.doc(pet.id);
      final previous = await document.get();
      final previousPath = previous.data()?['photoPath'] as String?;
      if (pet.profile.photoBytes case final bytes?) {
        newPhotoPath = _media.photoPath(
          groupId: groupId,
          collection: 'pets',
          documentId: pet.id,
          name: 'profile.jpg',
        );
        await _media.put(path: newPhotoPath, bytes: bytes);
      } else {
        newPhotoPath = previousPath;
      }
      final data = PetDto.fromDomain(pet).toJson();
      if (newPhotoPath != null) data['photoPath'] = newPhotoPath;
      await document.set(data, SetOptions(merge: true));
      if (previousPath != null && previousPath != newPhotoPath) {
        try {
          await _media.remove(previousPath);
        } on FirebaseException {
          // The Firestore update is authoritative; stale media can be cleaned later.
        }
      }
      return const Success(null);
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      // Product policy can restrict deletion to administrators in Firestore rules.
      await _pets.doc(id).delete();
      return const Success(null);
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }
}
