import 'package:assesment/common_ui/widgets/alerts/u_alert.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers for Riverpod
final locationProvider = StateProvider<Position?>((ref) => null);
final imageProvider = StateProvider<Map<int, String?>>((ref) => {});
final detectedLocationProvider = StateProvider<Map<int, Map<String, double>?>>(
  (ref) => {},
);
final answersProvider = StateProvider<Map<int, dynamic>>((ref) => {});

class QuestionScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> surveyData;

  const QuestionScreen({super.key, required this.surveyData});

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  bool isSubmitting = false;

  Null get submitSurvey => null;

  @override
  void initState() {
    super.initState();
    // Initial logic from GetX to reset answers
    ref.read(answersProvider.notifier).state = {};
    ref.read(locationProvider.notifier).state = null;

    _getLocation();
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
        context: context, // Pass context here
      );
      return;
    }
    final position = await Geolocator.getCurrentPosition();
    ref.read(locationProvider.notifier).state = position;
  }

  Future<void> pickImage(int questionId) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      ref.read(imageProvider.notifier).state[questionId] = image.path;
    }
  }

  Future<void> uploadFile(int questionId) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      ref.read(imageProvider.notifier).state[questionId] =
          result.files.single.path;
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
        context: context, // Pass context here
      );
      return;
    }
    final position = await Geolocator.getCurrentPosition();
    ref.read(detectedLocationProvider.notifier).state[questionId] = {
      "latitude": position.latitude,
      "longitude": position.longitude,
    };
  }

  Widget buildQuestion(Map<String, dynamic> question) {
    final id = question['id'];
    final type = question['type'];
    final text = question['text'];
    final marks = question['marks'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (marks != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Marks: $marks",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // yes/no
            if (type == 'yesno') ...[
              Row(
                children: (question['choices'] as List).map<Widget>((choice) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilledButton.tonal(
                        onPressed: () => setState(() {
                          ref.read(answersProvider.notifier).state[id] =
                              choice['id'];
                        }),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              ref.watch(answersProvider)[id] == choice['id']
                              ? Colors.green
                              : null,
                        ),
                        child: Text(choice['text']),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // single-choice (MCQ)
            if (type == 'choice') ...[
              ...(question['choices'] as List).map<Widget>((choice) {
                return RadioListTile(
                  title: Text(choice['text']),
                  value: choice['id'],
                  groupValue: ref.watch(answersProvider)[id],
                  onChanged: (val) => setState(() {
                    ref.read(answersProvider.notifier).state[id] = val;
                  }),
                );
              }),
            ],

            // multiple_scoring (single pick, scored by choice.marks)
            if (type == 'multiple_scoring') ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (question['choices'] as List).map<Widget>((choice) {
                  return RadioListTile(
                    title: Text('${choice['text']} (${choice['marks']} marks)'),
                    value: choice['id'],
                    groupValue: ref.watch(answersProvider)[id],
                    onChanged: (val) => setState(() {
                      ref.read(answersProvider.notifier).state[id] = val;
                    }),
                  );
                }).toList(),
              ),
            ],

            // image
            if (type == 'image') ...[
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => pickImage(id),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => uploadFile(id),
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload'),
                  ),
                ],
              ),
              if (ref.watch(imageProvider)[id] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Selected: ${ref.watch(imageProvider)[id]!.split("/").last}',
                  ),
                ),
            ],

            // location
            if (type == 'location') ...[
              FilledButton.icon(
                onPressed: () => detectLocation(id),
                icon: const Icon(Icons.location_on),
                label: const Text('Detect Location'),
              ),
              if (ref.watch(detectedLocationProvider)[id] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "${ref.watch(detectedLocationProvider)[id]!["latitude"]}, ${ref.watch(detectedLocationProvider)[id]!["longitude"]}",
                  ),
                ),
            ],

            // text / remarks
            if (type == 'text' || type == 'remarks') ...[
              TextField(
                controller: TextEditingController(),
                maxLines: 3,
                onChanged: (val) =>
                    ref.read(answersProvider.notifier).state[id] = val,
                decoration: const InputDecoration(
                  hintText: "Write your response...",
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            // linear
            if (type == 'linear') ...[
              const SizedBox(height: 12),
              Text(
                "Select value: ${ref.watch(answersProvider)[id] ?? question['min_value'] ?? 0}",
              ),
              Slider(
                min: (question['min_value'] ?? 0).toDouble(),
                max: (question['max_value'] ?? 20).toDouble(),
                divisions:
                    ((question['max_value'] ?? 20) -
                            (question['min_value'] ?? 0))
                        .toInt(),
                value:
                    (ref.watch(answersProvider)[id] ??
                            (question['min_value'] ?? 0))
                        .toDouble(),
                label:
                    "${ref.watch(answersProvider)[id] ?? question['min_value'] ?? 0}",
                onChanged: (val) => setState(() {
                  ref.read(answersProvider.notifier).state[id] = val.round();
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.surveyData['questions'] as List;

    return Scaffold(
      appBar: AppBar(title: Text(widget.surveyData['title'])),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) => buildQuestion(questions[index]),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: isSubmitting ? null : submitSurvey,
          child: isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Submit Survey'),
        ),
      ),
    );
  }
}
