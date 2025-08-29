// lib/features/site/provider/site_provider.dart
import 'package:assesment/features/site/model/site_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assesment/features/site/api/site_api.dart';
import 'package:assesment/core/network/dio_provider.dart';

final siteApiProvider = Provider<SiteApi>((ref) {
  final dio = ref.watch(dioProvider);
  return SiteApi(dio);
});

final sitesProvider = FutureProvider<SiteListModel>((ref) async {
  final siteApi = ref.read(siteApiProvider);
  return await siteApi.getSitesByUser();
});
