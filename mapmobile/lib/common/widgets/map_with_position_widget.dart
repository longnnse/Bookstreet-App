import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:mapmobile/models/map_model.dart';
import 'package:mapmobile/pages/book_store_detail/book_store_detail_page.dart';
import 'package:mapmobile/services/event_service.dart';
import 'package:mapmobile/services/store_service.dart';
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

enum MapType { store, event, showAll }

extension MapTypeExtension on MapType {
  String get note {
    switch (this) {
      case MapType.store:
        return "Vị trí cửa hàng sách có sách, click vào icon trên bản đồ để xem thêm thông tin";
      case MapType.event:
        return "Vị trí sự kiện";
      case MapType.showAll:
        return "Vị trí cửa hàng sách, click vào icon trên bản đồ để xem thêm thông tin";
    }
  }
}

class LocationWithPosition<T> {
  final T data;
  Rect? position;
  final MapType type;

  LocationWithPosition({
    required this.data,
    this.position,
    required this.type,
  });

  void setPosition(Rect position) {
    this.position = position;
  }
}

typedef BookStoreOrEventWithPosition
    = LocationWithPosition<Map<String, dynamic>>;

// Keeping this for backward compatibility
class EventWithPosition {
  final Map<String, dynamic> event;
  Rect? position;

  EventWithPosition({required this.event, this.position});

  void setPosition(Rect position) {
    this.position = position;
  }
}

class MapWithPositionWidget extends StatefulWidget {
  final String? storeId;
  final String? eventId;
  final MapType mapType;

  // Constructor để khởi tạo các thuộc tính
  const MapWithPositionWidget({
    super.key,
    this.storeId,
    this.eventId,
    required this.mapType,
  }) : assert(
            (mapType == MapType.store && storeId != null) ||
                (mapType == MapType.event && eventId != null) ||
                mapType == MapType.showAll,
            'storeId is required for MapType.store and eventId is required for MapType.event');

  @override
  MapWithPositionWidgetState createState() => MapWithPositionWidgetState();
}

// Trạng thái của MapWithPositionWidget
class MapWithPositionWidgetState extends State<MapWithPositionWidget> {
  final List<BookStoreOrEventWithPosition> _bookStoresWithPosition = [];
  final EventService _eventService = EventService();
  final StoreService _storeService = StoreService();

  double originalWidth = 1;
  double originalHeight = 1;

  // Define _imageFile to store the loaded image
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.mapType != MapType.showAll && widget.storeId != null) {
        final store = await _fetchStore(widget.storeId!);

        if (store != null) {
          _bookStoresWithPosition.add(BookStoreOrEventWithPosition(
            data: store,
            type: MapType.store,
          ));
        }
      }

      if (widget.mapType != MapType.showAll && widget.eventId != null) {
        final event = await _fetchEvent(widget.eventId!);

        if (event != null) {
          _bookStoresWithPosition.add(BookStoreOrEventWithPosition(
            data: event,
            type: MapType.event,
          ));
        }
      }

      await _processImage();
    });
  }

  Future<Map<String, dynamic>?> _fetchStore(String storeId) async {
    try {
      final res = await _storeService.getStoreById(storeId);
      return res;
    } catch (error) {
      debugPrint("Error fetching store: $error");
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchEvent(String eventId) async {
    try {
      final res = await _eventService.getEventById(id: eventId);
      return res;
    } catch (error) {
      debugPrint("Error fetching event: $error");
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
      final filePath = '${tempDir.path}/${image.split('/').last}';
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

    try {
      // Process image once
      final recognizedText = await textRecognizer.processImage(
        InputImage.fromFile(imageFile),
      );

      // Determine which locations to check based on map type
      final locationsToCheck = widget.mapType == MapType.showAll
          ? model.locations
          : [
              {'locationName': _bookStoresWithPosition[0].data['locationName']}
            ];

      // Create a set of location names for faster lookups
      final locationNames = locationsToCheck
          .map<String>((location) => location['locationName'] as String)
          .toSet();

      // Add all locations to _bookStoresWithPosition if showing all
      if (widget.mapType == MapType.showAll) {
        _bookStoresWithPosition.addAll(
          locationsToCheck.map<BookStoreOrEventWithPosition>(
            (location) => BookStoreOrEventWithPosition(
              data: {
                'locationName': location['locationName'],
                'storeName': location['storeName'],
                'urlImage': location['storeImage'],
                'storeId': location['storeId'],
              },
              type: MapType.store,
            ),
          ),
        );
      }

      // Create a lookup map for faster access to stores by location name
      final Map<String, BookStoreOrEventWithPosition> storesByLocation = {
        for (var store in _bookStoresWithPosition)
          store.data['locationName']: store
      };

      // Process text blocks to find matching locations
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          // Find matching location name in the recognized text
          String? matchingLocationName;
          for (final name in locationNames) {
            if (line.text.contains(name)) {
              matchingLocationName = name;
              break; // Exit loop once a match is found
            }
          }

          // Update position for matching store
          if (matchingLocationName != null) {
            final matchingStore = storesByLocation[matchingLocationName];
            if (matchingStore != null) {
              matchingStore.setPosition(line.boundingBox);
            }
          }
        }
      }

      setState(() {}); // Update the UI
    } finally {
      // Ensure resources are released
      textRecognizer.close();
    }
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            if (_imageFile != null)
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
                              if (_bookStoresWithPosition[index].position !=
                                  null)
                                Positioned(
                                  left: _scaledLeft(
                                      _bookStoresWithPosition[index].position!),
                                  top: _scaledTop(
                                      _bookStoresWithPosition[index].position!),
                                  child: GestureDetector(
                                    onTap: () async {
                                      navigate(index);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: CachedNetworkImage(
                                        imageUrl: _bookStoresWithPosition[index]
                                            .data['urlImage'],
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
                                    top: _scaledTop(
                                            _bookStoresWithPosition[index]
                                                .position!) -
                                        30,
                                    child: GestureDetector(
                                      onTap: () async {
                                        navigate(index);
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
                    if (_bookStoresWithPosition.isNotEmpty) _buildNote(),
                  ],
                ),
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
      _buildLocationRow(Icons.location_on, Colors.red, widget.mapType.note),
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

  void navigate(int index) {
    if (widget.mapType == MapType.store || widget.mapType == MapType.showAll) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookStoreDetailPage(
            storeId: _bookStoresWithPosition[index].data['storeId'],
          ),
        ),
      );
    } else {
      context.pop();
    }
  }
}
