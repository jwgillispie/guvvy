class Vote {
  final int congress;
  final String chamber;
  final int rollNumber;
  final DateTime date;
  final int session;
  final int yeaCount;
  final int nayCount;
  final String? voteResult;
  final String voteQuestion;
  final String? billNumber;
  
  Vote({
    required this.congress,
    required this.chamber,
    required this.rollNumber,
    required this.date,
    required this.session,
    required this.yeaCount,
    required this.nayCount,
    this.voteResult,
    required this.voteQuestion,
    this.billNumber,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      congress: json['congress'] as int,
      chamber: json['chamber'] as String,
      rollNumber: json['rollnumber'] as int,
      date: DateTime.parse(json['date'] as String),
      session: json['session'] as int,
      yeaCount: json['yea_count'] as int,
      nayCount: json['nay_count'] as int,
      voteResult: json['vote_result'] as String?,
      voteQuestion: json['vote_question'] as String,
      billNumber: json['bill_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'congress': congress,
      'chamber': chamber,
      'rollNumber': rollNumber,
      'date': date.toIso8601String(),
      'session': session,
      'yeaCount': yeaCount,
      'nayCount': nayCount,
      'voteResult': voteResult,
      'voteQuestion': voteQuestion,
      'billNumber': billNumber,
    };
  }
}