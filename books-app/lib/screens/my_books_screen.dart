import 'package:books_app/models/book.dart';
import 'package:books_app/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:books_app/models/book.dart' as book;

class MyBooksScreen extends StatefulWidget {
  static const String id = 'my_books_screen';

  const MyBooksScreen({Key? key}) : super(key: key);

  @override
  State<MyBooksScreen> createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends State<MyBooksScreen> {
  final _auth = FirebaseAuth.instance;

  List<Book> booksList = <Book>[];
  final addBookController = TextEditingController();
  final _formKey = GlobalKey<FormFieldState>();
  late final String userId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser().whenComplete(() {
      _fetchBooks().whenComplete(() {
        setState(() {});
      });
    });
  }

  Future<void> _getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // fetch the userId from astra db for the user
        final userDetails = await fetchUser(user.email!);
        userId = userDetails.id;
      } else {
        // Navigate to welcome screen
        Navigator.pushNamed(context, WelcomeScreen.id);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchBooks() async {
    try {
      final books = await fetchBooks(userId);
      booksList = books;
      setState(() {});
    } catch (e) {
      booksList = <Book>[];
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Books"),
      ),
      body: booksList.isNotEmpty
          ? RefreshIndicator(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: booksList.length,
                itemBuilder: (context, index) {
                  if (booksList.isEmpty) {
                    return const Text('No books yet');
                  } else {
                    return _buildBookCard(booksList[index]);
                  }
                },
              ),
              onRefresh: _fetchBooks,
            )
          : const Center(
              child: CircularProgressIndicator(),
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
                            autofocus: true,
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
                            addBook(addBookController.text, userId);
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

  Future<void> _updateBook(Book book) async {
    try {
      await updateBook(book, userId);
      _fetchBooks();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _deleteBook(String bookId) async {
    try {
      await deleteBook(bookId, userId);
      _fetchBooks();
    } catch (e) {
      print(e);
    }
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
                      // Call PUT api and rebuild
                      book.liked = !book.liked;
                      _updateBook(book);
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
                      // Call Delete api and rebuild
                      _deleteBook(book.id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
