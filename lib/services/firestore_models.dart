import 'package:cloud_firestore/cloud_firestore.dart';

/// User document model stored in Firestore under /users/{uid}
class FirestoreUserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLogin;
  final int streak;
  final int totalStudyMinutes;
  final int documentsUploaded;

  const FirestoreUserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.lastLogin,
    this.photoUrl,
    this.streak = 0,
    this.totalStudyMinutes = 0,
    this.documentsUploaded = 0,
  });

  factory FirestoreUserModel.fromMap(Map<String, dynamic> map, String docId) {
    return FirestoreUserModel(
      uid: docId,
      name: (map['name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      photoUrl: map['photoUrl'] as String?,
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      lastLogin: _parseDateTime(map['lastLogin']) ?? DateTime.now(),
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      totalStudyMinutes: (map['totalStudyMinutes'] as num?)?.toInt() ?? 0,
      documentsUploaded: (map['documentsUploaded'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'streak': streak,
      'totalStudyMinutes': totalStudyMinutes,
      'documentsUploaded': documentsUploaded,
    };
  }

  FirestoreUserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
    int? streak,
    int? totalStudyMinutes,
    int? documentsUploaded,
  }) {
    return FirestoreUserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      streak: streak ?? this.streak,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
      documentsUploaded: documentsUploaded ?? this.documentsUploaded,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}

/// Document metadata model stored in Firestore under /documents/{documentId}
class FirestoreDocumentModel {
  final String id;
  final String ownerId;
  final String title;
  final String subject;
  final String fileName;
  final String fileUrl;
  final DateTime uploadedAt;
  final DateTime lastOpened;
  final int conceptCount;
  final int quizCount;
  final int flashcardCount;
  final String? summary;
  final String? extractedText;
  final Map<String, dynamic>? documentData;
  final String status;
  final String uploadStatus;
  final String storagePath;
  final Map<String, dynamic>? structuredKnowledge;

  const FirestoreDocumentModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.subject,
    required this.fileName,
    required this.fileUrl,
    required this.uploadedAt,
    required this.lastOpened,
    this.conceptCount = 0,
    this.quizCount = 0,
    this.flashcardCount = 0,
    this.summary,
    this.extractedText,
    this.documentData,
    this.status = 'processing',
    this.uploadStatus = 'uploaded',
    this.storagePath = '',
    this.structuredKnowledge,
  });

  factory FirestoreDocumentModel.fromMap(
      Map<String, dynamic> map, String docId) {
    return FirestoreDocumentModel(
      id: docId,
      ownerId: (map['ownerId'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      subject: (map['subject'] as String?) ?? 'General',
      fileName: (map['fileName'] as String?) ?? '',
      fileUrl: (map['fileUrl'] as String?) ?? '',
      uploadedAt: _parseDateTime(map['uploadedAt']) ?? DateTime.now(),
      lastOpened: _parseDateTime(map['lastOpened']) ?? DateTime.now(),
      conceptCount: (map['conceptCount'] as num?)?.toInt() ?? 0,
      quizCount: (map['quizCount'] as num?)?.toInt() ?? 0,
      flashcardCount: (map['flashcardCount'] as num?)?.toInt() ?? 0,
      summary: map['summary'] as String?,
      extractedText: map['extractedText'] as String?,
      documentData: map['documentData'] as Map<String, dynamic>?,
      status: (map['status'] as String?) ?? 'processing',
      uploadStatus: (map['uploadStatus'] as String?) ?? 'uploaded',
      storagePath: (map['storagePath'] as String?) ?? '',
      structuredKnowledge: map['structuredKnowledge'] is Map
          ? Map<String, dynamic>.from(map['structuredKnowledge'] as Map)
          : null,
    );
  }

  String get fileType =>
      fileName.contains('.') ? fileName.split('.').last.toUpperCase() : 'DOC';

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'subject': subject,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'lastOpened': Timestamp.fromDate(lastOpened),
      'conceptCount': conceptCount,
      'quizCount': quizCount,
      'flashcardCount': flashcardCount,
      if (summary != null) 'summary': summary,
      if (extractedText != null) 'extractedText': extractedText,
      if (documentData != null) 'documentData': documentData,
      'status': status,
      'uploadStatus': uploadStatus,
      'storagePath': storagePath,
      if (structuredKnowledge != null)
        'structuredKnowledge': structuredKnowledge,
    };
  }

  FirestoreDocumentModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? subject,
    String? fileName,
    String? fileUrl,
    DateTime? uploadedAt,
    DateTime? lastOpened,
    int? conceptCount,
    int? quizCount,
    int? flashcardCount,
    String? status,
    String? uploadStatus,
    String? storagePath,
    Map<String, dynamic>? structuredKnowledge,
  }) {
    return FirestoreDocumentModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      lastOpened: lastOpened ?? this.lastOpened,
      conceptCount: conceptCount ?? this.conceptCount,
      quizCount: quizCount ?? this.quizCount,
      flashcardCount: flashcardCount ?? this.flashcardCount,
      status: status ?? this.status,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      storagePath: storagePath ?? this.storagePath,
      structuredKnowledge: structuredKnowledge ?? this.structuredKnowledge,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}

/// Chat Session model stored in Firestore under /chat_sessions/{sessionId}
class FirestoreChatSessionModel {
  final String id;
  final String ownerId;
  final String? documentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FirestoreChatSessionModel({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.documentId,
  });

  factory FirestoreChatSessionModel.fromMap(
      Map<String, dynamic> map, String docId) {
    return FirestoreChatSessionModel(
      id: docId,
      ownerId: (map['ownerId'] as String?) ?? '',
      documentId: map['documentId'] as String?,
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'documentId': documentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  FirestoreChatSessionModel copyWith({
    String? id,
    String? ownerId,
    String? documentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FirestoreChatSessionModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      documentId: documentId ?? this.documentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}

/// Chat Message model stored in Firestore under /chat_sessions/{sessionId}/messages/{messageId}
class FirestoreChatMessageModel {
  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime timestamp;

  const FirestoreChatMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory FirestoreChatMessageModel.fromMap(
      Map<String, dynamic> map, String docId) {
    return FirestoreChatMessageModel(
      id: docId,
      role: (map['role'] as String?) ?? 'user',
      content: (map['content'] as String?) ?? '',
      timestamp: _parseDateTime(map['timestamp']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  FirestoreChatMessageModel copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? timestamp,
  }) {
    return FirestoreChatMessageModel(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}

/// Study Progress model stored in Firestore under /study_progress/{uid}
class FirestoreStudyProgressModel {
  final String uid;
  final int totalMinutes;
  final int currentStreak;
  final int conceptsLearned;
  final int flashcardsReviewed;
  final int quizzesCompleted;
  final DateTime? lastStudyDate;

  const FirestoreStudyProgressModel({
    required this.uid,
    this.totalMinutes = 0,
    this.currentStreak = 0,
    this.conceptsLearned = 0,
    this.flashcardsReviewed = 0,
    this.quizzesCompleted = 0,
    this.lastStudyDate,
  });

  factory FirestoreStudyProgressModel.fromMap(
      Map<String, dynamic> map, String docId) {
    return FirestoreStudyProgressModel(
      uid: docId,
      totalMinutes: (map['totalMinutes'] as num?)?.toInt() ?? 0,
      currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
      conceptsLearned: (map['conceptsLearned'] as num?)?.toInt() ?? 0,
      flashcardsReviewed: (map['flashcardsReviewed'] as num?)?.toInt() ?? 0,
      quizzesCompleted: (map['quizzesCompleted'] as num?)?.toInt() ?? 0,
      lastStudyDate: _parseDateTime(map['lastStudyDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalMinutes': totalMinutes,
      'currentStreak': currentStreak,
      'conceptsLearned': conceptsLearned,
      'flashcardsReviewed': flashcardsReviewed,
      'quizzesCompleted': quizzesCompleted,
      if (lastStudyDate != null)
        'lastStudyDate': Timestamp.fromDate(lastStudyDate!),
    };
  }

  FirestoreStudyProgressModel copyWith({
    String? uid,
    int? totalMinutes,
    int? currentStreak,
    int? conceptsLearned,
    int? flashcardsReviewed,
    int? quizzesCompleted,
    DateTime? lastStudyDate,
  }) {
    return FirestoreStudyProgressModel(
      uid: uid ?? this.uid,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      conceptsLearned: conceptsLearned ?? this.conceptsLearned,
      flashcardsReviewed: flashcardsReviewed ?? this.flashcardsReviewed,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}
