import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mapmobile/common/widgets/app_dropdown.dart';
import 'package:mapmobile/models/map_model.dart';
import 'package:mapmobile/pages/product_detail/product_detail.dart';
import 'package:mapmobile/services/categoryservice.dart';
import 'package:mapmobile/services/distributor_service.dart';
import 'package:mapmobile/services/product_service.dart';
import 'package:mapmobile/services/storeservice.dart';
import 'package:mapmobile/util/util.dart';
import 'package:provider/provider.dart';

class StoreProductsFilterPage extends StatefulWidget {
  final int? storeId;

  const StoreProductsFilterPage({super.key, this.storeId});

  @override
  State<StoreProductsFilterPage> createState() =>
      _StoreProductsFilterPageState();
}

class _StoreProductsFilterPageState extends State<StoreProductsFilterPage> {
  RangeValues? _initialPriceRange;
  RangeValues? _priceRange;
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();

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
    if (widget.storeId == null) {
      selectedProductTypeId = 1;
    }
    _loadData();
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

  Future<void> fetchFilterData() async {
    setState(() {
      isLoadingFilters = true;
    });

    if (widget.storeId == null || selectedProductTypeId == 1) {
      await Future.wait([
        getAllCategory(),
        getAllDistributorFilter(),
        if (widget.storeId == null) getAllStore(),
      ]);
    }

    setState(() {
      isLoadingFilters = false;
    });
  }

  Future<void> getAllStore() async {
    await getAllBookStore().then((res) {
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
    await getAllCate("1").then((res) {
      setState(() {
        categoriesFilter = res.data['data']['list'];
      });
    });
  }

  Future<void> getAllDistributorFilter() async {
    await getAllDistributor().then((res) {
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
        title: Text(widget.storeId == null
            ? 'Thông tin sách'
            : 'Sản phẩm của cửa hàng'),
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
          if (widget.storeId != null) ...[
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
              if (widget.storeId == null && bookStoresFilter.isNotEmpty)
                _buildStoreFilter(),
              if (widget.storeId == null && bookStoresFilter.isNotEmpty)
                const SizedBox(height: 16),
              if (categoriesFilter.isNotEmpty) _buildCategoryFilter(),
              const SizedBox(height: 16),
              if (distributorsFilter.isNotEmpty) _buildDistributorFilter(),
              const SizedBox(height: 16),
            ],
          ],
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
      label: 'Loại sách',
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
            builder: (context) =>
                ProductDetail(pid: product['productId'].toString()),
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
                  imageUrl: product['urlImage']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      Image.asset('assets/images/book_photo.jpg'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product['productName'],
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
