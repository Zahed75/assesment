import 'package:assesment/app/router/routes.dart';
import 'package:assesment/common_ui/widgets/alerts/u_alert.dart';
import 'package:assesment/features/question/model/survey_submit_model.dart';
import 'package:assesment/features/question/provider/survey_submit_provider.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

// Providers for Riverpod
final locationProvider = StateProvider<Position?>((ref) => null);
final imageProvider = StateProvider<Map<int, String?>>((ref) => {});
final detectedLocationProvider = StateProvider<Map<int, Map<String, double>?>>(
  (ref) => {},
);
final answersProvider = StateProvider<Map<int, dynamic>>((ref) => {});
final currentCategoryProvider = StateProvider<String>((ref) => 'All');
final expandedCategoriesProvider = StateProvider<Set<String>>((ref) => {});

class QuestionScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> surveyData;
  final String siteCode;

  const QuestionScreen({
    super.key,
    required this.surveyData,
    required this.siteCode,
  });

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  bool isSubmitting = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(answersProvider.notifier).state = {};
      ref.read(locationProvider.notifier).state = null;
      _getLocation();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      UAlert.show(
        title: "Permission Denied",
        message: "Location permission is required.",
        icon: Icons.error_outline,
        iconColor: Colors.redAccent,
        context: context,
      );
      return;
    }
    final position = await Geolocator.getCurrentPosition();
    ref.read(locationProvider.notifier).state = position;
  }

  Future<void> pickImage(int questionId) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      ref.read(imageProvider.notifier).update((state) {
        return {...state, questionId: image.path};
      });
    }
  }

  Future<void> uploadFile(int questionId) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      ref.read(imageProvider.notifier).update((state) {
        return {...state, questionId: result.files.single.path};
      });
    }
  }

  Future<void> detectLocation(int questionId) async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      UAlert.show(
        title: "Permission Denied",
        message: "Location permission is required.",
        icon: Icons.error_outline,
        iconColor: Colors.redAccent,
        context: context,
      );
      return;
    }
    final position = await Geolocator.getCurrentPosition();
    ref.read(detectedLocationProvider.notifier).update((state) {
      return {
        ...state,
        questionId: {
          "latitude": position.latitude,
          "longitude": position.longitude,
        },
      };
    });
  }

  void _toggleCategory(String category) {
    ref.read(expandedCategoriesProvider.notifier).update((state) {
      final newState = Set<String>.from(state);
      if (newState.contains(category)) {
        newState.remove(category);
      } else {
        newState.add(category);
      }
      return newState;
    });
  }

  // In your _submitSurvey method, add validation before submitting

  // In your QuestionScreen class, replace the entire _submitSurvey method with this:
  Future<void> _submitSurvey() async {
    if (isSubmitting) return;

    setState(() => isSubmitting = true);

    try {
      final surveySubmitApi = ref.read(surveySubmitApiProvider);
      final answers = ref.read(answersProvider);
      final currentLocation = ref.read(locationProvider);
      final images = ref.read(imageProvider);
      final detectedLocations = ref.read(detectedLocationProvider);

      // Prepare question responses with validation
      final List<Map<String, dynamic>> questionResponses = [];
      final Map<int, String> imageFiles = {};
      final List<String> validationErrors = [];

      // Process regular questions (text, choice, linear, remarks, yesno, multiple_scoring)
      for (var question in widget.surveyData['questions']) {
        final questionId = question['id'];
        final questionType = question['type'];
        final isRequired = question['is_required'] ?? false;
        final answer = answers[questionId];

        // Skip image and location questions for now (handled separately)
        if (questionType == 'image' || questionType == 'location') {
          continue;
        }

        // Validate required questions
        if (isRequired && answer == null) {
          validationErrors.add('${question['text']} is required');
          continue;
        }

        // Validate linear range
        if (questionType == 'linear' && answer != null) {
          final minValue = question['min_value'] ?? 0;
          final maxValue = question['max_value'] ?? 100;
          if (answer < minValue || answer > maxValue) {
            validationErrors.add(
              '${question['text']}: Value must be between $minValue and $maxValue',
            );
            continue;
          }
        }

        // Validate text length
        if ((questionType == 'text' || questionType == 'remarks') &&
            answer is String) {
          if (answer.length < 10) {
            validationErrors.add(
              '${question['text']}: Please provide more details (min 10 characters)',
            );
            continue;
          }
        }

        if (answer != null) {
          Map<String, dynamic> response = {'question': questionId};

          switch (questionType) {
            case 'yesno':
            case 'choice':
            case 'multiple_scoring':
              response['selected_choice'] = {'id': answer};
              break;

            case 'linear':
              response['linear_value'] = answer;
              break;

            case 'text':
            case 'remarks':
              response['answer_text'] = answer;
              break;
          }

          questionResponses.add(response);
        }
      }

      // Process image questions
      for (var question in widget.surveyData['questions']) {
        final questionId = question['id'];
        final questionType = question['type'];
        final isRequired = question['is_required'] ?? false;

        if (questionType == 'image') {
          final imagePath = images[questionId];

          // Validate required image
          if (isRequired && imagePath == null) {
            validationErrors.add('${question['text']} is required');
            continue;
          }

          if (imagePath != null) {
            imageFiles[questionId] = imagePath;
            // Add response entry for image question
            questionResponses.add({'question': questionId});
          }
        }
      }

      // Process location questions
      for (var question in widget.surveyData['questions']) {
        final questionId = question['id'];
        final questionType = question['type'];
        final isRequired = question['is_required'] ?? false;

        if (questionType == 'location') {
          final location = detectedLocations[questionId];

          // Validate required location
          if (isRequired && location == null) {
            validationErrors.add('${question['text']} is required');
            continue;
          }

          if (location != null) {
            questionResponses.add({
              'question': questionId,
              'location_lat': location['latitude'],
              'location_lon': location['longitude'],
            });
          }
        }
      }

      // Check for validation errors
      if (validationErrors.isNotEmpty) {
        throw Exception(
          'Please complete all required fields:\n${validationErrors.join('\n')}',
        );
      }

      // Ensure outlet_code is not empty
      final effectiveOutletCode = widget.siteCode.isNotEmpty
          ? widget.siteCode
          : 'CH02';

      // Submit the survey
      final response = await surveySubmitApi.submitSurveyResponse(
        surveyId: widget.surveyData['id'],
        outletCode: effectiveOutletCode,
        locationLat: currentLocation?.latitude,
        locationLon: currentLocation?.longitude,
        questionResponses: questionResponses,
        imagePaths: imageFiles,
      );

      // Handle successful submission
      _showSuccessDialog(response);
    } catch (e) {
      // Handle error with user-friendly message
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      UAlert.show(
        title: "Submission Failed",
        message: errorMessage,
        icon: Icons.error_outline,
        iconColor: Colors.redAccent,
        context: context,
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  // Add this method to show success dialog with results
  void _showSuccessDialog(SurveySubmitResponseModel response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Survey Submitted"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                response.message ?? "Survey submitted successfully!",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                "Total Score: ${response.totalScore?.toStringAsFixed(2) ?? '0'}",
              ),
              Text("Survey: ${response.surveyTitle}"),
              Text("Response ID: ${response.responseId}"),
              const SizedBox(height: 16),
              if (response.submittedQuestions != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Question Results:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...response.submittedQuestions!
                        .take(3)
                        .map(
                          (q) => Text(
                            "• ${q.questionText}: ${q.obtainedMarks}/${q.maxMarks}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    if (response.submittedQuestions!.length > 3)
                      Text(
                        "+ ${response.submittedQuestions!.length - 3} more questions...",
                      ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate back to home screen
              GoRouter.of(context).go(Routes.home);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(
    String category,
    int questionCount,
    bool isExpanded,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.category, color: Colors.blue.shade700, size: 20),
        ),
        title: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text("$questionCount questions"),
        trailing: Icon(
          isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
          size: 20,
        ),
        onTap: () => _toggleCategory(category),
      ),
    );
  }

  Widget _buildQuestionCard(
    Map<String, dynamic> question,
    int serialNumber,
    String category,
  ) {
    final id = question['id'];
    final type = question['type'];
    final text = question['text'];
    final marks = question['marks'];
    final isRequired = question['is_required'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header with serial number
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$serialNumber',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (isRequired)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "Required",
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (marks != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "$marks marks",
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Question input based on type
            _buildQuestionInput(question, id, type),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionInput(
    Map<String, dynamic> question,
    int id,
    String type,
  ) {
    switch (type) {
      case 'yesno':
        return _buildYesNoInput(question, id);
      case 'choice':
        return _buildChoiceInput(question, id);
      case 'multiple_scoring':
        return _buildMultipleScoringInput(question, id);
      case 'image':
        return _buildImageInput(id);
      case 'location':
        return _buildLocationInput(id);
      case 'text':
      case 'remarks':
        return _buildTextInput(id);
      case 'linear':
        return _buildLinearInput(question, id);
      default:
        return const Text('Unknown question type');
    }
  }

  Widget _buildYesNoInput(Map<String, dynamic> question, int id) {
    final choices = question['choices'] as List;
    final currentAnswer = ref.watch(answersProvider)[id];

    return Row(
      children: [
        // Yes Button - 50% width
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilledButton.tonal(
              onPressed: () =>
                  ref.read(answersProvider.notifier).update((state) {
                    return {...state, id: choices[0]['id']};
                  }),
              style: FilledButton.styleFrom(
                backgroundColor: currentAnswer == choices[0]['id']
                    ? Colors.green
                    : null,
                foregroundColor: currentAnswer == choices[0]['id']
                    ? Colors.white
                    : null,
              ),
              child: Text(choices[0]['text']),
            ),
          ),
        ),

        // No Button - 50% width
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilledButton.tonal(
              onPressed: () =>
                  ref.read(answersProvider.notifier).update((state) {
                    return {...state, id: choices[1]['id']};
                  }),
              style: FilledButton.styleFrom(
                backgroundColor: currentAnswer == choices[1]['id']
                    ? Colors.red
                    : null,
                foregroundColor: currentAnswer == choices[1]['id']
                    ? Colors.white
                    : null,
              ),
              child: Text(choices[1]['text']),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceInput(Map<String, dynamic> question, int id) {
    return Column(
      children: (question['choices'] as List).map<Widget>((choice) {
        return RadioListTile(
          title: Text(choice['text']),
          value: choice['id'],
          groupValue: ref.watch(answersProvider)[id],
          onChanged: (val) {
            ref.read(answersProvider.notifier).update((state) {
              return {...state, id: val};
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildMultipleScoringInput(Map<String, dynamic> question, int id) {
    return Column(
      children: (question['choices'] as List).map<Widget>((choice) {
        return RadioListTile(
          title: Text('${choice['text']} (${choice['marks']} marks)'),
          value: choice['id'],
          groupValue: ref.watch(answersProvider)[id],
          onChanged: (val) {
            ref.read(answersProvider.notifier).update((state) {
              return {...state, id: val};
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildImageInput(int id) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => pickImage(id),
                icon: const Icon(Iconsax.camera, size: 18),
                label: const Text('Take Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => uploadFile(id),
                icon: const Icon(Iconsax.gallery, size: 18),
                label: const Text('Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade50,
                  foregroundColor: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
        if (ref.watch(imageProvider)[id] != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.gallery_tick, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selected: ${ref.watch(imageProvider)[id]!.split("/").last}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLocationInput(int id) {
    final detectedLocation = ref.watch(detectedLocationProvider)[id];
    final isLocationDetected = detectedLocation != null;

    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => detectLocation(id),
          icon: const Icon(Iconsax.location, size: 18),
          label: const Text('Detect Current Location'),
        ),
        const SizedBox(height: 12),
        // Show detected location if available
        if (isLocationDetected)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.location_tick, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Lat: ${detectedLocation["latitude"]!.toStringAsFixed(6)}, "
                    "Lng: ${detectedLocation["longitude"]!.toStringAsFixed(6)}",
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTextInput(int id) {
    return TextField(
      maxLines: 3,
      onChanged: (val) {
        ref.read(answersProvider.notifier).update((state) {
          return {...state, id: val};
        });
      },
      decoration: InputDecoration(
        hintText: "Type your response here...",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildLinearInput(Map<String, dynamic> question, int id) {
    final minValue = question['min_value'] ?? 0;
    final maxValue = question['max_value'] ?? 10;
    final currentValue = ref.watch(answersProvider)[id] ?? minValue;

    return Column(
      children: [
        Slider(
          min: minValue.toDouble(),
          max: maxValue.toDouble(),
          value: currentValue.toDouble(),
          divisions: maxValue - minValue,
          onChanged: (val) {
            ref.read(answersProvider.notifier).update((state) {
              return {...state, id: val.round()};
            });
          },
        ),
        Text(
          "Selected: $currentValue",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.surveyData['questions'] as List;
    final expandedCategories = ref.watch(expandedCategoriesProvider);

    // Group questions by category (you might need to adjust this based on your data structure)
    final Map<String, List<Map<String, dynamic>>> categorizedQuestions = {};

    for (var question in questions) {
      final category = question['category'] ?? 'General';
      if (!categorizedQuestions.containsKey(category)) {
        categorizedQuestions[category] = [];
      }
      categorizedQuestions[category]!.add(question);
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => {
            // Use GoRouter's pop() to handle back navigation
            if (GoRouter.of(context).canPop())
              {
                GoRouter.of(context).pop(), // This pops the current route
              }
            else
              {
                // If there's no route to pop, go to a default route (e.g., home)
                GoRouter.of(
                  context,
                ).go(Routes.home), // Go to the home route or a fallback
              },
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.surveyData['title'] ?? 'Survey',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              'Site: ${widget.siteCode}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.info_circle),
            onPressed: () {
              UAlert.show(
                title: "Survey Info",
                message:
                    widget.surveyData['description'] ??
                    'No description available',
                context: context,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Survey info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.surveyData['title'] ?? 'Survey',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.surveyData['description'] != null)
                    Text(
                      widget.surveyData['description']!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(
                        Iconsax.document_text,
                        '${questions.length} Questions',
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Iconsax.clock,
                        '${questions.length * 2} min approx',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Questions list
            Expanded(
              child: ListView(
                controller: _scrollController,
                children: [
                  ...categorizedQuestions.entries.map((entry) {
                    final category = entry.key;
                    final categoryQuestions = entry.value;
                    final isExpanded = expandedCategories.contains(category);

                    return Column(
                      children: [
                        _buildCategoryHeader(
                          category,
                          categoryQuestions.length,
                          isExpanded,
                        ),
                        if (isExpanded)
                          ...categoryQuestions.asMap().entries.map((
                            questionEntry,
                          ) {
                            final index = questionEntry.key;
                            final question = questionEntry.value;
                            return _buildQuestionCard(
                              question,
                              index + 1,
                              category,
                            );
                          }),
                      ],
                    );
                  }),
                  const SizedBox(height: 80), // Space for submit button
                ],
              ),
            ),
          ],
        ),
      ),
      // FLOATING ACTION BUTTON FOR SUBMIT
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: isSubmitting ? null : _submitSurvey,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          icon: isSubmitting
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
              : const Icon(Iconsax.send_2),
          label: Text(isSubmitting ? 'Submitting...' : 'Submit Survey'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.blue.shade50,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
