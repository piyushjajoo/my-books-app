import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

Future<List<Book>> fetchBooks() async {
  final response = await http.get(
    Uri.parse(
        'http://localhost:8080/users/5e877e44-c2ac-4828-a27a-ffcb38f0e205/books'),
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
    },
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final List t = json.decode(response.body);
    final List<Book> books = t.map((item) => Book.fromJson(item)).toList();
    return books;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load books');
  }
}

Future<void> addBook(String bookName) async {
  final response = await http.post(
    Uri.parse(
        'http://localhost:8080/users/5e877e44-c2ac-4828-a27a-ffcb38f0e205/books'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'book_name': bookName,
    }),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    // then parse the JSON.
    print("book added successfully");
    return;
  }

  throw Exception("Failed to add book");
}

class Book {
  final String id;
  final String bookName;
  final String startedAt;
  final String finishedAt;
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
