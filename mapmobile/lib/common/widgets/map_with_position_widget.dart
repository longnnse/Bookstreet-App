import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:mapmobile/shared/networkimagefallback.dart';
import 'package:mapmobile/shared/text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

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
  final String mapImageUrl;
  final String locationName;
  final String storeName;
  final String openingHours;
  final String closingHours;
  final String storeImageUrl;

  // Constructor để khởi tạo các thuộc tính
  const MapWithPositionWidget(
      {super.key,
      required this.mapImageUrl,
      required this.locationName,
      required this.storeName,
      required this.openingHours,
      required this.closingHours,
      required this.storeImageUrl});

  @override
  MapWithPositionWidgetState createState() => MapWithPositionWidgetState();
}

// Trạng thái của MapWithPositionWidget
class MapWithPositionWidgetState extends State<MapWithPositionWidget> {
  // Biến để lưu trữ hình ảnh và vị trí của A1
  File? _imageFile;
  Rect? _a1Position;
  double originalWidth = 1; // Chiều rộng gốc của hình ảnh
  double originalHeight = 1; // Chiều cao gốc của hình ảnh

  @override
  void initState() {
    super.initState();
    // Gọi hàm _processImage sau khi khung hình đã được vẽ
   _processImage();
  }

  // Hàm xử lý hình ảnh
  Future<void> _processImage() async {
    final file = await _loadImageFromUrl(); // Tải hình ảnh từ tài nguyên
    if (file != null) {
      await _detectText(file); // Nhận diện văn bản trong hình ảnh
      setState(() => _imageFile = file); // Cập nhật trạng thái với hình ảnh mới
    }
  }

  // Hàm tải hình ảnh từ tài nguyên
  Future<File?> _loadImageFromUrl() async {
    try {
      final response = await http.get(Uri.parse(widget.mapImageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/map_image.png';
        final file = File(filePath);
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
    final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin); // Khởi tạo bộ nhận diện văn bản
    final recognizedText = await textRecognizer.processImage(
      InputImage.fromFile(imageFile), // Xử lý hình ảnh
    );

    // Duyệt qua các khối văn bản và dòng
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        if (line.text.contains(widget.locationName)) {
          // Kiểm tra xem tên cửa hàng có trong dòng không
          _a1Position = line.boundingBox; // Lưu vị trí của A1
          break;
        }
      }
    }
    setState(() {}); // Cập nhật trạng thái
    textRecognizer.close(); // Đóng bộ nhận diện văn bản
  }

  // Hàm tính toán vị trí bên trái đã được tỷ lệ hóa
  double _scaledLeft() {
    if (_a1Position == null) return 0; // Nếu không có vị trí, trả về 0
    double displayedWidth =
        MediaQuery.of(context).size.width; // Lấy chiều rộng hiển thị
    double scaleX = displayedWidth / originalWidth; // Tính tỷ lệ chiều rộng
    return _a1Position!.left * scaleX - 6.w; // Tính toán vị trí bên trái
  }

  // Hàm tính toán vị trí trên đã được tỷ lệ hóa
  double _scaledTop() {
    if (_a1Position == null) return 0; // Nếu không có vị trí, trả về 0
    double displayedHeight =
        _getImageDisplayedHeight(); // Lấy chiều cao hiển thị
    double scaleY = displayedHeight / originalHeight; // Tính tỷ lệ chiều cao
    return _a1Position!.top * scaleY - 100.h; // Tính toán vị trí trên
  }

  // Hàm lấy chiều cao hiển thị của hình ảnh
  double _getImageDisplayedHeight() {
    double displayedWidth =
        MediaQuery.of(context).size.width; // Lấy chiều rộng hiển thị
    return (originalHeight * displayedWidth) /
        originalWidth; // Tính chiều cao hiển thị
  }

  // Hàm hiển thị widget thông tin
  void _showInfoWidget(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            height: 200,
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: NetworkImageWithFallback(
                    imageUrl: widget.storeImageUrl,
                    fallbackWidget: const Icon(Icons.error),
                  ),
                ),
                const SizedBox(
                    width: 10), // Added spacing between image and text
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DynamicText(
                        text: widget.storeName,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      _buildInfoRow(
                          Icons.location_on, Colors.red, widget.locationName),
                      _buildInfoRow(Icons.schedule, Colors.green,
                          "${widget.openingHours} - ${widget.closingHours}"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 5), // Added spacing between icon and text
        DynamicText(text: text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _imageFile == null // Nếu chưa có hình ảnh
        ? const Center(
            child: CircularProgressIndicator()) // Hiển thị vòng tròn tải
        : Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Image.file(
                        _imageFile!, // Hiển thị hình ảnh
                        width: constraints.maxWidth,
                        height: _getImageDisplayedHeight(),
                        fit: BoxFit.cover,
                      ),
                      if (_a1Position != null) // Nếu có vị trí A1
                        Positioned(
                          left: _scaledLeft(),
                          top: _scaledTop(),
                          child: GestureDetector(
                            onTap: () {
                              _showInfoWidget(context);
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

  List<Widget> _buildLocationRows() {
    return [
      _buildLocationRow(Icons.location_on, Colors.red,
          "Vị trí cửa hàng sách có sách, click vào icon trên bản đồ để xem thêm thông tin"),
      const SizedBox(height: 10),
      _buildLocationRow(Icons.location_on, Colors.green, "Vị trí của bạn"),
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
