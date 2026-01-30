/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class NudgeData implements _i1.SerializableModel {
  NudgeData._({
    this.id,
    required this.category,
    required this.title,
    this.link,
    this.expiry,
    required this.isDone,
  });

  factory NudgeData({
    int? id,
    required String category,
    required String title,
    String? link,
    DateTime? expiry,
    required bool isDone,
  }) = _NudgeDataImpl;

  factory NudgeData.fromJson(Map<String, dynamic> jsonSerialization) {
    return NudgeData(
      id: jsonSerialization['id'] as int?,
      category: jsonSerialization['category'] as String,
      title: jsonSerialization['title'] as String,
      link: jsonSerialization['link'] as String?,
      expiry: jsonSerialization['expiry'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['expiry']),
      isDone: jsonSerialization['isDone'] as bool,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String category;

  String title;

  String? link;

  DateTime? expiry;

  bool isDone;

  /// Returns a shallow copy of this [NudgeData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  NudgeData copyWith({
    int? id,
    String? category,
    String? title,
    String? link,
    DateTime? expiry,
    bool? isDone,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NudgeData',
      if (id != null) 'id': id,
      'category': category,
      'title': title,
      if (link != null) 'link': link,
      if (expiry != null) 'expiry': expiry?.toJson(),
      'isDone': isDone,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NudgeDataImpl extends NudgeData {
  _NudgeDataImpl({
    int? id,
    required String category,
    required String title,
    String? link,
    DateTime? expiry,
    required bool isDone,
  }) : super._(
         id: id,
         category: category,
         title: title,
         link: link,
         expiry: expiry,
         isDone: isDone,
       );

  /// Returns a shallow copy of this [NudgeData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  NudgeData copyWith({
    Object? id = _Undefined,
    String? category,
    String? title,
    Object? link = _Undefined,
    Object? expiry = _Undefined,
    bool? isDone,
  }) {
    return NudgeData(
      id: id is int? ? id : this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      link: link is String? ? link : this.link,
      expiry: expiry is DateTime? ? expiry : this.expiry,
      isDone: isDone ?? this.isDone,
    );
  }
}
