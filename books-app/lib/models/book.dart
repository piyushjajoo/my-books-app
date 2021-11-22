import 'package:intl/intl.dart';

class Book {
  final String id;
  final String bookName;
  final String startedAt;
  String finishedAt;
  bool liked;

  Book({
    required this.id,
    required this.bookName,
    required this.startedAt,
    required this.finishedAt,
    required this.liked,
  });

  factory Book.fromJson(Map<String, dynamic> book) {
    final DateFormat parser = DateFormat("yyyy-MM-ddThh:mm:ss");
    final DateFormat niceFormatter = DateFormat("MM/dd/yyyy hh:mm:ss");

    return Book(
      id: book['id'],
      bookName: book['book_name'],
      startedAt: niceFormatter.format(parser.parseUTC(book['started_at'])),
      finishedAt: book['finished_at'] != null
          ? niceFormatter.format(parser.parseUTC(book['finished_at']))
          : "",
      liked: book['liked'],
    );
  }
}
