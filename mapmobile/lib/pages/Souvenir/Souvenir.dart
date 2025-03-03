import 'package:flutter/material.dart';
import 'package:mapmobile/models/map_model.dart';
import 'package:mapmobile/pages/Souvenir/widgets/SouvenirList.dart';
import 'package:mapmobile/pages/Souvenir/widgets/categorysidebar.dart';
import 'package:mapmobile/pages/Souvenir/widgets/header.dart';
import 'package:mapmobile/services/genreservice.dart';
import 'package:mapmobile/services/productservice.dart';
import 'package:provider/provider.dart';

class Souvenir extends StatefulWidget {
  const Souvenir({super.key});

  @override
  State<Souvenir> createState() => _SouvenirState();
}

class _SouvenirState extends State<Souvenir> {
  List<dynamic> Souvenirs = [];
  List<dynamic> genres = [];
  int cid = 0;
  int gid = 0;
  Future<void> onCateChange(int categoryId) async {
    cid = categoryId;
    getGenreByCate(categoryId).then((res) {
      setState(() {
        genres = res.data['data']['list'];
      });
    });

    getSouvenir(categoryId: categoryId, streetId: getStreet().streetId)
        .then((res) {
      setState(() {
        Souvenirs = res.data['data']['list'];
      });
    });
  }

  Future<void> onGenreChange(int genreId) async {
    gid = genreId;
    getSouvenir(
            categoryId: cid, genreId: genreId, streetId: getStreet().streetId)
        .then((res) {
      setState(() {
        Souvenirs = res.data['data']['list'];
      });
    });
  }

  Future<void> onTextChange(String text) async {
    print("text change api... $text");
    getSouvenir(
            categoryId: cid,
            genreId: gid,
            search: text,
            streetId: getStreet().streetId)
        .then((res) {
      print("get Souvenir ${res.data['data']['list']}");
      setState(() {
        Souvenirs = res.data['data']['list'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getSouvenir(streetId: getStreet().streetId).then((res) {
      print(res.data);
      setState(() {
        Souvenirs = res.data['data']['list'];
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
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Header(
                    onTextChange: onTextChange,
                  )),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                      flex: 3,
                      child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(right: 10),
                          child: SouvenirList(souvenirs: Souvenirs))),
                  Flexible(
                      flex: 1,
                      child: CategorySidebar(
                        onCateChange: onCateChange,
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
