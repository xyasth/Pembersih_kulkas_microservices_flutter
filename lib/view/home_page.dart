// import 'package:flutter/material.dart';
// import '../models/home_model.dart';
// import '../services/home_service.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late Future<List<Recipe>> _recipes;

//   @override
//   void initState() {
//     super.initState();
//     _recipes = ApiService().fetchRecipes();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Resep Makanan'),
//         backgroundColor: Colors.deepOrange,
//         centerTitle: true,
//       ),
//       body: FutureBuilder<List<Recipe>>(
//         future: _recipes,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Text(
//                 'Gagal memuat data:\n${snapshot.error}',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: Colors.red),
//               ),
//             );
//           }

//           final recipes = snapshot.data;

//           if (recipes == null || recipes.isEmpty) {
//             return const Center(child: Text('Tidak ada resep ditemukan.'));
//           }

//           return Padding(
//             padding: const EdgeInsets.all(10),
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2, // Dua kolom
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//                 childAspectRatio: 0.75, // Tinggi dibanding lebar
//               ),
//               itemCount: recipes.length,
//               itemBuilder: (context, index) {
//                 final recipe = recipes[index];
//                 return Card(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 4,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       Expanded(
//                         child: ClipRRect(
//                           borderRadius: const BorderRadius.vertical(
//                               top: Radius.circular(12)),
//                               // child: Image.network('https://picsum.photos/200/300')
//                           child: Image.network(
//                             recipe.imageUrl,
//                             headers: {
//                               'User-Agent':'mozilla'
//                             },
//                             fit: BoxFit.cover,
//                             // ⬇️ Tambahkan ini untuk indikator loading
//                             loadingBuilder: (context, child, loadingProgress) {
//                               if (loadingProgress == null) return child;
//                               return const Center(
//                                   child: CircularProgressIndicator());
//                             },
//                             // ⬇️ Tambahkan ini untuk handle error saat gambar gagal dimuat
//                             errorBuilder: (context, error, stackTrace) {
//                               return const Center(
//                                 child: Icon(Icons.broken_image,
//                                     size: 48, color: Colors.grey),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           recipe.title,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//================================================================================ 
// import 'package:flutter/material.dart';
// import '../models/home_model.dart';
// import '../services/home_service.dart';
// import 'recipe_detail_page.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late Future<List<Recipe>> _recipes;

//   @override
//   void initState() {
//     super.initState();
//     _recipes = ApiService().fetchRecipes();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Resep Makanan'),
//         backgroundColor: Colors.deepOrange,
//         centerTitle: true,
//       ),
//       body: FutureBuilder<List<Recipe>>(
//         future: _recipes,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error, size: 64, color: Colors.red),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Gagal memuat data:\n${snapshot.error}',
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _recipes = ApiService().fetchRecipes();
//                       });
//                     },
//                     child: const Text('Coba Lagi'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           final recipes = snapshot.data;

//           if (recipes == null || recipes.isEmpty) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text('Tidak ada resep ditemukan.'),
//                 ],
//               ),
//             );
//           }

//           return Padding(
//             padding: const EdgeInsets.all(10),
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2, // Dua kolom
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//                 childAspectRatio: 0.75, // Tinggi dibanding lebar
//               ),
//               itemCount: recipes.length,
//               itemBuilder: (context, index) {
//                 final recipe = recipes[index];
//                 return GestureDetector(
//                   onTap: () {
//                     // Navigasi ke detail page
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => RecipeDetailPage(
//                           recipeId: recipe.id,
//                           recipeTitle: recipe.title,
//                         ),
//                       ),
//                     );
//                   },
//                   child: Card(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 4,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Expanded(
//                           child: ClipRRect(
//                             borderRadius: const BorderRadius.vertical(
//                                 top: Radius.circular(12)),
//                             child: Image.network(
//                               recipe.imageUrl,
//                               headers: {
//                                 'User-Agent': 'mozilla'
//                               },
//                               fit: BoxFit.cover,
//                               // Loading indicator
//                               loadingBuilder: (context, child, loadingProgress) {
//                                 if (loadingProgress == null) return child;
//                                 return const Center(
//                                     child: CircularProgressIndicator());
//                               },
//                               // Error handler
//                               errorBuilder: (context, error, stackTrace) {
//                                 return const Center(
//                                   child: Icon(Icons.broken_image,
//                                       size: 48, color: Colors.grey),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             recipe.title,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         // Tambahkan indikator bahwa card bisa ditekan
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Lihat Detail',
//                                 style: TextStyle(
//                                   color: Colors.deepOrange,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               Icon(
//                                 Icons.arrow_forward_ios,
//                                 size: 12,
//                                 color: Colors.deepOrange,
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

//=======================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/home_model.dart';
import '../models/youtube_video_model.dart'; // Import model YouTube baru
import '../services/home_service.dart';
import '../services/youtube_service.dart'; // Import service YouTube baru
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

  @override
  void initState() {
    super.initState();
    _recipes = ApiService().fetchRecipes();
  }

  Future<void> _searchYouTubeVideos(String query) async {
    if (query.isEmpty) {
      setState(() {
        _showYouTubeResults = false;
        _youtubeVideos = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showYouTubeResults = true;
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
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencari video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchYouTubeUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka video YouTube'),
            backgroundColor: Colors.red,
          ),
        );
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
          prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _showYouTubeResults = false;
                      _youtubeVideos = [];
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
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_youtubeVideos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Tidak ada video ditemukan'),
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
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      video.thumbnailUrl,
                      width: 120,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 90,
                          color: Colors.grey[300],
                          child: const Icon(Icons.play_circle_outline, size: 40),
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
                                 color: Colors.deepOrange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Tonton Video',
                              style: TextStyle(
                                color: Colors.deepOrange,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Resep Makanan'),
        backgroundColor: Colors.deepOrange,
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
                                   color: Colors.deepOrange, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Video Tutorial: "${_searchController.text}"',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                'Gagal memuat data:\n${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _recipes = ApiService().fetchRecipes();
                                  });
                                },
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        );
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
                            ],
                          ),
                        );
                      }

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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipeDetailPage(
                                      recipeId: recipe.id,
                                      recipeTitle: recipe.title,
                                    ),
                                  ),
                                );
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
                                            return const Center(
                                                child: CircularProgressIndicator());
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(Icons.broken_image,
                                                  size: 48, color: Colors.grey),
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
                                              color: Colors.deepOrange,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 12,
                                            color: Colors.deepOrange,
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