import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/invoice.dart';

abstract class PrinterRepository {
  Future<Either<Failure, bool>> isPrinterConnected();
  Future<Either<Failure, void>> connectPrinter();
  Future<Either<Failure, void>> disconnectPrinter();
  Future<Either<Failure, void>> printInvoice(Invoice invoice);
  Future<Either<Failure, void>> printReceipt(Invoice invoice);
  Future<Either<Failure, List<String>>> getConnectedPrinters();
  Future<Either<Failure, void>> selectPrinter(String printerId);
} 