import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mapmobile/common/widgets/map_with_position_widget.dart';
import 'package:mapmobile/shared/box.dart';

List<Map<String, dynamic>> menuItems = [
  {
    'icon': Icons.book,
    'title': 'Thông tin sách',
    'route': '/books',
    'backgroundColor': const Color(0xFFFFCC80), // Cam pastel sáng
    'accentColor': const Color(0xFFFF9800), // Cam đậm
  },
  {
    'icon': Icons.savings,
    'title': 'Điểm tích lũy',
    'route': '/points',
    'backgroundColor': const Color(0xFF80DEEA), // Xanh nước biển sáng
    'accentColor': const Color(0xFF00BCD4), // Xanh ngọc đậm
  },
  {
    'icon': Icons.redeem,
    'title': 'Đồ lưu niệm',
    'route': '/souvenir',
    'backgroundColor': const Color(0xFFFF8A80), // Đỏ hồng sáng
    'accentColor': const Color(0xFFD32F2F), // Đỏ đậm
  },
  {
    'icon': Icons.event,
    'title': 'Sự kiện',
    'route': '/event',
    'backgroundColor': const Color(0xFFB39DDB), // Tím pastel sáng
    'accentColor': const Color(0xFF673AB7), // Tím đậm
  },
  {
    'icon': Icons.map,
    'title': 'Bản đồ',
    'route': '/map',
    'backgroundColor': const Color(0xFFA5D6A7), // Xanh lá cây nhạt
    'accentColor': const Color(0xFF2E7D32), // Xanh lá cây rực rỡ
  },
];

class GradientMenu extends StatelessWidget {
  const GradientMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: menuItems.map((item) {
        // Sử dụng giá trị mặc định nếu không tìm thấy
        final Color backgroundColor = item['backgroundColor'] ?? Colors.grey;
        final Color accentColor = item['accentColor'] ?? Colors.blueGrey;

        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
          child: GestureDetector(
            onTap: () {
              if (item['route'] == '/map') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapWithPositionWidget(
                      isShowAll: true,
                      storeId: "0",
                    ),
                  ),
                );
              } else {
                context.push(item['route']);
              }
            },
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 1.sw / 4,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: accentColor,
              ),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GradientIconBox(
                      icon: Icon(
                        item['icon'],
                        color: backgroundColor,
                        size: 20,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: const Alignment(0.8, 1),
                        colors: <Color>[backgroundColor, accentColor],
                        tileMode: TileMode.mirror,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class GradientIconBox extends StatelessWidget {
  const GradientIconBox({
    super.key,
    required this.icon,
    this.gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment(0.8, 1),
      colors: <Color>[
        Color(0xff1f005c),
        Color(0xff5b0060),
        Color(0xff870160),
        Color(0xffac255e),
        Color(0xffca485c),
        Color(0xffe16b5c),
        Color(0xfff39060),
        Color(0xffffb56b),
      ],
      tileMode: TileMode.mirror,
    ),
  });

  final Icon icon;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return GradientBox(
      gradient: gradient,
      widget: Container(
        padding: const EdgeInsets.all(10),
        child: icon,
      ),
    );
  }
}
