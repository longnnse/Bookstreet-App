import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mapmobile/common/widgets/app_dropdown.dart';
import 'package:mapmobile/models/map_model.dart';
import 'package:mapmobile/pages/ProductDetail/bookdetail.dart';
import 'package:mapmobile/services/categoryservice.dart';
import 'package:mapmobile/services/distributor_service.dart';
import 'package:mapmobile/services/productservice.dart';
import 'package:mapmobile/services/storeservice.dart';
import 'package:mapmobile/util/util.dart';
import 'package:provider/provider.dart';

enum FilterType {
  category,
  store,
  distributor,
}

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  RangeValues? _initialPriceRange;
  RangeValues? _priceRange;
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> books = [];
  List<dynamic> categoriesFilter = [];
  List<dynamic> bookStoresFilter = [];
  List<dynamic> distributorsFilter = [];

  bool isLoading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
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
        fetchFilterData(FilterType.category),
        fetchFilterData(FilterType.store),
        fetchFilterData(FilterType.distributor),
      ]);

      // Find min and max price from the books list
      double minPrice = double.infinity;
      double maxPrice = 0;

      for (var book in books) {
        double price =
            book['price'] != null ? double.parse(book['price'].toString()) : 0;
        if (price < minPrice) minPrice = price;
        if (price > maxPrice) maxPrice = price;
      }

      _initialPriceRange = RangeValues(minPrice.isFinite ? minPrice : 0,
          maxPrice.isFinite ? maxPrice : 10000000);

      // Set price range with found min and max values
      _priceRange = _initialPriceRange;
    });
  }

  Future<void> fetchFilterData(FilterType type) async {
    setState(() {
      isLoading = true;
    });

    switch (type) {
      case FilterType.category:
        await getAllCategory();
        break;
      case FilterType.store:
        await getAllStore();
        break;
      case FilterType.distributor:
        await getAllDistributorFilter();
        break;
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> onFilter({
    int? categoryId,
    int? genreId,
    int? storeId,
    int? distributorId,
    double? minPrice,
    double? maxPrice,
  }) async {
    setState(() {
      isLoading = true;
    });
    try {
      final res = await getBook(
        search: _searchController.text,
        categoryId: categoryId,
        genreId: genreId,
        streetId: getStreet().streetId,
        storeId: storeId,
        distributorId: distributorId,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

      if (mounted) {
        setState(() {
          books = res.data['data']['list'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          books = [];
        });
        // Consider adding error handling/display here
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

  Future<void> getAllStore() async {
    await getAllBookStore().then((res) {
      setState(() {
        bookStoresFilter = res;
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
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildFilterSection(),
            const SizedBox(width: 16),
            _buildBooksGrid(),
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
          if (bookStoresFilter.isNotEmpty) _buildStoreFilter(),
          const SizedBox(height: 16),
          if (categoriesFilter.isNotEmpty) _buildCategoryFilter(),
          const SizedBox(height: 16),
          if (distributorsFilter.isNotEmpty) _buildDistributorFilter(),
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
        hintText: 'Tìm kiếm sách',
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

  Widget _buildStoreFilter() {
    return AppDropdown(
      label: 'Cửa hàng',
      items: bookStoresFilter
          .map((e) => DropdownValue(value: e, displayText: e['storeName']))
          .toList(),
      onChanged: (value) {
        if (value == null) {
          onFilter();
        } else {
          onFilter(storeId: value.value['storeId']);
        }
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

  Widget _buildBooksGrid() {
    return Expanded(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? const Center(child: Text("Không tìm thấy sản phẩm"))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) => _buildBookCard(books[index]),
                ),
    );
  }

  Widget _buildBookCard(dynamic book) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetail(pid: book['productId'].toString()),
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
                  imageUrl: book['urlImage']!,
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
                book['productName'],
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                formatToVND(book['price']),
                style: const TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
