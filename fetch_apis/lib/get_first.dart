import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

/// ===========================
/// POST MODEL (Manual Serialization)
/// ===========================


class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  // Convert JSON to Dart Object
  factory Post.fromJson(Map<String, dynamic> json) {  //Factory returns the same instance every time
    return Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

/// ===========================
/// POST SERVICE (Fetch Data)
/// ===========================
///
class PostService {

  static const String url = 'https://jsonplaceholder.typicode.com/posts';

  Future<List<Post>> fetchPosts() async {

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {

      List<dynamic> jsonData = json.decode(response.body);  //the API returns multiple items as a list of JSON objects
      //The app makes a GET request to the API.
      // The API returns a list of JSON objects like this
      return jsonData.map((item) => Post.fromJson(item)).toList();

      //map() goes through each item in jsonData.
      // Post.fromJson(item) converts each JSON object into a Post object.

      //List<Map<String, dynamic>> jsonData = [
      //   {'id': 1, 'title': 'Post One'},
      //   {'id': 2, 'title': 'Post Two'},
      //   {'id': 3, 'title': 'Post Three'}
      // ];

      //This part calls the factory constructor Post.fromJson() for each item in jsonData:


    } else {
      throw Exception('Failed to load posts');
    }
  }
}

/// ===========================
/// MAIN APP WIDGETS
/// ===========================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PostList(),
    );
  }
}

/// ===========================
/// POST LIST (Display Content)
/// ===========================
///

class PostList extends StatefulWidget {
  const PostList({super.key});

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  late Future<List<Post>> futurePosts;

  //futurePosts is a variable that holds the result of fetching posts from the internet.
  // Future<List<Post>> means this will get the data sometime in the future (because it's coming from an API).

  @override
  void initState() {  //runs only once when the screen (widget) is created.
    super.initState();
    futurePosts = PostService().fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Posts'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder (
        //FutureBuilder is a special widget that waits for the futurePosts to finish fetching data.
        // snapshot is the result of that future. It shows:
        // Whether the data is loading.
        // Whether there was an error.
        // Whether the data was fetched successfully.
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No posts found'));
          } else {
            // Show Posts
            List<Post> posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  title: Text(
                    'Post ${post.id}: ${post.title}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(post.body),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(post.id.toString()),
                  ),

                );
              },
            );
          }
        },
      ),
    );
  }
}
