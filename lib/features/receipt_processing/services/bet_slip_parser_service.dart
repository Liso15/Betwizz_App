import 'package:betwizz_app/features/receipt_processing/models/bet_slip_data_model.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:intl/intl.dart'; // For date parsing, if needed

abstract class BetSlipParserService {
  /// Parses raw OCR text, attempting to identify it as a Betway receipt
  /// and extract structured bet slip data.
  /// Returns [BetSlipData] or null if parsing fails or text doesn't match Betway format.
  BetSlipData? parseBetwayText(String rawOcrText);

  // Future methods could be:
  // BetSlipData? parseHollywoodBetsText(String rawOcrText);
  // BetSlipData? parseText(String rawOcrText, {String? expectedBookmaker});
}

class ExampleRegexBetSlipParserService implements BetSlipParserService {
  @override
  BetSlipData? parseBetwayText(String rawOcrText) {
    debugPrint("--- Attempting to parse Betway text (ExampleRegex) ---");
    // debugPrint("Raw OCR Text:\n$rawOcrText");

    // IMPORTANT: These regexes are EXAMPLES and highly UNRELIABLE without real data.
    // They are for demonstration purposes only and will likely need significant refinement
    // or a completely different approach (like line-by-line analysis, keyword spotting,
    // or even a simple ML model for classification/extraction) based on actual Betway receipt OCR output.

    String? bookmaker = "Betway (Example Parse)"; // Assume it's Betway if this parser is called
    List<String> selections = [];
    double? stake;
    double? totalOdds;
    double? potentialWinnings;
    String? betType;
    String? transactionId;
    DateTime? betDateTime;

    // --- Example Regexes (Illustrative) ---

    // Try to find Stake
    // Looks for "Stake", optional "R", then digits and decimals.
    final stakeRegex = RegExp(r"Stake(?: Amount)?:\s*R?([\d,]+\.?\d*)", caseSensitive: false);
    final stakeMatch = stakeRegex.firstMatch(rawOcrText);
    if (stakeMatch != null && stakeMatch.groupCount >= 1) {
      try {
        stake = double.tryParse(stakeMatch.group(1)!.replaceAll(',', ''));
        debugPrint("Found Stake: $stake");
      } catch (e) {
        debugPrint("Error parsing stake: ${stakeMatch.group(1)} -> $e");
      }
    }

    // Try to find Total Odds
    // Looks for "Total Odds", "Odds", or "Price", then digits and decimals.
    final oddsRegex = RegExp(r"(?:Total Odds|Odds|Price):\s*([\d,]+\.?\d*)", caseSensitive: false);
    final oddsMatch = oddsRegex.firstMatch(rawOcrText);
    if (oddsMatch != null && oddsMatch.groupCount >= 1) {
      try {
        totalOdds = double.tryParse(oddsMatch.group(1)!.replaceAll(',', ''));
        debugPrint("Found Total Odds: $totalOdds");
      } catch (e) {
        debugPrint("Error parsing total odds: ${oddsMatch.group(1)} -> $e");
      }
    }

    // Try to find Potential Winnings/Returns
    final winningsRegex = RegExp(r"(?:Potential Winnings|Potential Returns|To Pay|Returns):\s*R?([\d,]+\.?\d*)", caseSensitive: false);
    final winningsMatch = winningsRegex.firstMatch(rawOcrText);
    if (winningsMatch != null && winningsMatch.groupCount >= 1) {
        try {
            potentialWinnings = double.tryParse(winningsMatch.group(1)!.replaceAll(',', ''));
            debugPrint("Found Potential Winnings: $potentialWinnings");
        } catch (e) {
            debugPrint("Error parsing potential winnings: ${winningsMatch.group(1)} -> $e");
        }
    }


    // Try to find Bet Type (e.g., "Multiple Bet", "Single Bet")
    final betTypeRegex = RegExp(r"(Single Bet|Multiple Bet|System Bet)", caseSensitive: false);
    final betTypeMatch = betTypeRegex.firstMatch(rawOcrText);
    if (betTypeMatch != null) {
      betType = betTypeMatch.group(0); // Group 0 is the whole match
      debugPrint("Found Bet Type: $betType");
    }

    // Try to find Transaction ID (often alphanumeric, might be near "Bet ID" or "Ticket ID")
    // This is highly variable. Example: look for a long alphanumeric string.
    final transactionIdRegex = RegExp(r"(?:Bet ID|Ticket ID|Transaction ID|Ref No):\s*([a-zA-Z0-9-]+)", caseSensitive: false);
    final transactionIdMatch = transactionIdRegex.firstMatch(rawOcrText);
    if (transactionIdMatch != null && transactionIdMatch.groupCount >=1) {
        transactionId = transactionIdMatch.group(1);
        debugPrint("Found Transaction ID: $transactionId");
    }

    // Try to find Selections (VERY illustrative and likely to be inaccurate)
    // This might involve looking for lines with "vs" or team names, or lines under a "Selections" header.
    // For this stub, let's just grab a few lines that might look like selections.
    // A real parser would need much more sophisticated logic.
    final lines = rawOcrText.split('\n');
    bool inSelectionSection = false;
    for (final line in lines) {
        if (line.toLowerCase().contains("selections:") || line.toLowerCase().contains("my bets")) {
            inSelectionSection = true;
            continue;
        }
        if (inSelectionSection && line.trim().isNotEmpty) {
            // Example: look for lines with common sport terms or "vs"
            if (line.contains(RegExp(r"\b(vs|@|To Win)\b", caseSensitive: false)) ||
                (line.length > 10 && !line.toLowerCase().contains("stake") && !line.toLowerCase().contains("odds"))) {
                if (selections.length < 5) { // Limit to 5 example selections
                    selections.add(line.trim());
                    debugPrint("Found Potential Selection: ${line.trim()}");
                } else {
                    // break; // Stop after finding a few
                }
            }
        }
        // Heuristic to stop selection search
        if (inSelectionSection && (line.toLowerCase().contains("stake:") || line.toLowerCase().contains("total odds:"))) {
            inSelectionSection = false;
        }
    }
    if (selections.isEmpty && lines.length > 5) { // Fallback if no selections found via keywords
        // Try taking a few lines from the middle as a wild guess if no explicit section found
        // This is purely for demonstration that some text could be extracted.
        // int start = (lines.length / 3).round();
        // selections.addAll(lines.sublist(start, min(start + 3, lines.length)).map((l) => l.trim()).where((l) => l.isNotEmpty));
    }


    // Attempt to parse a date and time
    // Example: "2023/07/15 14:30" or "15 Jul 2023 02:30 PM"
    // This requires knowing the typical date formats on Betway slips.
    // Using a very generic regex here.
    final dateTimeRegex = RegExp(r"(\d{2,4}[-/]\d{1,2}[-/]\d{2,4})\s*(\d{1,2}:\d{2}(?::\d{2})?\s*(?:AM|PM)?)?", caseSensitive: false);
    final dateTimeMatch = dateTimeRegex.firstMatch(rawOcrText);
    if (dateTimeMatch != null) {
        String datePart = dateTimeMatch.group(1) ?? "";
        String timePart = dateTimeMatch.group(2) ?? "";
        String combinedDateTimeStr = "$datePart $timePart".trim();
        try {
            // Attempt common formats. This is very brittle.
            // A library for more robust date parsing from varied formats might be needed.
            if (combinedDateTimeStr.isNotEmpty) {
                 // Try a few common formats
                try { betDateTime = DateFormat("yyyy/MM/dd HH:mm").parse(combinedDateTimeStr); } catch (_) {}
                if (betDateTime == null) { try { betDateTime = DateFormat("dd/MM/yyyy HH:mm").parse(combinedDateTimeStr); } catch (_) {} }
                if (betDateTime == null) { try { betDateTime = DateFormat("dd MMM yyyy hh:mm a").parse(combinedDateTimeStr); } catch (_) {} }
                 // Add more DateFormat variations as needed based on observed slip formats
                if (betDateTime != null) debugPrint("Found Bet DateTime: $betDateTime");
            }
        } catch (e) {
            debugPrint("Error parsing date/time: $combinedDateTimeStr -> $e");
        }
    }


    // If no crucial information like stake or odds is found, maybe it's not a valid Betway slip OCR.
    // For this example, we'll return what we found.
    final parsedData = BetSlipData(
      bookmaker: bookmaker,
      selections: selections,
      stake: stake,
      totalOdds: totalOdds,
      potentialWinnings: potentialWinnings,
      betType: betType,
      transactionId: transactionId,
      betDateTime: betDateTime,
    );

    debugPrint("--- Betway Parsing Result (ExampleRegex) ---");
    debugPrint(parsedData.toString());

    // Only return data if something meaningful was parsed, otherwise return null.
    // For this stub, we always return it to show what the regexes did (or didn't do).
    return parsedData;
    // return parsedData.isEmpty ? null : parsedData; // A more realistic check
  }
}

// --- Riverpod Provider ---
import 'package:flutter_riverpod/flutter_riverpod.dart';

final betSlipParserServiceProvider = Provider<BetSlipParserService>((ref) {
  return ExampleRegexBetSlipParserService();
});
