import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:habits/constants/habit_icons.dart';
import 'package:habits/core/extensions/map_extension.dart';
import 'package:habits/core/extensions/string_extensions.dart';

class Category {
  static const String tableName = 'category';
  
  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      created_at INTEGER NOT NULL,
      name TEXT NOT NULL,
      description TEXT,
      color INTEGER,
      icon_name TEXT,
      extra_attributes TEXT
    )
  ''';

  final String id;
  final DateTime createdAt;
  final String name;
  final String? description;
  final int color;
  final String iconName;
  final Map<String, dynamic>? extraAttributes;

  const Category({
    required this.id,
    required this.createdAt,
    required this.name,
    this.description,
    required this.color,
    required this.iconName,
    this.extraAttributes,
  });

  // Create a new category
  factory Category.create({
    required String name,
    String? description,
    required int color,
    required String iconName,
    Map<String, dynamic>? extraAttributes,
  }) {
    return Category(
      id: name.toSnakeCase(),
      createdAt: DateTime.now(),
      name: name,
      description: description,
      color: color,
      iconName: iconName,
      extraAttributes: extraAttributes,
    );
  }

  // Get the icon data for this category
  IconData get icon => HabitIcons.getIcon(iconName);

  // Create from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      name: json.getStringOrDefaultValue('name'),
      description: json.getStringOrNull('description'),
      color: json['color'] as int? ?? 0xFF000000,
      iconName: json.getStringOrDefaultValue('icon_name'),
      extraAttributes: json['extra_attributes'] != null
          ? jsonDecode(json['extra_attributes'] as String)
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.millisecondsSinceEpoch,
      'name': name,
      'description': description,
      'color': color,
      'icon_name': iconName,
      'extra_attributes':
          extraAttributes != null ? jsonEncode(extraAttributes) : null,
    };
  }

  // Create a copy with some fields replaced
  Category copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? description,
    int? color,
    String? iconName,
    Map<String, dynamic>? extraAttributes,
  }) {
    return Category(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      iconName: iconName ?? this.iconName,
      extraAttributes: extraAttributes ?? this.extraAttributes,
    );
  }

  // Create a duplicate with new ID and timestamp
  Category duplicate({
    String? name,
    String? description,
    int? color,
    String? iconName,
    Map<String, dynamic>? extraAttributes,
  }) {
    return Category(
      id: id,
      createdAt: DateTime.now(),
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      iconName: iconName ?? this.iconName,
      extraAttributes: extraAttributes ?? this.extraAttributes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
