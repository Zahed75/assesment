// lib/features/result/model/survey_result_model.dart
class SurveyResultModel {
  String? message;
  int? responseId;
  double? obtainedScore; // Changed to double
  int? totalScore;
  double? percentage;
  String? submittedBy;
  String? submittedUserPhone;
  String? submittedAt;
  String? siteCode;
  String? outletCode;
  List<SubmittedQuestions>? submittedQuestions;
  int? userId;
  String? surveyTitle;

  SurveyResultModel({
    this.message,
    this.responseId,
    this.obtainedScore, // Changed to double
    this.totalScore,
    this.percentage,
    this.submittedBy,
    this.submittedUserPhone,
    this.submittedAt,
    this.siteCode,
    this.outletCode,
    this.submittedQuestions,
    this.userId,
    this.surveyTitle,
  });

  factory SurveyResultModel.fromJson(Map<String, dynamic> json) {
    return SurveyResultModel(
      message: json['message'],
      responseId: json['response_id'],
      obtainedScore: json['obtained_score']
          ?.toDouble(), // Handle both int and double
      totalScore: json['total_score'],
      percentage: json['percentage']?.toDouble(),
      submittedBy: json['submitted_by'],
      submittedUserPhone: json['submitted_user_phone'],
      submittedAt: json['submitted_at'],
      siteCode: json['site_code'],
      outletCode: json['outlet_code'],
      submittedQuestions: json['submitted_questions'] != null
          ? (json['submitted_questions'] as List)
                .map((v) => SubmittedQuestions.fromJson(v))
                .toList()
          : null,
      userId: json['user_id'],
      surveyTitle: json['survey_title'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = this.message;
    data['response_id'] = this.responseId;
    data['obtained_score'] = this.obtainedScore;
    data['total_score'] = this.totalScore;
    data['percentage'] = this.percentage;
    data['submitted_by'] = this.submittedBy;
    data['submitted_user_phone'] = this.submittedUserPhone;
    data['submitted_at'] = this.submittedAt;
    data['site_code'] = this.siteCode;
    data['outlet_code'] = this.outletCode;
    if (this.submittedQuestions != null) {
      data['submitted_questions'] = this.submittedQuestions!
          .map((v) => v.toJson())
          .toList();
    }
    data['user_id'] = this.userId;
    data['survey_title'] = this.surveyTitle;
    return data;
  }
}

// lib/features/result/model/survey_result_model.dart
class SubmittedQuestions {
  int? questionId;
  String? questionText;
  String? type;
  int? maxMarks;
  double? obtainedMarks;
  dynamic answer; // Changed from String? to dynamic

  SubmittedQuestions({
    this.questionId,
    this.questionText,
    this.type,
    this.maxMarks,
    this.obtainedMarks,
    this.answer, // Changed to dynamic
  });

  factory SubmittedQuestions.fromJson(Map<String, dynamic> json) {
    return SubmittedQuestions(
      questionId: json['question_id'],
      questionText: json['question_text'],
      type: json['type'],
      maxMarks: json['max_marks'],
      obtainedMarks: json['obtained_marks']?.toDouble(),
      answer: json['answer']?.toString(), // Convert any type to string
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['question_id'] = this.questionId;
    data['question_text'] = this.questionText;
    data['type'] = this.type;
    data['max_marks'] = this.maxMarks;
    data['obtained_marks'] = this.obtainedMarks;
    data['answer'] = this.answer
        ?.toString(); // Ensure it's string when serializing
    return data;
  }
}
