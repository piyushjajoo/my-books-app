import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

Future<List<Book>> fetchBooks(String userId) async {
  final response = await http.get(
    Uri.parse(
      'http://{host}/users/:userId:/books'
          .replaceFirst(':userId:', userId)
          .replaceFirst('{host}', GlobalConfiguration().get('booksServerHost')),
    ),
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

Future<void> addBook(String bookName, String userId) async {
  final response = await http.post(
    Uri.parse(
      'http://{host}/users/:userId:/books'
          .replaceFirst(':userId:', userId)
          .replaceFirst('{host}', GlobalConfiguration().get('booksServerHost')),
    ),
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

Future<void> updateBook(Book book, String userId) async {
  final DateFormat parser = DateFormat("yyyy-MM-ddThh:mm:ss.SSS");
  final DateFormat niceFormatter = DateFormat("MM/dd/yyyy hh:mm:ss");

  final response = await http.put(
    Uri.parse(
      'http://{host}/users/:userId:/books/:bookId:'
          .replaceFirst(':userId:', userId)
          .replaceFirst(":bookId:", book.id)
          .replaceFirst('{host}', GlobalConfiguration().get('booksServerHost')),
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'book_name': book.bookName,
      'liked': book.liked,
      'started_at': parser.format(niceFormatter.parseUTC(book.startedAt)) + "Z",
      'finished_at': book.finishedAt.isNotEmpty
          ? parser.format(niceFormatter.parseUTC(book.finishedAt)) + "Z"
          : "",
    }),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    // then parse the JSON.
    print("book updated successfully");
    return;
  }

  throw Exception("Failed to update book");
}

Future<void> deleteBook(String bookId, String userId) async {
  final response = await http.delete(
    Uri.parse(
      'http://{host}/users/:userId:/books/:bookId:'
          .replaceFirst(':userId:', userId)
          .replaceFirst(":bookId:", bookId)
          .replaceFirst('{host}', GlobalConfiguration().get('booksServerHost')),
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    // then parse the JSON.
    print("book deleted successfully");
    return;
  }

  throw Exception("Failed to delete book");
}

Future<void> registerUser(
    String email, String firstName, String lastName) async {
  final response = await http.post(
    Uri.parse(
      'http://{host}/users'
          .replaceFirst('{host}', GlobalConfiguration().get('booksServerHost')),
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
    }),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    // then parse the JSON.
    print("user registered successfully");
    return;
  }

  throw Exception("Failed to register the user");
}

Future<User> fetchUser(String email) async {
  final response = await http.get(
    Uri.parse(
      'http://{host}/users'
          .replaceFirst('{host}', GlobalConfiguration().get('booksServerHost')),
    ).replace(queryParameters: {'email': email}),
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
    },
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return User.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load user');
  }
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

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String createdAt;
  final String modifiedAt;

  User(
      {required this.id,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.createdAt,
      required this.modifiedAt});

  factory User.fromJson(Map<String, dynamic> user) {
    final DateFormat parser = DateFormat("yyyy-MM-ddThh:mm:ss");
    final DateFormat niceFormatter = DateFormat("MM/dd/yyyy hh:mm:ss");

    return User(
      id: user['id'],
      email: user['email'],
      firstName: user['first_name'],
      lastName: user['last_name'],
      createdAt: niceFormatter.format(parser.parseUTC(user['created_at'])),
      modifiedAt: niceFormatter.format(parser.parseUTC(user['modified_at'])),
    );
  }
}
