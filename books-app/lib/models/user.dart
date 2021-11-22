import 'package:intl/intl.dart';

class User {
  String id;
  String email;
  String firstName;
  String lastName;
  String createdAt;
  String modifiedAt;

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
