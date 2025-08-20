import 'package:assesment/features/survey/survey_info.dart';
import 'package:assesment/utils/constants/colors.dart';
import 'package:assesment/utils/constants/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/sizes.dart';

// Define Riverpod providers for state management (no API data for now)
final isLoadingProvider = StateProvider<bool>((ref) => true);
final surveysProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);
final siteCodeProvider = StateProvider<String>((ref) => 'Loading...');

// HomeScreen UI (migrated to Riverpod)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Simulating data load with delay
    _loadSiteCode();
    _fetchSurveys();
  }

  // Load site code from storage (or just use a placeholder)
  void _loadSiteCode() {
    final siteCode = 'D011'; // Placeholder for the site code
    ref.read(siteCodeProvider.notifier).state = siteCode;
  }

  // Simulate fetching surveys (replace with real API logic later)
  Future<void> _fetchSurveys() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate loading delay

    final mockSurveys = [
      {'title': 'Survey 1', 'questions': [], 'totalQuestions': 10},
      {'title': 'Survey 2', 'questions': [], 'totalQuestions': 5},
    ];
    ref.read(surveysProvider.notifier).state = mockSurveys;
    ref.read(isLoadingProvider.notifier).state = false; // Stop loading
  }

  // Handle site selection
  Future<void> _selectSite() async {
    final updatedCode =
        'D013'; // Simulated updated site code from HomeSiteLocation screen
    ref.read(siteCodeProvider.notifier).state = updatedCode;
    await _fetchSurveys(); // Refetch surveys after site change
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final siteCode = ref.watch(siteCodeProvider);
    final surveys = ref.watch(surveysProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final textColor = isDark ? UColors.white : UColors.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/circleIcon.png',
                    width: 24,
                    height: 24,
                  ),
                  Text(
                    'Home',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w900,
                      color: UColors.warning,
                    ),
                  ),
                  GestureDetector(
                    onTap: _selectSite,
                    child: Row(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            siteCode,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(
                                  color: UColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Iconsax.arrow_down_1,
                          color: UColors.primary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black12 : Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _fetchSurveys,
                        child: surveys.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  const SizedBox(height: 120),
                                  Center(
                                    child: Text(
                                      'No surveys available.',
                                      style: TextStyle(color: subtitleColor),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                itemCount: surveys.length,
                                itemBuilder: (context, index) {
                                  final survey = surveys[index];
                                  final qLen =
                                      (survey['questions'] as List?)?.length ??
                                      0;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (index == 0)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                            top: 8,
                                          ),
                                          child: Text(
                                            UTexts.availabileSurvey,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .copyWith(
                                                  color: textColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                      SurveyInfo(
                                        title: survey['title'] ?? '',
                                        totalQuestions: qLen,
                                        estimatedTime: '${qLen * 1} min',
                                        onStart: () {
                                          // Handle start of the survey
                                          // Get.to(() => QuestionScreen(surveyData: survey));
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  );
                                },
                              ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
