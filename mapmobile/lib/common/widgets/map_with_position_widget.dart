import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:mapmobile/models/map_model.dart';
import 'package:mapmobile/pages/book_store_detail/book_store_detail_page.dart';
import 'package:mapmobile/services/locationservice.dart';
import 'package:mapmobile/services/storeservice.dart';
import 'package:mapmobile/shared/networkimagefallback.dart';
import 'package:mapmobile/shared/text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

/* 
  Ý tưởng: Lớp MapWidget là một StatefulWidget trong Flutter, 
  được sử dụng để hiển thị một hình ảnh bản đồ và xác định vị trí của một cửa hàng 
  dựa trên tên cửa hàng được cung cấp. 

  Các bước hoạt động:
  1. Khi widget được khởi tạo, nó sẽ tải hình ảnh từ tài nguyên.
  2. Sau khi hình ảnh được tải, hàm _detectText sẽ được gọi để nhận diện văn bản trong hình ảnh.
  3. Nếu tên cửa hàng được tìm thấy trong văn bản, vị trí của nó sẽ được lưu trữ.
  4. Các hàm _scaledLeft và _scaledTop sẽ tính toán vị trí hiển thị của biểu tượng vị trí 
     dựa trên kích thước của hình ảnh và kích thước màn hình.
  5. Cuối cùng, widget sẽ hiển thị hình ảnh và biểu tượng vị trí nếu có.
*/

// Lớp MapWidget là một StatefulWidget, chứa các thông tin về hình ảnh và tên cửa hàng
class MapWithPositionWidget extends StatefulWidget {
  final String? storeId;
  final bool isShowAll;

  // Constructor để khởi tạo các thuộc tính
  const MapWithPositionWidget({
    super.key,
    this.storeId,
    required this.isShowAll,
  });

  @override
  MapWithPositionWidgetState createState() => MapWithPositionWidgetState();
}

// Trạng thái của MapWithPositionWidget
class MapWithPositionWidgetState extends State<MapWithPositionWidget> {
  final List<_BookStoreWithPosition> _bookStoresWithPosition = [];

  double originalWidth = 1;
  double originalHeight = 1;

  // Define _imageFile to store the loaded image
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!widget.isShowAll && widget.storeId != null) {
        final store = await _fetchStore(widget.storeId!);

        if (store != null) {
          _bookStoresWithPosition.add(_BookStoreWithPosition(
            store: store,
          ));
        }
      }

      await _processImage();
    });
  }

  Future<Map<String, dynamic>?> _fetchStore(String storeId) async {
    try {
      final res = await getStoreById(storeId);
      return res;
    } catch (error) {
      debugPrint("Error fetching store: $error");
    }
    return null;
  }

  // Hàm xử lý hình ảnh
  Future<void> _processImage() async {
    final file = await _loadImage();
    if (file != null) {
      await _detectText(file);
      setState(
          () => _imageFile = file); // Update _imageFile with the loaded image
    }
  }

  // Hàm tải hình ảnh từ tài nguyên
  Future<File?> _loadImage() async {
    try {
      final image = context.read<MapModel>().imageUrl;

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/map_image.png';
      final file = File(filePath);

      // Check if the file already exists in cache
      if (await file.exists()) {
        // Load from cache
        img.Image? originalImage = img.decodeImage(await file.readAsBytes());
        if (originalImage == null) return null;

        setState(() {
          originalWidth = originalImage.width.toDouble();
          originalHeight = originalImage.height.toDouble();
        });

        return file;
      }

      // If not in cache, download and save it
      final response = await http.get(Uri.parse(image));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);

        img.Image? originalImage = img.decodeImage(response.bodyBytes);
        if (originalImage == null) return null;

        setState(() {
          originalWidth = originalImage.width.toDouble();
          originalHeight = originalImage.height.toDouble();
        });

        return file;
      }
    } catch (e) {
      debugPrint("Error loading image: $e");
    }
    return null;
  }

  // Hàm nhận diện văn bản trong hình ảnh
  Future<void> _detectText(File imageFile) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final model = context.read<MapModel>();

    final recognizedText = await textRecognizer.processImage(
      InputImage.fromFile(imageFile),
    );

    // Clear previous locations
    _bookStoresWithPosition.clear();

    // Iterate over text blocks and lines
    final locationsToCheck = widget.isShowAll
        ? model.locations
        : [
            {'locationName': _bookStoresWithPosition[0].store['locationName']}
          ];

    final locationNames =
        locationsToCheck.map((location) => location['locationName']).toSet();
    final locationMap = {
      for (var location in locationsToCheck) location['locationName']: location
    };

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final matchingLocationName = locationNames.firstWhere(
          (name) => line.text.contains(name),
          orElse: () => null,
        );
        if (matchingLocationName != null) {
          _bookStoresWithPosition.add(_BookStoreWithPosition(
            store: locationMap[matchingLocationName],
            position: line.boundingBox,
          ));
        }
      }
    }
    setState(() {}); // Update the state
    textRecognizer.close();
  }

  // Hàm tính toán vị trí bên trái đã được tỷ lệ hóa
  double _scaledLeft(Rect location) {
    double displayedWidth = MediaQuery.of(context).size.width;
    double scaleX = displayedWidth / originalWidth;
    return location.left * scaleX - 36;
  }

  // Hàm tính toán vị trí trên đã được tỷ lệ hóa
  double _scaledTop(Rect location) {
    double displayedHeight = _getImageDisplayedHeight();
    double scaleY = displayedHeight / originalHeight;
    return location.top * scaleY - 50.h;
  }

  // Hàm lấy chiều cao hiển thị của hình ảnh
  double _getImageDisplayedHeight() {
    double displayedWidth =
        MediaQuery.of(context).size.width; // Lấy chiều rộng hiển thị
    return (originalHeight * displayedWidth) /
        originalWidth; // Tính chiều cao hiển thị
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _imageFile == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _imageFile!, // Hiển thị hình ảnh
                                width: constraints.maxWidth,
                                height: _getImageDisplayedHeight(),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Iterate over _kiotLocations to display each location
                          for (int index = 0;
                              index < _bookStoresWithPosition.length;
                              index++)
                            if (_bookStoresWithPosition[index].position != null)
                              Positioned(
                                left: _scaledLeft(
                                    _bookStoresWithPosition[index].position!),
                                top: _scaledTop(
                                    _bookStoresWithPosition[index].position!),
                                child: GestureDetector(
                                  onTap: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BookStoreDetailPage(
                                          storeId:
                                              _bookStoresWithPosition[index]
                                                  .store['storeId'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: CachedNetworkImage(
                                      imageUrl: _bookStoresWithPosition[index]
                                          .store['storeImage'],
                                      width: 54,
                                      height: 50,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                          if (_bookStoresWithPosition.isNotEmpty)
                            for (int index = 0;
                                index < _bookStoresWithPosition.length;
                                index++)
                              if (_bookStoresWithPosition[index].position !=
                                  null)
                                Positioned(
                                  left: _scaledLeft(
                                          _bookStoresWithPosition[index]
                                              .position!) +
                                      15,
                                  top: _scaledTop(_bookStoresWithPosition[index]
                                          .position!) -
                                      30,
                                  child: GestureDetector(
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BookStoreDetailPage(
                                            storeId:
                                                _bookStoresWithPosition[index]
                                                    .store['storeId'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Icon(Icons.location_on,
                                        color: Colors.red),
                                  ),
                                ),
                          Positioned(
                            left: 70.w,
                            top: 350.h,
                            child: const Column(
                              children: [
                                Icon(Icons.location_on, color: Colors.green),
                                Text(
                                  'You are here',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildNote(),
                ],
              ),
            ),
    );
  }

  Widget _buildNote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Chú thích",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        ..._buildLocationRows(),
      ],
    );
  }

  final String storeNote =
      "Vị trí cửa hàng sách có sách, click vào icon trên bản đồ để xem thêm thông tin";

  final String eventNote = "Vị trí sự kiện";

  List<Widget> _buildLocationRows() {
    return [
      _buildLocationRow(
          Icons.location_on,
          Colors.red,
          _bookStoresWithPosition[0].store['storeName'] != null
              ? storeNote
              : eventNote),
      const SizedBox(height: 10),
      _buildLocationRow(Icons.location_on, Colors.green, "You are here"),
    ];
  }

  Widget _buildLocationRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color),
        Text(text),
      ],
    );
  }
}

class _BookStoreWithPosition {
  final Map<String, dynamic> store;
  final Rect? position;

  _BookStoreWithPosition({required this.store, this.position});
}
