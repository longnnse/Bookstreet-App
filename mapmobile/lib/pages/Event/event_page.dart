import 'package:flutter/material.dart';
import 'package:mapmobile/pages/Event/widget/event_list.dart';
import 'package:mapmobile/services/event_service.dart';
import 'package:shimmer/shimmer.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  List<dynamic> eventList = [];
  bool isLoading = true;
  bool isSearching = false;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final EventService _eventService = EventService();

  Future<void> _fetchEvents({String? search}) async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await _eventService.getEvent(search: search);
      if (mounted) {
        final now = DateTime.now();
        final filteredEvents = response.where((event) {
          try {
            final startDate = DateTime.parse(event['starDate']);
            final endDate = DateTime.parse(event['endDate']);
            return now.isAfter(startDate) && now.isBefore(endDate);
          } catch (e) {
            return false; // Skip events with invalid dates
          }
        }).toList();

        setState(() {
          eventList = filteredEvents;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Lỗi khi tải sự kiện. Vui lòng thử lại.';
          isLoading = false;
        });
      }
    }
  }

  Future<void> onTextChange(String text) async {
    setState(() {
      isSearching = true;
    });
    await _fetchEvents(search: text);
    setState(() {
      isSearching = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: onTextChange,
        decoration: InputDecoration(
          hintText: 'aTìm kiếm sự kiện...',
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.primary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    onTextChange('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            height: 120,
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'Đã xảy ra lỗi',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => _fetchEvents(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy sự kiện',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Điều chỉnh tìm kiếm hoặc kiểm tra lại sau',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sự kiện'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _fetchEvents(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildSearchBar(),
                ),
              ),
              if (isLoading)
                SliverFillRemaining(
                  child: _buildLoadingShimmer(),
                )
              else if (errorMessage != null)
                SliverFillRemaining(
                  child: _buildErrorState(),
                )
              else if (eventList.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: Eventlist(eventList: eventList),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
