import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:async';
import '../models/home_model.dart';
import '../models/youtube_video_model.dart';
import '../services/home_service.dart';
import '../services/youtube_service.dart';
import 'recipe_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Recipe>> _recipes;
  final TextEditingController _searchController = TextEditingController();
  final YouTubeService _youtubeService = YouTubeService();
  
  List<YouTubeVideo> _youtubeVideos = [];
  bool _isSearching = false;
  bool _showYouTubeResults = false;
  String? _youtubeError;

  @override
  void initState() {
    super.initState();
    _recipes = _fetchRecipesWithErrorHandling();
  }

  Future<List<Recipe>> _fetchRecipesWithErrorHandling() async {
    try {
      return await ApiService().fetchRecipes();
    } catch (e) {
      // Log error dan re-throw untuk ditangani oleh FutureBuilder
      debugPrint('Error fetching recipes: $e');
      rethrow;
    }
  }

  Future<void> _searchYouTubeVideos(String query) async {
    if (query.isEmpty) {
      setState(() {
        _showYouTubeResults = false;
        _youtubeVideos = [];
        _youtubeError = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showYouTubeResults = true;
      _youtubeError = null;
    });

    try {
      final videos = await _youtubeService.searchVideos(query);
      setState(() {
        _youtubeVideos = videos;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _youtubeVideos = [];
        _youtubeError = _getYouTubeErrorMessage(e);
      });
      
      if (mounted) {
        _showErrorSnackBar(_youtubeError!);
      }
    }
  }

  String _getYouTubeErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'Tidak ada koneksi internet untuk mencari video';
    } else if (error is TimeoutException) {
      return 'Pencarian video timeout, coba lagi';
    } else if (error.toString().contains('quota')) {
      return 'Kuota YouTube API habis, coba lagi nanti';
    } else if (error.toString().contains('403')) {
      return 'Akses YouTube API ditolak';
    } else {
      return 'Gagal mencari video: ${error.toString()}';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Tutup',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _launchYouTubeUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Cannot launch URL');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Tidak dapat membuka video YouTube');
      }
    }
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari resep makanan...',
          prefixIcon: const Icon(Icons.search, color: Colors.blue),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _showYouTubeResults = false;
                      _youtubeVideos = [];
                      _youtubeError = null;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onSubmitted: _searchYouTubeVideos,
        onChanged: (value) {
          setState(() {});
          if (value.isEmpty) {
            setState(() {
              _showYouTubeResults = false;
              _youtubeVideos = [];
              _youtubeError = null;
            });
          }
        },
      ),
    );
  }

  Widget _buildYouTubeResults() {
    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Mencari video...'),
            ],
          ),
        ),
      );
    }

    if (_youtubeError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _youtubeError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _searchYouTubeVideos(_searchController.text),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_youtubeVideos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.video_library_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text('Tidak ada video ditemukan'),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _youtubeVideos.length,
      itemBuilder: (context, index) {
        final video = _youtubeVideos[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _launchYouTubeUrl(video.youtubeUrl),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail with error handling
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      video.thumbnailUrl,
                      width: 120,
                      height: 90,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 120,
                          height: 90,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 90,
                          color: Colors.grey[300],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_circle_outline, size: 40, color: Colors.grey),
                              Text('Gambar\nTidak Tersedia', 
                                   style: TextStyle(fontSize: 10, color: Colors.grey),
                                   textAlign: TextAlign.center),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Video Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          video.channelTitle,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          video.description,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.play_arrow, 
                                 color: Colors.blue, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Tonton Video',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    String errorMessage = 'Terjadi kesalahan yang tidak diketahui';
    IconData errorIcon = Icons.error_outline;
    
    if (error.contains('SocketException') || error.contains('network')) {
      errorMessage = 'Tidak ada koneksi internet.\nPastikan Anda terhubung ke internet dan coba lagi.';
      errorIcon = Icons.wifi_off;
    } else if (error.contains('TimeoutException') || error.contains('timeout')) {
      errorMessage = 'Koneksi timeout.\nServer mungkin sedang sibuk, coba lagi nanti.';
      errorIcon = Icons.timer_off;
    } else if (error.contains('404')) {
      errorMessage = 'Data tidak ditemukan.\nAPI mungkin sedang bermasalah.';
      errorIcon = Icons.search_off;
    } else if (error.contains('500')) {
      errorMessage = 'Server sedang bermasalah.\nCoba lagi dalam beberapa menit.';
      errorIcon = Icons.cloud_off;
    } else if (error.contains('403') || error.contains('401')) {
      errorMessage = 'Akses tidak diizinkan.\nPeriksa konfigurasi API.';
      errorIcon = Icons.lock_outline;
    } else {
      errorMessage = 'Gagal memuat data:\n$error';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(errorIcon, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _recipes = _fetchRecipesWithErrorHandling();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeGrid(List<Recipe> recipes) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return GestureDetector(
            onTap: () {
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailPage(
                      recipeId: recipe.id,
                      recipeTitle: recipe.title,
                    ),
                  ),
                );
              } catch (e) {
                _showErrorSnackBar('Gagal membuka detail resep');
              }
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      child: Image.network(
                        recipe.imageUrl,
                        headers: {'User-Agent': 'mozilla'},
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.restaurant, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Gambar tidak\ntersedia', 
                                     style: TextStyle(color: Colors.grey, fontSize: 12),
                                     textAlign: TextAlign.center),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lihat Detail',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Resep Makanan'),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          
          // Content
          Expanded(
            child: _showYouTubeResults
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(Icons.video_library, 
                                   color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Video Tutorial: "${_searchController.text}"',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildYouTubeResults(),
                      ],
                    ),
                  )
                : FutureBuilder<List<Recipe>>(
                    future: _recipes,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Memuat resep...'),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return _buildErrorState(snapshot.error.toString());
                      }

                      final recipes = snapshot.data;

                      if (recipes == null || recipes.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restaurant_menu, 
                                   size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Tidak ada resep ditemukan.'),
                              SizedBox(height: 8),
                              Text('Coba lagi nanti atau periksa koneksi internet Anda.',
                                   style: TextStyle(color: Colors.grey, fontSize: 12),
                                   textAlign: TextAlign.center),
                            ],
                          ),
                        );
                      }

                      return _buildRecipeGrid(recipes);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}