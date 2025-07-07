import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:betwizz_app/features/channels/models/strategy_model.dart';
import 'package:betwizz_app/features/channels/repositories/strategy_repository.dart';

// FutureProvider to fetch the list of strategies.
// It depends on strategyRepositoryProvider to get an instance of StrategyRepository.
final strategiesProvider = FutureProvider<List<StrategyModel>>((ref) async {
  final strategyRepository = ref.watch(strategyRepositoryProvider);
  return strategyRepository.getStrategies();
});

// Example of a more complex notifier if state manipulation beyond fetching is needed later:
//
// class StrategyVaultNotifier extends StateNotifier<AsyncValue<List<StrategyModel>>> {
//   final StrategyRepository _repository;
//
//   StrategyVaultNotifier(this._repository) : super(const AsyncValue.loading()) {
//     _fetchStrategies();
//   }
//
//   Future<void> _fetchStrategies() async {
//     try {
//       final strategies = await _repository.getStrategies();
//       state = AsyncValue.data(strategies);
//     } catch (e, s) {
//       state = AsyncValue.error(e, s);
//     }
//   }
//
//   Future<void> refreshStrategies() async {
//     state = const AsyncValue.loading();
//     await _fetchStrategies();
//   }
//
//   // Add other methods like addStrategy, deleteStrategy etc.
// }
//
// final strategyVaultNotifierProvider =
//     StateNotifierProvider<StrategyVaultNotifier, AsyncValue<List<StrategyModel>>>((ref) {
//   return StrategyVaultNotifier(ref.watch(strategyRepositoryProvider));
// });
