import 'package:flutter/material.dart';
import 'package:mapmobile/models/map_model.dart';
import 'package:mapmobile/pages/Book/widgets/booklist.dart';
import 'package:mapmobile/pages/Book/widgets/categorysidebar.dart';
import 'package:mapmobile/pages/Book/widgets/genresidebar.dart';
import 'package:mapmobile/pages/Book/widgets/header.dart';
import 'package:mapmobile/services/genreservice.dart';
import 'package:mapmobile/services/productservice.dart';
import 'package:mapmobile/shared/text.dart';
import 'package:provider/provider.dart';

class Book extends StatefulWidget {
  const Book({super.key});

  @override
  State<Book> createState() => _BookState();
}

class _BookState extends State<Book> {
  List<dynamic> books = [];
  List<dynamic> genres = [];
  int cid = 0;
  int gid = 0;
  int sid = 0;
  Future<void> onCateChange(int categoryId) async {
    cid = categoryId;
    getGenreByCate(categoryId).then((res) {
      setState(() {
        genres = res.data['data']['list'];
      });
    });

    getBook(
            categoryId: categoryId,
            streetId: getStreet().streetId,
            storeId: sid)
        .then((res) {
      setState(() {
        books = res.data['data']['list'];
      });
    });
  }

  Future<void> onGenreChange(int genreId) async {
    gid = genreId;
    getBook(
            categoryId: cid,
            genreId: genreId,
            streetId: getStreet().streetId,
            storeId: sid)
        .then((res) {
      setState(() {
        books = res.data['data']['list'];
      });
    });
  }

  Future<void> onTextChange(String text) async {
    print("text change api... $text");
    getBook(
            categoryId: cid,
            genreId: gid,
            search: text,
            streetId: getStreet().streetId,
            storeId: sid)
        .then((res) {
      print("get book ${res.data['data']['list']}");
      setState(() {
        books = res.data['data']['list'];
      });
    });
  }

  Future<void> onStoreChange(int storeId) async {
    sid = storeId;
    getBook(
            categoryId: cid,
            genreId: gid,
            streetId: getStreet().streetId,
            storeId: storeId)
        .then((res) {
      setState(() {
        books = res.data['data']['list'];
      });
    });
  }

  @override
  void initState() {
    super.initState();

    getBook(streetId: getStreet().streetId).then((res) {
      setState(() {
        books = res.data['data']['list'];
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
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.only(bottom: 40),
                child: Header(
                  onTextChange: onTextChange,
                )),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                    flex: 3,
                    child: Container(
                        color: Colors.white,
                        width: double.infinity,
                        padding: const EdgeInsets.only(right: 10),
                        child: BookList(books: books))),
                Flexible(
                    flex: 2,
                    child: Column(
                      children: [
                        Consumer<MapModel>(builder: (context, value, child) {
                          var model = context.read<MapModel>();
                          List<dynamic> locations =
                              model.locations as List<dynamic>;
                          return DropdownButton(
                            value: sid,
                            items: [
                              const DropdownMenuItem(
                                value: 0,
                                child: DynamicText(text: "Tổng hợp"),
                              ),
                              ...locations
                                  .where((loc) => loc['storeId'] != 0)
                                  .map((loc) => DropdownMenuItem(
                                      value: loc['storeId'],
                                      child:
                                          DynamicText(text: loc['storeName'])))
                            ],
                            onChanged: (v) {
                              onStoreChange(v as int);
                            },
                            isExpanded: true,
                          );
                        }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GenreSidebar(
                              genres: genres,
                              onGenreChange: onGenreChange,
                            ),
                            CategorySidebar(
                              onCateChange: onCateChange,
                            )
                          ],
                        ),
                      ],
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
