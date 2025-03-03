import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapmobile/shared/text.dart';
import 'package:mapmobile/util/util.dart';

class SouvenirList extends StatelessWidget {
  const SouvenirList({super.key, required this.souvenirs});
  final List<dynamic> souvenirs;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double parentWidth = constraints.maxWidth;
      double itemWidth = parentWidth / 6.2;
      double deviceHeight = MediaQuery.of(context).size.height;
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        height: deviceHeight - deviceHeight / 4,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 14.0,
            runSpacing: 8.0,
            children: [
              ...souvenirs.map((b) {
                final imageURL = isImageUrl(b["urlImage"] ?? "")
                    ? b["urlImage"]
                    : "https://inantao.com/wp-content/uploads/2021/03/3d-illustration-mockup-nbblank-hardcover-book-969x1024.jpg";
                return InkWell(
                  onTap: () {
                    context.push("/souvernir/${b["productId"]}");
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(255, 211, 211, 211))),
                    child: Column(
                      children: [
                        Image.network(imageURL,
                            fit: BoxFit.contain, width: itemWidth,
                            errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: itemWidth,
                            child: Icon(Icons.error),
                          ); // Display the fallback widget if an error occurs
                        }),
                        SizedBox(
                          width: itemWidth,
                          child: Text(
                            b["productName"],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 17),
                          ),
                        ),
                        SizedBox(
                            width: itemWidth,
                            child: DynamicText(text: formatToVND(b["price"])))
                      ],
                    ),
                  ),
                );
              })
            ],
          ),
        ),
      );
    });
  }
}
