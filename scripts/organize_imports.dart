// ignore_for_file: avoid_print

import 'dart:io';
import 'package:path/path.dart' as path;

void main() async {
  // Get the absolute path of the current script's directory
  final scriptFile = File(Platform.script.toFilePath());
  final scriptDir = Directory(path.dirname(scriptFile.path));

  // Navigate to the lib directory
  final libDir = Directory(path.normalize(path.join(scriptDir.path, '../lib')));

  // Convert to absolute path
  final absoluteLibPath = libDir.absolute.path;

  // Verify the lib directory exists
  if (!libDir.existsSync()) {
    print('Error: Could not find lib directory at $absoluteLibPath');
    exit(1);
  }

  // Verify this is the correct lib directory
  if (!path.normalize(absoluteLibPath).contains('habits${path.separator}lib')) {
    print('Error: Invalid lib directory. Must be under habits/lib');
    print('Current path: $absoluteLibPath');
    exit(1);
  }

  print('Organizing imports and exports in $absoluteLibPath...');
  await organizeImportsInDirectory(libDir);
  print('Done organizing imports and exports!');
}

Future<void> organizeImportsInDirectory(Directory dir) async {
  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      await organizeImportsInFile(entity);
    }
  }
}

Future<void> organizeImportsInFile(File file) async {
  final content = await file.readAsString();
  final lines = content.split('\n');

  final dartImports = <String>[];
  final flutterImports = <String>[];
  final packageImports = <String>[];
  final projectImports = <String>[];
  final relativeImports = <String>[];

  final dartExports = <String>[];
  final flutterExports = <String>[];
  final packageExports = <String>[];
  final projectExports = <String>[];
  final relativeExports = <String>[];

  final otherLines = <String>[];

  bool isImportOrExport = false;
  for (final line in lines) {
    if (line.trim().startsWith('import ') ||
        line.trim().startsWith('export ')) {
      isImportOrExport = true;
      final statement = line.trim();
      final isExport = statement.startsWith('export ');

      if (statement.contains('dart:')) {
        isExport ? dartExports.add(statement) : dartImports.add(statement);
      } else if (statement.contains('package:flutter/')) {
        isExport
            ? flutterExports.add(statement)
            : flutterImports.add(statement);
      } else if (statement.contains('package:habits/')) {
        isExport
            ? projectExports.add(statement)
            : projectImports.add(statement);
      } else if (statement.contains('package:')) {
        isExport
            ? packageExports.add(statement)
            : packageImports.add(statement);
      } else if (statement.contains("'./") ||
          statement.contains("'../") ||
          statement.contains("'.'") ||
          statement.contains('"./') ||
          statement.contains('"../') ||
          statement.contains('"."')) {
        isExport
            ? relativeExports.add(statement)
            : relativeImports.add(statement);
      } else {
        otherLines.add(line);
      }
    } else {
      if (isImportOrExport && line.trim().isEmpty) {
        continue;
      }
      isImportOrExport = false;
      otherLines.add(line);
    }
  }

  dartImports.sort();
  flutterImports.sort();
  packageImports.sort();
  projectImports.sort();
  relativeImports.sort();

  dartExports.sort();
  flutterExports.sort();
  packageExports.sort();
  projectExports.sort();
  relativeExports.sort();

  final importGroups = <List<String>>[];
  final exportGroups = <List<String>>[];

  if (dartImports.isNotEmpty) importGroups.add(dartImports);
  if (flutterImports.isNotEmpty) importGroups.add(flutterImports);
  if (packageImports.isNotEmpty) importGroups.add(packageImports);
  if (projectImports.isNotEmpty) importGroups.add(projectImports);
  if (relativeImports.isNotEmpty) importGroups.add(relativeImports);

  if (dartExports.isNotEmpty) exportGroups.add(dartExports);
  if (flutterExports.isNotEmpty) exportGroups.add(flutterExports);
  if (packageExports.isNotEmpty) exportGroups.add(packageExports);
  if (projectExports.isNotEmpty) exportGroups.add(projectExports);
  if (relativeExports.isNotEmpty) exportGroups.add(relativeExports);

  final newContent = [
    if (importGroups.isNotEmpty)
      importGroups.map((group) => group.join('\n')).join('\n\n'),
    if (exportGroups.isNotEmpty)
      exportGroups.map((group) => group.join('\n')).join('\n\n'),
    if (otherLines.isNotEmpty) otherLines.join('\n'),
  ].where((part) => part.isNotEmpty).join('\n\n');

  if (content != newContent) {
    await file.writeAsString(newContent);
    print('Organized imports and exports in ${file.path}');
  }
}
