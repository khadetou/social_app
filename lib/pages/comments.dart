import 'package:flutter/material.dart';

class Comments extends StatefulWidget {
  const Comments({Key? key}) : super(key: key);

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  @override
  Widget build(BuildContext context) {
    return const Text("Comments");
  }
}

class Comment extends StatelessWidget {
  const Comment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text("Comment");
  }
}
