import 'package:flutter/material.dart';
import 'package:mapmobile/common/widgets/map_with_position_widget.dart';
import 'package:mapmobile/common/widgets/show_message.dart';
import 'package:mapmobile/pages/author/author_detail.dart';
import 'package:mapmobile/services/product_service.dart';
import 'package:mapmobile/shared/networkimagefallback.dart';
import 'package:mapmobile/util/util.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/cart_item.dart';
import '../../services/cart_service.dart';
import '../../pages/cart/cart_page.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({super.key, required this.pid});
  final dynamic pid;

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  dynamic product = {};
  bool isLoading = true;
  bool isFavorite = false;
  ProductService productService = ProductService();
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    productService.getProductById(widget.pid).then((res) {
      setState(() {
        product = res;
        isLoading = false;
      });
    });
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          Container(
            height: 20,
            width: 200,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Container(
            height: 20,
            width: 150,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildBookCover() {
    return Hero(
      tag: 'book_cover_${product["id"]}',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(200),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: NetworkImageWithFallback(
                imageUrl: product["urlImage"] ?? "",
                fallbackWidget: const Icon(Icons.error, size: 100),
                height: 300,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (product['status'] != 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sản phẩm hiện không có sẵn'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      try {
                        final cartItem = CartItem(
                          productId: product['productId'].toString(),
                          productName: product['productName'],
                          imageUrl: product['urlImage'] ?? "",
                          price: (product['price'] ?? 0).toDouble(),
                          quantity: 1,
                        );

                        await _cartService.addToCart(cartItem);

                        ShowMessage.showSuccess(
                            context, 'Đã thêm vào giỏ hàng');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Có lỗi xảy ra khi thêm vào giỏ hàng'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    label: const Text("Thêm vào giỏ"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (product["storeId"] != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapWithPositionWidget(
                              storeId: product["storeId"].toString(),
                              mapType: MapType.store,
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.location_on, color: Colors.white),
                    label: Text(product["storeName"] != null
                        ? "Xem vị trí cửa hàng"
                        : "Chưa mở bán"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookInfo() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(200),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product['productName'] ?? "",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            formatToVND(product['price'] ?? 0),
            style: const TextStyle(
              color: Color.fromARGB(255, 186, 12, 0),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 15,
            childAspectRatio: 3,
            children: [
              ...(product?['book']?['listAuthors'] ?? [])
                  .map((author) => _buildInfoItem(
                        "Tác giả",
                        author['authorName'],
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AuthorDetail(
                                authorId: author['authorId']?.toString() ?? '',
                              ),
                            ),
                          );
                        },
                        statusColor: Colors.green,
                      ))
                  .toList(),
              _buildInfoItem(
                  "Nhà xuất bản", product['book']?['publisherName'] ?? ""),
              _buildInfoItem(
                  "Nhà phân phối", product['book']?['distributorName'] ?? ""),
              _buildInfoItem(
                  "Ngày xuất bản", product['book']?['publicDay'] ?? "chưa có"),
              _buildInfoItem("Được bán tại", product['storeName'] ?? "chưa có"),
              _buildInfoItem(
                "Tình trạng",
                product['status'] == 1
                    ? "còn hàng"
                    : product['status'] == 2
                        ? "hết hàng"
                        : "không rõ",
                statusColor: product['status'] == 1
                    ? Colors.green
                    : product['status'] == 2
                        ? Colors.red
                        : Colors.grey,
              ),
              _buildInfoItem("Lần tái bản",
                  product['book']?['editionNumber']?.toString() ?? "1"),
              _buildInfoItem("Năm tái bản",
                  product['book']?['editionYear']?.toString() ?? ""),
              _buildInfoItem(
                  "ISBN", product['book']?['isbn']?.toString() ?? ""),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value,
      {Color? statusColor, VoidCallback? onPressed}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onPressed,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: statusColor ?? Colors.black,
              decoration: onPressed != null ? TextDecoration.underline : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(200),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mô tả sản phẩm",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            product['description'] ?? "",
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['productName'] ?? ""),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const CartPage(userId: 'current_user_id'),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? _buildShimmerLoading()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fixed book cover section
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    padding: const EdgeInsets.all(20),
                    child: _buildBookCover(),
                  ),
                  // Scrollable content section
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildBookInfo(),
                            const SizedBox(height: 20),
                            _buildDescription(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
