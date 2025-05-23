import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapmobile/shared/header.dart';
import 'package:mapmobile/services/productservice.dart';
import 'package:mapmobile/shared/btn.dart';
import 'package:mapmobile/shared/networkimagefallback.dart';
import 'package:mapmobile/shared/text.dart';
import 'package:mapmobile/util/util.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({super.key, required this.pid});
  final dynamic pid;

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  dynamic product = {};

  @override
  void initState() {
    super.initState();
    getProductById(widget.pid).then((res) {
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
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 40),
              child: const Header(),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
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
                              margin: const EdgeInsets.only(bottom: 20),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
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
                                  height: 300,
                                  child: GridView.count(
                                    // shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 1,
                                    mainAxisSpacing: 1,
                                    childAspectRatio: 5,
                                    children: [
                                      const DynamicText(
                                          text: ("Mã sản phẩm")),
                                      DynamicText(
                                          text: product['productId'] != null
                                              ? product['productId']
                                                  .toString()
                                              : ""),
                                      const DynamicText(text: ("Phân loại")),
                                      DynamicText(
                                          text:
                                              product['categoryName'] ?? ""),
                                      const DynamicText(text: ("Giá")),
                                      DynamicText(
                                          text: formatToVND(
                                              product['price'] ?? 0)),
                                      const DynamicText(text: ("Vị trí bán")),
                                      DynamicText(
                                          text: product['storeName'] ??
                                              "chưa có"),
                                      const DynamicText(text: ("Tình trạng")),
                                      DynamicText(
                                          text: product['status'] == 1
                                              ? "còn hàng"
                                              : product['status'] == 2
                                                  ? "hết hàng"
                                                  : "không rõ"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
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
      )),
    );
  }
}
