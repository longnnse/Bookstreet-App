import 'package:flutter/material.dart';
import 'package:mapmobile/services/categoryservice.dart';
import 'package:mapmobile/shared/text.dart';

class CategorySidebar extends StatefulWidget {
  const CategorySidebar({super.key, required this.onCateChange});
  final Function onCateChange;
  @override
  State<CategorySidebar> createState() => _CategorySidebarState();
}

class _CategorySidebarState extends State<CategorySidebar> {
  List<dynamic> categories = [];
  int selectedCate = 0;

  @override
  void initState() {
    super.initState();
    getAllCate("2").then((res) {
      print(res.data);
      setState(() {
        categories = res.data['data']['list'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).size.height / 4,
      child: SingleChildScrollView(
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  selectedCate = 0;
                });
                widget.onCateChange(0);
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 6,
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: selectedCate == 0
                        ? const Color.fromARGB(255, 200, 13, 0)
                        : Colors.white),
                child: DynamicText(
                  text: "Tất cả",
                  textStyle: TextStyle(
                      color: selectedCate == 0 ? Colors.white : Colors.black),
                ),
              ),
            ),
            ...categories.map((cate) {
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedCate = cate["categoryId"];
                  });
                  widget.onCateChange(cate["categoryId"]);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 6,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: cate["categoryId"] == selectedCate
                          ? const Color.fromARGB(255, 200, 13, 0)
                          : Colors.white),
                  child: DynamicText(
                    text: cate["categoryName"],
                    textStyle: TextStyle(
                        color: cate["categoryId"] == selectedCate
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
