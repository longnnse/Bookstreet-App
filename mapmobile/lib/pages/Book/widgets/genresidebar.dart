import 'package:flutter/material.dart';
import 'package:mapmobile/shared/text.dart';

class GenreSidebar extends StatefulWidget {
  const GenreSidebar(
      {super.key, required this.genres, required this.onGenreChange});
  final List<dynamic> genres;
  final Function onGenreChange;
  @override
  State<GenreSidebar> createState() => _GenreSidebar();
}

class _GenreSidebar extends State<GenreSidebar> {
  int selectedGenre = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   getAllGenre().then((res) {
  //     print(res.data);
  //     setState(() {
  //       genres = res.data;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).size.height / 3 -
          100,
      child: SingleChildScrollView(
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  selectedGenre = 0;
                  widget.onGenreChange(0);
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 6,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: selectedGenre == 0
                        ? const Color.fromARGB(255, 215, 14, 0)
                        : Colors.white),
                child: DynamicText(
                  text: "Tất cả",
                  textStyle: TextStyle(
                      color: selectedGenre == 0 ? Colors.white : Colors.black),
                ),
              ),
            ),
            ...widget.genres.map((cate) {
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedGenre = cate["genreId"];
                    widget.onGenreChange(cate["genreId"]);
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 6,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: cate["genreId"] == selectedGenre
                          ? const Color.fromARGB(255, 215, 14, 0)
                          : Colors.white),
                  child: DynamicText(
                    text: cate["genreName"],
                    textStyle: TextStyle(
                        color: cate["genreId"] == selectedGenre
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
