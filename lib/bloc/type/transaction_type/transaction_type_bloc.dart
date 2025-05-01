import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_event.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_state.dart';
import 'package:the_djenggot/repository/type/transaction_type_repository.dart';

class TransactionTypeBloc
    extends Bloc<TransactionTypeEvent, TransactionTypeState> {
  final TransactionTypeRepository _repository;

  TransactionTypeBloc(this._repository) : super(TransactionTypeLoading()) {
    on<LoadTransactionTypes>((event, emit) async {
      emit(TransactionTypeLoading());
      try {
        final transactionTypes = await _repository.getAllTransactionTypes();
        emit(TransactionTypeLoaded(transactionTypes));
      } catch (e) {
        emit(TransactionTypeError(e.toString()));
      }
    });

    on<AddTransactionType>((event, emit) async {
      try {
        await _repository.addTransactionType(
          event.name,
          icon: event.icon,
          needEvidence: event.needEvidence ?? true,
        );
        final transactionTypes = await _repository.getAllTransactionTypes();
        emit(TransactionTypeLoaded(transactionTypes));
      } catch (e) {
        emit(TransactionTypeError(e.toString()));
      }
    });

    on<UpdateTransactionType>((event, emit) async {
      try {
        await _repository.updateTransactionType(
          event.transactionType,
          event.newName,
          icon: event.icon,
          needEvidence: event.needEvidence,
        );
        final transactionTypes = await _repository.getAllTransactionTypes();
        emit(TransactionTypeLoaded(transactionTypes));
      } catch (e) {
        emit(TransactionTypeError(e.toString()));
      }
    });

    on<DeleteTransactionType>((event, emit) async {
      try {
        await _repository.deleteTransactionType(event.id);
        final transactionTypes = await _repository.getAllTransactionTypes();
        emit(TransactionTypeLoaded(transactionTypes));
      } catch (e) {
        emit(TransactionTypeError(e.toString()));
      }
    });

    on<SearchTransactionTypes>((event, emit) async {
      try {
        final transactionTypes =
            await _repository.searchTransactionTypes(event.query);
        emit(TransactionTypeLoaded(transactionTypes));
      } catch (e) {
        emit(TransactionTypeError(e.toString()));
      }
    });
  }
}
