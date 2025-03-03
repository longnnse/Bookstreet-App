import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapmobile/shared/header.dart';
import 'package:mapmobile/services/productservice.dart';
import 'package:mapmobile/shared/Btn.dart';
import 'package:mapmobile/shared/networkimagefallback.dart';
import 'package:mapmobile/shared/text.dart';
import 'package:mapmobile/util/util.dart';

class BookDetail extends StatefulWidget {
  const BookDetail({super.key, required this.pid});
  final dynamic pid;

  @override
  State<BookDetail> createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  dynamic product = {};

  @override
  void initState() {
    super.initState();
    getProductById(widget.pid).then((res) {
      print("product");
      print(res);
      setState(() {
        product = res;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                child: Header(),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 20),
                                child: NetworkImageWithFallback(
                                    imageUrl: product["urlImage"] ?? "",
                                    fallbackWidget: const Icon(Icons.error)),
                              ),
                              Btn(
                                  content: product["storeName"] != null
                                      ? "Xem vị trí cửa hàng"
                                      : "Chưa mở bán",
                                  onTap: () {
                                    if (product["storeId"] != null) {
                                      context
                                          .push("/map/${product["storeId"]}");
                                    }
                                  })
                            ],
                          ),
                        ),
                      )),
                  Flexible(
                      flex: 3,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DynamicText(
                                    text: product['productName'] ?? "",
                                    textStyle: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  DynamicText(
                                    text: formatToVND(product['price'] ?? 0),
                                    textStyle: const TextStyle(
                                        color: Color.fromARGB(255, 186, 12, 0),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 450,
                                    child: GridView.count(
                                      // shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 1,
                                      mainAxisSpacing: 1,
                                      childAspectRatio: 5,
                                      children: [
                                        const DynamicText(text: ("Tác giả")),
                                        DynamicText(
                                            text: product?['book']
                                                        ?['authors'] !=
                                                    null
                                                ? product?['book']?['authors']
                                                    .join(", ")
                                                : ""),
                                        const DynamicText(
                                            text: ("Nhà xuất bản")),
                                        DynamicText(
                                            text: product['book']
                                                    ?['publisherName'] ??
                                                ""),
                                        const DynamicText(
                                            text: ("Nhà phân phối")),
                                        DynamicText(
                                            text: product['book']
                                                    ?['distributorName'] ??
                                                ""),
                                        const DynamicText(
                                            text: ("Ngày xuất bản")),
                                        DynamicText(
                                            text: product['book']
                                                    ?['publicDay'] ??
                                                "chưa có"),
                                        const DynamicText(
                                            text: ("Được bán tại")),
                                        DynamicText(
                                            text: product['storeName'] ??
                                                "chưa có"),
                                        const DynamicText(text: ("Tình trạng")),
                                        DynamicText(
                                          text: product['status'] == 1
                                              ? "còn hàng"
                                              : product['status'] == 2
                                                  ? "hết hàng"
                                                  : "không rõ",
                                          textStyle: TextStyle(
                                              color: product['status'] == 1
                                                  ? Colors.green
                                                  : Colors.red),
                                        ),
                                        const DynamicText(
                                            text: ("Lần tái bản")),
                                        DynamicText(
                                            text: product['book']
                                                        ?['editionNumber'] !=
                                                    null
                                                ? product['book']
                                                        ['editionNumber']
                                                    .toString()
                                                : "1"),
                                        const DynamicText(
                                            text: ("Năm tái bản")),
                                        DynamicText(
                                            text: product['book']
                                                        ?['editionYear'] !=
                                                    null
                                                ? product['book']['editionYear']
                                                    .toString()
                                                : "")
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 20),
                              child: Column(
                                children: [
                                  const DynamicText(
                                    text: "Mô tả sản phẩm",
                                    textStyle: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  DynamicText(
                                    text: product['description'] ?? "",
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.w400),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ))
                ],
              )
            ],
          ),
        ),
      )),
    );
  }
}
