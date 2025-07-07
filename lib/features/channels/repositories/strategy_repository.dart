import 'package:betwizz_app/features/channels/models/strategy_model.dart';

abstract class StrategyRepository {
  Future<List<StrategyModel>> getStrategies();
  // Future<StrategyModel?> getStrategyById(String id);
  // Future<void> addStrategy(StrategyModel strategy);
  // Future<void> updateStrategy(StrategyModel strategy);
  // Future<void> deleteStrategy(String id);
}

class MockStrategyRepository implements StrategyRepository {
  final List<StrategyModel> _mockStrategies = [
    StrategyModel(
      id: 'strat_001',
      title: 'The Accumulator King',
      description: 'A guide to building high-value accumulator bets with calculated risks. Focuses on major football leagues.',
      authorName: 'BettingPro101',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    StrategyModel(
      id: 'strat_002',
      title: 'Underdog Hunter SA Rugby',
      description: 'Identifying undervalued underdogs in South African rugby matches. Statistical analysis and form guide.',
      authorName: 'RugbyOracleZA',
      createdAt: DateTime.now().subtract(const Duration(days: 5, hours: 3)),
    ),
    StrategyModel(
      id: 'strat_003',
      title: 'Cricket In-Play Masterclass',
      description: 'Strategies for live betting on cricket matches, focusing on momentum shifts and player performance.',
      authorName: 'CaptainCricket',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
     StrategyModel(
      id: 'strat_004',
      title: 'Horse Racing Trifecta Tips',
      description: 'A detailed approach to selecting horses for Trifecta bets in local SA races.',
      authorName: 'PunterPete',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
    ),
  ];

  @override
  Future<List<StrategyModel>> getStrategies() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    // Simulate a chance of error for testing UI
    // if (Random().nextDouble() < 0.1) {
    //   throw Exception("Failed to fetch strategies due to a mock network error.");
    // }
    return List<StrategyModel>.from(_mockStrategies); // Return a copy
  }

  // Example implementations for other methods if needed:
  // @override
  // Future<StrategyModel?> getStrategyById(String id) async {
  //   await Future.delayed(const Duration(milliseconds: 300));
  //   try {
  //     return _mockStrategies.firstWhere((s) => s.id == id);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // @override
  // Future<void> addStrategy(StrategyModel strategy) async {
  //   await Future.delayed(const Duration(milliseconds: 500));
  //   _mockStrategies.add(strategy.copyWith(id: 'strat_${Random().nextInt(1000).toString().padLeft(3,'0')}'));
  // }
}

// --- Riverpod Provider ---
// Import Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';

final strategyRepositoryProvider = Provider<StrategyRepository>((ref) {
  // For now, we provide the mock implementation.
  // Later, this could be swapped for a real backend implementation (e.g., FirestoreStrategyRepository).
  return MockStrategyRepository();
});
