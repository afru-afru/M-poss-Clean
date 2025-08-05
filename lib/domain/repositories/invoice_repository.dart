import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/invoice.dart';

abstract class InvoiceRepository {
  Future<Either<Failure, List<Invoice>>> getInvoices();
  Future<Either<Failure, Invoice>> getInvoiceById(String id);
  Future<Either<Failure, Invoice>> createInvoice(Invoice invoice);
  Future<Either<Failure, Invoice>> updateInvoice(Invoice invoice);
  Future<Either<Failure, void>> deleteInvoice(String id);
  Future<Either<Failure, List<Invoice>>> getInvoicesByStatus(String status);
  Future<Either<Failure, List<Invoice>>> getInvoicesByDateRange(DateTime start, DateTime end);
} 