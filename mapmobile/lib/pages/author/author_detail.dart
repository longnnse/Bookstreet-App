import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapmobile/services/author_service.dart';

class AuthorDetail extends StatefulWidget {
  final String authorId;

  const AuthorDetail({super.key, required this.authorId});

  @override
  State<AuthorDetail> createState() => _AuthorDetailState();
}

class _AuthorDetailState extends State<AuthorDetail> {
  Map<String, dynamic>? authorDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await getAuthorDetail();
    });
  }

  Future<void> getAuthorDetail() async {
    setState(() {
      isLoading = true;
    });
    await getAuthorById(widget.authorId).then((res) {
      setState(() {
        authorDetail = res;
        isLoading = false;
      });
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : authorDetail == null
              ? const Center(child: Text('Không tìm thấy thông tin tác giả'))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 300,
                      floating: false,
                      pinned: true,
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(900),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black87,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          authorDetail!['authorName'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 3.0,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ],
                          ),
                        ),
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            authorDetail!['urlImage'] != null
                                ? CachedNetworkImage(
                                    imageUrl: authorDetail!['urlImage']!,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      'assets/images/author_avatar.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Image.asset(
                                    'assets/images/author_avatar.jpg',
                                    fit: BoxFit.cover,
                                  ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withAlpha(700),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (authorDetail!['dateOfBirth'] != null) ...[
                              _buildInfoSection(
                                'Ngày sinh',
                                _formatDate(authorDetail!['dateOfBirth']),
                                Icons.cake,
                              ),
                              const SizedBox(height: 24),
                            ],
                            if (authorDetail!['biography'] != null) ...[
                              _buildInfoSection(
                                'Tiểu sử',
                                authorDetail!['biography'],
                                Icons.history_edu,
                              ),
                              const SizedBox(height: 24),
                            ],
                            if (authorDetail!['description'] != null) ...[
                              _buildInfoSection(
                                'Mô tả',
                                authorDetail!['description'],
                                Icons.description,
                              ),
                            ],
                            if (authorDetail!['books'] != null &&
                                authorDetail!['books'].isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _buildBooksList(authorDetail!['books']),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksList(List<dynamic> books) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.book, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              'Tác phẩm',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: book['coverImage'] != null
                      ? CachedNetworkImage(
                          imageUrl: book['coverImage'],
                          width: 60,
                          height: 90,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            width: 60,
                            height: 90,
                            color: Colors.grey[300],
                            child: const Icon(Icons.book),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 90,
                          color: Colors.grey[300],
                          child: const Icon(Icons.book),
                        ),
                ),
                title: Text(
                  book['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(book['publishYear']?.toString() ?? ''),
              ),
            );
          },
        ),
      ],
    );
  }
}
