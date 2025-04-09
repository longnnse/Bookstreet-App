import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mapmobile/models/map_model.dart';
import 'package:mapmobile/pages/author/author_detail.dart';
import 'package:mapmobile/services/author_service.dart';
import 'package:provider/provider.dart';

class AuthorPage extends StatefulWidget {
  const AuthorPage({super.key});

  @override
  State<AuthorPage> createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> {
  List<dynamic> authors = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await getAllAuthorData();
    });
  }

  Future<void> getAllAuthorData() async {
    setState(() {
      isLoading = true;
    });
    await getAllAuthor().then((res) {
      setState(() {
        authors = res;
        isLoading = false;
      });
    });
  }

  MapModel getStreet() {
    final model = Provider.of<MapModel>(context, listen: false);
    return model;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : authors.isEmpty
                ? const Center(
                    child: Text("Không tìm thấy tác giả"),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: authors.length,
                    itemBuilder: (context, index) {
                      final author = authors[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AuthorDetail(
                                  authorId: author['authorId'].toString()),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: author['urlImage'] != null
                                      ? CachedNetworkImage(
                                          imageUrl: author['urlImage']!,
                                          fit: BoxFit.fill,
                                          width: double.infinity,
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                            'assets/images/author_avatar.jpg',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/author_avatar.jpg',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    author['authorName'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
