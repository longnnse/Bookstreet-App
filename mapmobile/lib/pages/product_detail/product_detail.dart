import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mapmobile/common/widgets/cart_button.dart';
import 'package:mapmobile/common/widgets/map_with_position_widget.dart';
import 'package:mapmobile/common/widgets/show_message.dart';
import 'package:mapmobile/pages/author/author_detail.dart';
import 'package:mapmobile/pages/store_products_filter/store_products_filter_page.dart';
import 'package:mapmobile/services/gift_service.dart';
import 'package:mapmobile/services/preferences_manager.dart';
import 'package:mapmobile/services/product_service.dart';
import 'package:mapmobile/shared/networkimagefallback.dart';
import 'package:mapmobile/util/util.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/cart_item.dart';
import '../../services/cart_service.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({
    super.key,
    required this.pid,
    required this.productType,
  });
  final dynamic pid;
  final ProductType productType;

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  dynamic product = {};
  bool isLoading = true;
  bool isFavorite = false;
  final ProductService productService = ProductService();
  final CartService _cartService = CartService();
  final GiftService _giftService = GiftService();

  @override
  void initState() {
    super.initState();
    if (widget.productType == ProductType.gift) {
      _giftService.getGiftById(widget.pid).then((res) {
        setState(() {
          product = res;
          isLoading = false;
        });
      });
    } else {
      productService.getProductById(widget.pid).then((res) {
        setState(() {
          product = res;
          isLoading = false;
        });
      });
    }
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

  Widget _buildProductCover() {
    return Hero(
      tag: 'product_cover_${product["id"]}',
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
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: NetworkImageWithFallback(
                  imageUrl: product["urlImage"] ?? "",
                  fallbackWidget: widget.productType == ProductType.gift
                      ? Image.asset('assets/images/gift.jpg', fit: BoxFit.cover)
                      : Image.asset('assets/images/book_photo.jpg',
                          fit: BoxFit.cover),
                  fit: BoxFit.cover,
                  height: 1.sh / 2,
                ),
              ),
            ),
            Column(
              children: [
                if (widget.productType != ProductType.gift &&
                    PreferencesManager.getUserData() != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
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
                            isbn: product['book']?['isbn'],
                          );

                          await _cartService.addToCart(cartItem);

                          ShowMessage.showSuccess(
                              context, 'Đã thêm vào giỏ hàng');
                        } catch (e) {
                          ShowMessage.showError(context, 'Có lỗi xảy ra $e');
                        }
                      },
                      icon:
                          const Icon(Icons.shopping_cart, color: Colors.white),
                      label: const Text("Thêm vào giỏ"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
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
                    label: Text(product["storeId"] != null
                        ? "Xem vị trí cửa hàng"
                        : "Chưa mở bán"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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

  Widget _buildProductInfo() {
    return Container(
      width: double.infinity,
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
            widget.productType == ProductType.gift
                ? product['giftName'] ?? ""
                : product['productName'] ?? "",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.productType != ProductType.gift) ...[
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
              crossAxisSpacing: 10,
              mainAxisSpacing: 8,
              childAspectRatio: 6,
              crossAxisCount: 2,
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
                                  authorId:
                                      author['authorId']?.toString() ?? '',
                                ),
                              ),
                            );
                          },
                          statusColor: Colors.green,
                        ))
                    .toList(),
                if (product['book']?['publisherName'] != null)
                  _buildInfoItem(
                      "Nhà xuất bản", product['book']?['publisherName'] ?? ""),
                if (product['book']?['distributorName'] != null)
                  _buildInfoItem("Nhà phân phối",
                      product['book']?['distributorName'] ?? ""),
                if (product['book']?['publicDay'] != null)
                  _buildInfoItem(
                      "Ngày xuất bản",
                      DateFormat('yyyy/MM/dd').format(
                          DateTime.parse(product['book']?['publicDay']))),
                if (product['storeName'] != null)
                  _buildInfoItem("Được bán tại", product['storeName'] ?? ""),
                _buildInfoItem(
                  "Tình trạng",
                  product['status'] == 1
                      ? "Còn hàng"
                      : product['status'] == 2
                          ? "Hết hàng"
                          : "Không rõ",
                  statusColor: product['status'] == 1
                      ? Colors.green
                      : product['status'] == 2
                          ? Colors.red
                          : Colors.grey,
                ),
                if (product['book']?['editionNumber'] != null)
                  _buildInfoItem("Lần tái bản",
                      product['book']?['editionNumber']?.toString() ?? ""),
                if (product['book']?['editionYear'] != null)
                  _buildInfoItem("Năm tái bản",
                      product['book']?['editionYear']?.toString() ?? ""),
                if (product['book']?['isbn'] != null)
                  _buildInfoItem(
                      "ISBN", product['book']?['isbn']?.toString() ?? ""),
              ],
            ),
          ],
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
            maxLines: 1,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: statusColor ?? Colors.black,
                decoration: onPressed != null ? TextDecoration.underline : null,
                overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            product['description'] != null && product['description'] != ""
                ? product['description']
                : "Không có thông tin",
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CartButton(),
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
                    child: _buildProductCover(),
                  ),
                  // Scrollable content section
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildProductInfo(),
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
