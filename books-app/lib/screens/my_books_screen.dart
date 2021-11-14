import 'package:books_app/models/book.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyBooksScreen extends StatefulWidget {
  static const String id = 'my_books_screen';

  const MyBooksScreen({Key? key}) : super(key: key);

  @override
  State<MyBooksScreen> createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends State<MyBooksScreen> {
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
        title: const Text("My Books"),
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
    );
  }
}
