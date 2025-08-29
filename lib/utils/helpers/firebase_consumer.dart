import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../result.dart';

class FirebaseConsumer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, DocumentSnapshot?> _lastDocuments = {};
  final Map<String, bool> _hasMoreData = {};

  Future<Result<T>> _handleFirestoreRequest<T>(Future<T> Function() request) async {
    try {
      if (await InternetConnection().hasInternetAccess) {
        final result = await request();
        return Result(data: result);
      } else {
        return Result(error: "no internet connection");
      }
    } catch (e) {
      return Result(error: e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> getDocument({
    String? path,
    String? collectionPath,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>)? queryBuilder,
  }) async {
    return _handleFirestoreRequest(() async {
      // If path is provided, get single document
      if (path != null) {
        final docSnapshot = await _firestore.doc(path).get();

        if (!docSnapshot.exists) {
          return <String, dynamic>{}; // Return empty map instead of throwing
        }

        return docSnapshot.data() as Map<String, dynamic>;
      }

      // If collectionPath and queryBuilder are provided, query collection
      if (collectionPath != null) {
        Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

        if (queryBuilder != null) {
          query = queryBuilder(query);
        }

        final querySnapshot = await query.get();

        if (querySnapshot.docs.isEmpty) {
          return <String, dynamic>{}; // Return empty map if no documents found
        }

        // Return the first document's data
        return querySnapshot.docs.first.data();
      }

      // If neither path nor collectionPath is provided
      return <String, dynamic>{};
    });
  }

  Future<Result<List<Map<String, dynamic>>>> getCollection({
    required String path,
    Query Function(Query)? queryBuilder,
    int? limit,
    bool getNextPage = false,
    bool resetPagination = false,
    String? trackingKey, // Add this new parameter
  }) async {
    return _handleFirestoreRequest(() async {
      // Use trackingKey if provided, otherwise use path
      final key = trackingKey ?? path;

      // Reset pagination if requested
      if (resetPagination) {
        _lastDocuments[key] = null;
        _hasMoreData[key] = true;
      }

      // If there are no more documents and we're getting the next page, return empty
      if (getNextPage && _hasMoreData.containsKey(key) && !_hasMoreData[key]!) {
        return <Map<String, dynamic>>[];
      }

      Query query = _firestore.collection(path);

      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      // Apply pagination if getting next page and we have a last document
      if (getNextPage && _lastDocuments.containsKey(key) && _lastDocuments[key] != null) {
        query = query.startAfterDocument(_lastDocuments[key]!);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      final List<Map<String, dynamic>> documents = querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      // Update pagination state using the key
      if (limit != null) {
        _lastDocuments[key] = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
        _hasMoreData[key] = querySnapshot.docs.length == limit;
      }

      return documents;
    });
  }

  Future<Result<List<Map<String, dynamic>>>> getSubCollection({
    required String documentPath,
    required String subCollectionName,
    Query Function(Query)? queryBuilder,
    int? limit,
    bool getNextPage = false,
    bool resetPagination = false,
  }) async {
    final fullPath = '$documentPath/$subCollectionName';
    return getCollection(
      path: fullPath,
      queryBuilder: queryBuilder,
      limit: limit,
      getNextPage: getNextPage,
      resetPagination: resetPagination,
    );
  }

  // Add these helper methods to check pagination state
  bool hasMoreData(String path) {
    return _hasMoreData[path] ?? false;
  }

  void resetPaginationState(String path) {
    _lastDocuments[path] = null;
    _hasMoreData[path] = true;
  }

  Future<Result<String>> addDocument({required String collectionPath, required Map<String, dynamic> data}) async {
    return _handleFirestoreRequest(() async {
      final docRef = await _firestore.collection(collectionPath).add(data);
      return docRef.id;
    });
  }

  Future<Result<void>> updateDocument({required String path, required Map<String, dynamic> data}) async {
    return _handleFirestoreRequest(() async {
      await _firestore.doc(path).update(data);
      return;
    });
  }

  Future<Result<void>> setDocument({required String path, required Map<String, dynamic> data, bool merge = false}) async {
    return _handleFirestoreRequest(() async {
      await _firestore.doc(path).set(data, SetOptions(merge: merge));
      return;
    });
  }

  Future<Result<void>> deleteDocument({required String path}) async {
    return _handleFirestoreRequest(() async {
      await _firestore.doc(path).delete();
      return;
    });
  }

  Future<Result<void>> batchWrite({required Future<void> Function(WriteBatch batch) operations}) async {
    return _handleFirestoreRequest(() async {
      final batch = _firestore.batch();
      await operations(batch);
      await batch.commit();
      return;
    });
  }

  Future<Result<T>> transaction<T>({required Future<T> Function(Transaction transaction) operations}) async {
    return _handleFirestoreRequest(() async {
      return _firestore.runTransaction(operations);
    });
  }
}
