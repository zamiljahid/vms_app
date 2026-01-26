class ActionModel {
  String currentStatus;
  List<String> allowedActions;
  String message;
  dynamic qrData;

  ActionModel({
    required this.currentStatus,
    required this.allowedActions,
    required this.message,
    this.qrData,
  });

  factory ActionModel.fromJson(Map<String, dynamic> json) {
    return ActionModel(
      currentStatus: json['currentStatus'],
      allowedActions: List<String>.from(json['allowedActions'] ?? []),
      message: json['message'] ?? '',
      qrData: json['qrData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStatus': currentStatus,
      'allowedActions': allowedActions,
      'message': message,
      'qrData': qrData,
    };
  }
}