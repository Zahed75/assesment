import 'package:assesment/navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mockSitesProvider = StateProvider<List<Map<String, String>>>((ref) {
  return [
    {'site_code': 'D001', 'name': 'Site A'},
    {'site_code': 'D002', 'name': 'Site B'},
    {'site_code': 'D003', 'name': 'Site C'},
    {'site_code': 'D004', 'name': 'Site D'},
    {'site_code': 'D005', 'name': 'Site E'},
  ];
});

final searchQueryProvider = StateProvider<String>((ref) => '');

class SiteLocation extends ConsumerWidget {
  final bool isSelectionMode;

  const SiteLocation({super.key, required this.isSelectionMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sites = ref.watch(mockSitesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final filteredSites = sites
        .where(
          (site) =>
              site['site_code']!.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              site['name']!.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Select Your Site',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Search Bar
            TextField(
              onChanged: (query) {
                ref.read(searchQueryProvider.state).state = query;
              },
              decoration: InputDecoration(
                hintText: 'Search by site code or name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(searchQueryProvider.state).state = '';
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // No results found
            if (filteredSites.isEmpty)
              const Expanded(child: Center(child: Text('No results found'))),

            // Site Grid
            Expanded(
              child: GridView.builder(
                itemCount: filteredSites.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final site = filteredSites[index];
                  final siteCode = site['site_code']!;
                  final siteName = site['name']!;

                  return GestureDetector(
                    onTap: () async {
                      // Simulate site selection and navigation
                      debugPrint(
                        '[HomeSiteLocation] TAP site_code=$siteCode, name="$siteName"',
                      );
                      // Here, simulate storing the selected site
                      // Navigate to the next screen after site selection
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NavigationMenu(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(1, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            siteCode,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            siteName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
