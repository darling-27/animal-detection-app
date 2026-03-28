import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/history_data.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── CHANGE THIS TO YOUR ACTUAL COLLECTION NAME ──
  static const String _collectionName = 'detections';
  static const int _pageSize = 15;

  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;

  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  /// Resets pagination state (call before initial fetch)
  void resetPagination() {
    _lastDocument = null;
    _hasMore = true;
    _isLoading = false;
  }

  /// Fetch detections with pagination (lazy loading)
  Future<List<HistoryData>> fetchDetections({
    String? filterType, // 'dangerous', 'wild', 'domestic', 'week'
  }) async {
    if (_isLoading || !_hasMore) return [];

    _isLoading = true;

    try {
      Query query = _firestore
          .collection(_collectionName)
          .orderBy('timestamp', descending: true);

      // ── Apply filters ──
      if (filterType == 'dangerous') {
        query = query.where('isDangerous', isEqualTo: true);
      } else if (filterType == 'wild') {
        query = query.where('animalCategory', isEqualTo: 'wild');
      } else if (filterType == 'domestic') {
        query = query.where('animalCategory', isEqualTo: 'domestic');
      } else if (filterType == 'week') {
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        query = query.where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo));
      }

      // ── Pagination cursor ──
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      query = query.limit(_pageSize);

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasMore = false;
        _isLoading = false;
        return [];
      }

      if (snapshot.docs.length < _pageSize) {
        _hasMore = false;
      }

      _lastDocument = snapshot.docs.last;
      _isLoading = false;

      return snapshot.docs
          .map((doc) => HistoryData.fromFirestore(doc))
          .toList();
    } catch (e) {
      _isLoading = false;
      rethrow;
    }
  }

  /// Fetch a single detection by ID
  Future<HistoryData?> fetchDetectionById(String id) async {
    try {
      final doc =
      await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return HistoryData.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get total count of detections
  Future<int> getTotalCount() async {
    final snapshot =
    await _firestore.collection(_collectionName).count().get();
    return snapshot.count ?? 0;
  }

  /// Get count of dangerous detections
  Future<int> getDangerousCount() async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('isDangerous', isEqualTo: true)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// Real-time stream for latest detections (optional)
  Stream<List<HistoryData>> streamLatestDetections({int limit = 10}) {
    return _firestore
        .collection(_collectionName)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => HistoryData.fromFirestore(doc))
        .toList());
  }
}