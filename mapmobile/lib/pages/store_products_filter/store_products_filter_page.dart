import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mapmobile/common/widgets/app_dropdown.dart';
import 'package:mapmobile/common/widgets/cart_button.dart';
import 'package:mapmobile/models/map_model.dart';
import 'package:mapmobile/pages/product_detail/product_detail.dart';
import 'package:mapmobile/services/category_service.dart';
import 'package:mapmobile/services/distributor_service.dart';
import 'package:mapmobile/services/gift_service.dart';
import 'package:mapmobile/services/product_service.dart';
import 'package:mapmobile/services/store_service.dart';
import 'package:mapmobile/util/util.dart';
import 'package:provider/provider.dart';

enum ProductType {
  book,
  souvenir,
  all,
  gift,
}

extension ProductTypeExtension on ProductType {
  String get name {
    switch (this) {
      case ProductType.book:
        return 'Sách';
      case ProductType.souvenir:
        return 'Quà lưu niệm';
      case ProductType.all:
        return 'Tất cả sản phẩm của cửa hàng';
      case ProductType.gift:
        return 'Quà tặng';
    }
  }

  int? get id {
    switch (this) {
      case ProductType.book:
        return 1;
      case ProductType.souvenir:
        return 2;
      case ProductType.all:
        return null;
      case ProductType.gift:
        return 3;
    }
  }
}

class StoreProductsFilterPage extends StatefulWidget {
  final int? storeId;
  final ProductType productType;

  const StoreProductsFilterPage(
      {super.key, this.storeId, required this.productType});

  @override
  State<StoreProductsFilterPage> createState() =>
      _StoreProductsFilterPageState();
}

class _StoreProductsFilterPageState extends State<StoreProductsFilterPage> {
  RangeValues? _initialPriceRange;
  RangeValues? _priceRange;
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final GiftService _giftService = GiftService();
  final DistributorService _distributorService = DistributorService();
  final StoreService _storeService = StoreService();

  List<dynamic> products = [];
  List<dynamic> categoriesFilter = [];
  List<dynamic> distributorsFilter = [];
  List<dynamic> bookStoresFilter = [];
  List<Map<String, dynamic>> productTypes = [
    {'id': 1, 'name': 'Sách'},
    {'id': 2, 'name': 'Quà lưu niệm'},
  ];

  int? selectedProductTypeId;
  int? selectedStoreId;
  bool isLoading = true;
  bool isLoadingFilters = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    selectedStoreId = widget.storeId;
    selectedProductTypeId = widget.productType.id;
    if (widget.productType == ProductType.gift) {
      fetchGiftData();
    } else {
      _loadData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        onFilter(),
        fetchFilterData(),
      ]);

      // Find min and max price from the products list
      double minPrice = double.infinity;
      double maxPrice = 0;

      for (var product in products) {
        double price = product['price'] != null
            ? double.parse(product['price'].toString())
            : 0;
        if (price < minPrice) minPrice = price;
        if (price > maxPrice) maxPrice = price;
      }

      _initialPriceRange = RangeValues(
        minPrice.isFinite ? minPrice : 0,
        maxPrice.isFinite ? maxPrice : 10000000,
      );

      _priceRange = _initialPriceRange;
    });
  }

  Future<void> fetchGiftData() async {
    await _giftService.getAllGift(getStreet().streetId).then((res) {
      setState(() {
        final now = DateTime.now();
        final filteredData = res.where((data) {
          try {
            final startDate = DateTime.parse(data['starDate']);
            final endDate = DateTime.parse(data['endDate']);
            return now.isAfter(startDate) && now.isBefore(endDate);
          } catch (e) {
            return false;
          }
        }).toList();
        products = filteredData;
        isLoading = false;
      });
    });
  }

  Future<void> fetchFilterData() async {
    setState(() {
      isLoadingFilters = true;
    });

    await Future.wait([
      getAllCategory(),
      if (widget.productType == ProductType.all ||
          widget.productType == ProductType.book)
        getAllDistributorFilter(),
      if (widget.productType == ProductType.all ||
          widget.productType == ProductType.souvenir)
        getAllStore(),
    ]);

    setState(() {
      isLoadingFilters = false;
    });
  }

  Future<void> getAllStore() async {
    await _storeService.getAllBookStore().then((res) {
      setState(() {
        bookStoresFilter = res;
      });
    });
  }

  Future<void> onFilter({
    int? categoryId,
    int? distributorId,
    double? minPrice,
    double? maxPrice,
    int? productTypeId,
    int? storeId,
  }) async {
    setState(() {
      isLoading = true;
    });
    try {
      final res = await _productService.filterProducts(
        search: _searchController.text,
        categoryId: categoryId,
        streetId: getStreet().streetId,
        storeId: storeId ?? selectedStoreId ?? widget.storeId,
        distributorId: distributorId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        productTypeId: productTypeId ?? selectedProductTypeId,
      );

      if (mounted) {
        setState(() {
          products = res;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          products = [];
        });
      }
    }
  }

  Future<void> getAllCategory() async {
    await _categoryService
        .getAllCategory(selectedProductTypeId.toString())
        .then((res) {
      setState(() {
        categoriesFilter = res;
      });
    });
  }

  Future<void> getAllDistributorFilter() async {
    await _distributorService.getAllDistributor().then((res) {
      setState(() {
        distributorsFilter = res;
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
      appBar: AppBar(
        title: Text(widget.productType.name),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CartButton(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildFilterSection(),
            const SizedBox(width: 16),
            _buildProductsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchField(),
          const SizedBox(height: 16),
          if (widget.productType == ProductType.all) ...[
            _buildProductTypeFilter(),
            const SizedBox(height: 16),
          ],
          if (selectedProductTypeId == 1) ...[
            if (isLoadingFilters) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else ...[
              if (widget.productType == ProductType.all &&
                  bookStoresFilter.isNotEmpty)
                _buildStoreFilter(),
              if (distributorsFilter.isNotEmpty) _buildDistributorFilter(),
              const SizedBox(height: 16),
            ],
          ],
          if (categoriesFilter.isNotEmpty) _buildCategoryFilter(),
          const SizedBox(height: 16),
          _buildPriceRangeFilter(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Tìm kiếm sản phẩm',
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
        suffixIcon: GestureDetector(
          onTap: () {
            _searchController.clear();
            onFilter();
          },
          child: const Icon(Icons.clear, color: Colors.red),
        ),
      ),
      onChanged: (value) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
          onFilter();
        });
      },
    );
  }

  Widget _buildDistributorFilter() {
    return AppDropdown(
      label: 'Nhà phát hành',
      items: distributorsFilter
          .map((e) => DropdownValue(value: e, displayText: e['distriName']))
          .toList(),
      onChanged: (value) {
        if (value == null) {
          onFilter();
        } else {
          onFilter(distributorId: value.value['distributorId']);
        }
      },
    );
  }

  Widget _buildCategoryFilter() {
    return AppDropdown(
      label: widget.productType == ProductType.book
          ? 'Loại sách'
          : 'Loại quà lưu niệm',
      items: categoriesFilter
          .map((e) => DropdownValue(value: e, displayText: e['categoryName']))
          .toList(),
      onChanged: (value) {
        if (value == null) {
          onFilter();
        } else {
          onFilter(categoryId: value.value['categoryId']);
        }
      },
    );
  }

  Widget _buildProductTypeFilter() {
    return AppDropdown(
      label: 'Loại sản phẩm',
      items: productTypes
          .map((e) => DropdownValue(value: e, displayText: e['name']))
          .toList(),
      onChanged: (value) async {
        if (value == null) {
          setState(() => selectedProductTypeId = null);
          onFilter();
        } else {
          setState(() => selectedProductTypeId = value.value['id']);
          await fetchFilterData();
          onFilter(productTypeId: value.value['id']);
        }
      },
    );
  }

  Widget _buildPriceRangeFilter() {
    final priceRange = _priceRange ?? _initialPriceRange;
    final initialPriceRange = _initialPriceRange;
    if (priceRange == null || initialPriceRange == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Khoảng giá: ${formatToVND(priceRange.start)} - ${formatToVND(priceRange.end)}'),
        RangeSlider(
          values: priceRange,
          min: initialPriceRange.start,
          max: initialPriceRange.end,
          divisions: 10,
          labels: RangeLabels('${formatToVND(priceRange.start)} VNĐ',
              '${formatToVND(priceRange.end)} VNĐ'),
          onChanged: (values) {
            setState(() => _priceRange = values);

            if (_debounce?.isActive ?? false) _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 500), () {
              onFilter(minPrice: values.start, maxPrice: values.end);
            });
          },
        ),
      ],
    );
  }

  Widget _buildStoreFilter() {
    return AppDropdown(
      label: 'Cửa hàng',
      items: bookStoresFilter
          .map((e) => DropdownValue(value: e, displayText: e['storeName']))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedStoreId = value?.value['storeId'];
        });
        onFilter(storeId: value?.value['storeId']);
      },
    );
  }

  Widget _buildProductsGrid() {
    return Expanded(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text("Không tìm thấy sản phẩm"))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) =>
                      _buildProductCard(products[index]),
                ),
    );
  }

  Widget _buildProductCard(dynamic product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetail(
              pid: (product['productId'] ?? product['id']).toString(),
              productType: widget.productType,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: product['urlImage'] ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => widget.productType ==
                          ProductType.gift
                      ? Image.asset('assets/images/gift.jpg', fit: BoxFit.cover)
                      : Image.asset('assets/images/book_photo.jpg',
                          fit: BoxFit.cover),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product['productName'] ?? product['giftName'],
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (product['price'] != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(
                  formatToVND(product['price']),
                  style: const TextStyle(color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
