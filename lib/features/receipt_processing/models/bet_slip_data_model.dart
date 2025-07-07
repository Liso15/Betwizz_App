import 'package:flutter/foundation.dart' show immutable;

@immutable
class BetSlipData {
  final String? bookmaker;
  final List<String> selections; // Could be List<Map<String, String>> for {event: "...", pick: "..."}
  final double? stake;
  final double? totalOdds; // Often called 'Price' or 'Returns' on slips can be ambiguous
  final double? potentialWinnings;
  final String? betType; // e.g., "Single", "Multiple", "System"
  final String? transactionId;
  final DateTime? betDateTime;

  const BetSlipData({
    this.bookmaker,
    this.selections = const [],
    this.stake,
    this.totalOdds,
    this.potentialWinnings,
    this.betType,
    this.transactionId,
    this.betDateTime,
  });

  // For easy debugging
  @override
  String toString() {
    return 'BetSlipData(\n'
           '  bookmaker: $bookmaker,\n'
           '  selections: $selections,\n'
           '  stake: $stake,\n'
           '  totalOdds: $totalOdds,\n'
           '  potentialWinnings: $potentialWinnings,\n'
           '  betType: $betType,\n'
           '  transactionId: $transactionId,\n'
           '  betDateTime: $betDateTime\n'
           ')';
  }

  // Optional: A method to check if any data was actually parsed
  bool get isEmpty {
    return bookmaker == null &&
           selections.isEmpty &&
           stake == null &&
           totalOdds == null &&
           potentialWinnings == null &&
           betType == null &&
           transactionId == null &&
           betDateTime == null;
  }
}
