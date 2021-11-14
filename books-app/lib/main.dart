import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Future<List<Book>> fetchBooks() async {
  final response = await http.get(
    Uri.parse(
        'http://10.0.2.2:8080/users/5e877e44-c2ac-4828-a27a-ffcb38f0e205/books'),
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

void main() {
  runApp(const MyBooksApp());
}

class MyBooksApp extends StatelessWidget {
  const MyBooksApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Books App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyBooksPage(title: 'My Books'),
    );
  }
}

class MyBooksPage extends StatefulWidget {
  const MyBooksPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyBooksPage> createState() => _MyBooksPageState();
}

class _MyBooksPageState extends State<MyBooksPage> {
  late Future<List<Book>> futureBooks;
  final addBookController = TextEditingController();
  final _formKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    futureBooks = fetchBooks();
  }

  Future<void> _fetchBooks() async {
    setState(() {
      futureBooks = fetchBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Book>>(
        future: futureBooks,
        builder: (context, books) {
          if (books.hasData) {
            return RefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              child: _buildBooksCards(books.data!),
              onRefresh: _fetchBooks,
            );
          } else if (books.hasError) {
            return Text('${books.error}');
          }
          // By default, show a loading spinner
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  scrollable: true,
                  title: const Text("Add Book"),
                  content: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            key: _formKey,
                            controller: addBookController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Book Name cannot be empty";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Book Name',
                              icon: Icon(
                                Icons.menu_book,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    Center(
                      child: ElevatedButton(
                        child: const Text("Submit"),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            addBook(addBookController.text);
                            addBookController.clear();
                            _fetchBooks();
                            Navigator.pop(context);
                          }
                        },
                      ),
                    )
                  ],
                );
              });
        },
        tooltip: 'Add Book',
        child: const Icon(Icons.my_library_books),
      ),
    );
  }

  Widget _buildBooksCards(List<Book>? books) {
    var _bookCards = <Widget>[];
    for (var book in books!) {
      _bookCards.add(_buildBookCard(book));
    }
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: _bookCards,
      ),
    );
  }

  Container _buildBookCard(Book? book) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: 200,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: Colors.blue[50],
          elevation: 5,
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.menu_book,
                        color: Colors.blue,
                      ),
                    ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          book!.bookName,
                          style: const TextStyle(
                            fontSize: 25.0,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "Started At",
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        book.startedAt,
                        style: const TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        book.liked ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        // Call PUT api and call rebuild
                        setState(() {
                          book.liked = !book.liked;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.done,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        // TODO call PUT API to mark the book finished and
                        // Instead of Started At, change to Finished At
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        // TODO call DELETE API and rebuild to remove the card
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
