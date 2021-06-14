import 'package:dio/dio.dart';
import 'package:indoor_map_app/model/comment_model.dart';
import 'package:indoor_map_app/model/post_model.dart';

class PostsService {
  //get
  //post
  //update
  //patch
  //delete

  Future<List<PostModel>> loadPosts() async{
    try {
      var response = await Dio().get("https://jsonplaceholder.typicode.com/posts");
      List<PostModel> posts = List() ;
      for(int i = 0 ; i < (response.data as List).length ; i++ ){
        PostModel postModel = PostModel.fromJson(response.data[i]) ;
        posts.add(postModel) ;
      }
      return posts ;
    } catch (e) {
      print(e);
      return [];
    }
  }

 Future<List<CommentModel>> loadPostComments(int postId) async{
    try {
      var response = await Dio().get(
        "https://jsonplaceholder.typicode.com/comments"
      , queryParameters: {
          "postId" : postId
      });
      List<CommentModel> comments = List() ;
      for(int i = 0 ; i < (response.data as List).length ; i++ ){
        CommentModel commentModel = CommentModel.fromJson(response.data[i]) ;
        comments.add(commentModel) ;
      }
      return comments ;
    } catch (e) {
      print(e);
      return [];
    }
  }
}