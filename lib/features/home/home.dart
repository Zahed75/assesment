// lib/features/home/home.dart
import 'package:assesment/common_ui/widgets/alerts/u_alert.dart';
import 'package:assesment/features/home/model/survey_list_model.dart';
import 'package:assesment/features/home/provider/survey_api_provider.dart';
import 'package:assesment/features/site/site_location.dart';
import 'package:assesment/features/survey/survey_info.dart';
import 'package:assesment/utils/constants/colors.dart';
import 'package:assesment/utils/constants/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

// Define Riverpod providers for state management
final isLoadingProvider = StateProvider<bool>((ref) => true);
final surveysProvider = StateProvider<List<SurveyData>>(
  (ref) => [],
); // Changed to SurveyData
final siteCodeProvider = StateProvider<String>((ref) => 'Loading...');
final errorMessageProvider = StateProvider<String?>((ref) => null);

// HomeScreen UI
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSiteCode();
      _fetchSurveys();
    });
  }

  // Load site code from storage (or just use a placeholder)
  void _loadSiteCode() {
    final siteCode = 'D011'; // Placeholder for the site code
    ref.read(siteCodeProvider.notifier).state = siteCode;
  }

  // Fetch surveys from API
  Future<void> _fetchSurveys() async {
    final surveyApi = ref.read(surveyApiProvider);

    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorMessageProvider.notifier).state = null;

    try {
      final surveyList = await surveyApi.getSurveysByUser();

      if (surveyList.data != null && surveyList.data!.isNotEmpty) {
        ref.read(surveysProvider.notifier).state = surveyList.data!;
      } else {
        ref.read(surveysProvider.notifier).state = [];
      }
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = e.toString();
      // Show error alert
      WidgetsBinding.instance.addPostFrameCallback((_) {
        UAlert.show(
          // Fixed UAlert reference
          title: 'Error',
          message:
              'Failed to load surveys: ${e.toString().replaceAll('Exception: ', '')}',
          context: context,
        );
      });
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  // Handle site selection
  Future<void> _openSiteLocation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SiteLocation(isSelectionMode: true),
      ),
    );
  }

  // Handle survey start
  void _onStartSurvey(SurveyData survey) {
    // Changed to SurveyData
    print('Starting survey: ${survey.title}');
    // TODO: Implement survey navigation
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final siteCode = ref.watch(siteCodeProvider);
    final surveys = ref.watch(surveysProvider);
    final errorMessage = ref.watch(errorMessageProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final textColor = isDark ? UColors.white : UColors.dark;

    // Show error message if exists
    if (errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        UAlert.show(
          // Fixed UAlert reference
          title: 'Error',
          message: errorMessage,
          context: context,
        );
        ref.read(errorMessageProvider.notifier).state = null;
      });
    }

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
                    onTap: _openSiteLocation,
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
                                  final questionCount =
                                      survey.questions?.length ?? 0;
                                  final estimatedTime =
                                      questionCount * 1; // 1 min per question

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
                                        title:
                                            survey.title ?? 'Untitled Survey',
                                        totalQuestions: questionCount,
                                        estimatedTime: '$estimatedTime min',
                                        onStart: () => _onStartSurvey(survey),
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
