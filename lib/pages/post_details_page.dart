import 'package:flutter/material.dart';
import 'package:indoor_map_app/model/comment_model.dart';
import 'package:indoor_map_app/model/post_model.dart';
import 'package:indoor_map_app/services/posts_service.dart';

class PostDetailsPage extends StatefulWidget {
  @override
  _PostDetailsPageState createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  List<CommentModel> comments = [];

  @override
  Widget build(BuildContext context) {
    PostModel post = ModalRoute.of(context).settings.arguments as PostModel;

    if (comments.isEmpty) {
      PostsService().loadPostComments(post.id).then((value) => {
            setState(() => {comments = value})
          });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                margin: EdgeInsets.all(12),
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        post.title,
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(post.body , style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.normal),),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(top: 12, left: 22),
                child: Text(
                  "comments",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                child: ListView.builder(
                    itemCount: comments.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.all(12),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comments[index].email,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(comments[index].body),
                            ],
                          ),
                        ),
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
