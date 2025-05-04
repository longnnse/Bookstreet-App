import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapmobile/pages/store_products_filter/store_products_filter_page.dart';
import 'package:mapmobile/services/store_service.dart';
import 'package:mapmobile/shared/btn.dart';
import 'package:mapmobile/shared/text.dart';

class BookStoreDetailPage extends StatefulWidget {
  const BookStoreDetailPage({super.key, required this.storeId});

  final int storeId;

  @override
  State<BookStoreDetailPage> createState() => _BookStoreDetailPageState();
}

class _BookStoreDetailPageState extends State<BookStoreDetailPage> {
  Map<String, dynamic> store = {};
  final StoreService _storeService = StoreService();

  Future<Map<String, dynamic>> _getStoreByOnTap(int storeId) async {
    final res = await _storeService.getStoreById(storeId.toString());
    return res;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      store = await _getStoreByOnTap(widget.storeId);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: store.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Stack(
                  children: [
                    Image.asset(
                      "assets/images/bookDialogBanner.jpeg",
                      fit: BoxFit.fitWidth,
                      width: 1.sw,
                      height: 1.sh / 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          SizedBox(height: 1.sh / 2.5),
                          Row(
                            children: [
                              SizedBox(
                                width: 200,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: CachedNetworkImage(
                                      imageUrl: store['urlImage'] ?? "",
                                      placeholder: (context, url) =>
                                          const Icon(Icons.error),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error)),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: DynamicText(
                                  text: store['storeName'],
                                  textStyle: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Spacer(),
                              Btn(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          StoreProductsFilterPage(
                                        storeId: widget.storeId,
                                        productType: ProductType.all,
                                      ),
                                    ),
                                  );
                                },
                                content: 'Xem tất cả sản phẩm',
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.timer),
                                  DynamicText(
                                      text:
                                          "${store['openingHours'] ?? ""} - ${store['closingHours'] ?? ""}",
                                      textStyle: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              DynamicText(
                                  text: store['description'],
                                  textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: 24,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
  }
}
