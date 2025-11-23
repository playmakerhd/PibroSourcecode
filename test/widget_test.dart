// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:pibro/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('pibro_test_storage');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
    await GetStorage.init();
  });

  tearDown(() async {
    await GetStorage().erase();
  });

  tearDownAll(() async {
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {
      // Ignore cleanup errors caused by pending I/O handles in tests.
    }
  });

  testWidgets('App bootstraps without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // The production app uses a GetMaterialApp wrapper, but MaterialApp
    // remains part of the widget tree. Verifying its presence ensures the
    // root widget renders successfully without relying on demo counter text.
    expect(find.byType(MaterialApp), findsWidgets);
  });
}

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this.basePath);

  final String basePath;

  Future<String?> _pathFuture() async => basePath;

  @override
  Future<String?> getApplicationDocumentsPath() => _pathFuture();

  @override
  Future<String?> getApplicationSupportPath() => _pathFuture();

  @override
  Future<String?> getLibraryPath() => _pathFuture();

  @override
  Future<String?> getTemporaryPath() => _pathFuture();

  @override
  Future<String?> getDownloadsPath() => _pathFuture();
}
