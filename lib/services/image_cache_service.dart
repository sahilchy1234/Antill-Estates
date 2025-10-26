import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Advanced image caching service with memory and disk cache
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._();
  static ImageCacheService get instance => _instance;
  
  ImageCacheService._();
  
  // Memory cache for images (LRU cache)
  final Map<String, Uint8List> _memoryCache = {};
  final List<String> _memoryCacheKeys = [];
  
  // Cache configuration
  static const int _maxMemoryCacheSize = 50; // 50 images in memory
  static const int _maxDiskCacheSize = 100 * 1024 * 1024; // 100 MB
  static const Duration _cacheExpiration = Duration(days: 7);
  
  Directory? _cacheDirectory;
  
  /// Initialize image cache
  Future<void> init() async {
    try {
      final tempDir = await getTemporaryDirectory();
      _cacheDirectory = Directory('${tempDir.path}/image_cache');
      
      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }
      
      // Clean old cache on init
      await _cleanOldCache();
    } catch (e) {
      print('Error initializing image cache: $e');
    }
  }
  
  /// Get image from cache or download
  Future<Uint8List?> getImage(String url) async {
    try {
      final cacheKey = _getCacheKey(url);
      
      // Check memory cache first
      if (_memoryCache.containsKey(cacheKey)) {
        _updateMemoryCacheLRU(cacheKey);
        return _memoryCache[cacheKey];
      }
      
      // Check disk cache
      final cachedFile = await _getCachedFile(cacheKey);
      if (cachedFile != null && await cachedFile.exists()) {
        final bytes = await cachedFile.readAsBytes();
        _addToMemoryCache(cacheKey, bytes);
        return bytes;
      }
      
      // Download image
      return await _downloadAndCacheImage(url, cacheKey);
    } catch (e) {
      print('Error getting image from cache: $e');
      return null;
    }
  }
  
  /// Pre-cache images
  Future<void> preCacheImages(List<String> urls) async {
    for (final url in urls) {
      try {
        await getImage(url);
      } catch (e) {
        print('Error pre-caching image: $e');
      }
    }
  }
  
  /// Download and cache image
  Future<Uint8List?> _downloadAndCacheImage(String url, String cacheKey) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        
        // Save to disk cache
        await _saveToDiskCache(cacheKey, bytes);
        
        // Add to memory cache
        _addToMemoryCache(cacheKey, bytes);
        
        return bytes;
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
    return null;
  }
  
  /// Save image to disk cache
  Future<void> _saveToDiskCache(String cacheKey, Uint8List bytes) async {
    try {
      final file = await _getCachedFile(cacheKey);
      if (file != null) {
        await file.writeAsBytes(bytes);
      }
    } catch (e) {
      print('Error saving to disk cache: $e');
    }
  }
  
  /// Get cached file
  Future<File?> _getCachedFile(String cacheKey) async {
    if (_cacheDirectory == null) return null;
    return File('${_cacheDirectory!.path}/$cacheKey');
  }
  
  /// Add image to memory cache (LRU)
  void _addToMemoryCache(String cacheKey, Uint8List bytes) {
    // Remove oldest if cache is full
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      final oldestKey = _memoryCacheKeys.removeAt(0);
      _memoryCache.remove(oldestKey);
    }
    
    _memoryCache[cacheKey] = bytes;
    _memoryCacheKeys.add(cacheKey);
  }
  
  /// Update memory cache LRU
  void _updateMemoryCacheLRU(String cacheKey) {
    _memoryCacheKeys.remove(cacheKey);
    _memoryCacheKeys.add(cacheKey);
  }
  
  /// Generate cache key from URL
  String _getCacheKey(String url) {
    final bytes = utf8.encode(url);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
  
  /// Clean old cache files
  Future<void> _cleanOldCache() async {
    try {
      if (_cacheDirectory == null || !await _cacheDirectory!.exists()) return;
      
      final files = _cacheDirectory!.listSync();
      final now = DateTime.now();
      
      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          final age = now.difference(stat.modified);
          
          if (age > _cacheExpiration) {
            await file.delete();
          }
        }
      }
      
      // Check total cache size
      await _enforceCacheSizeLimit();
    } catch (e) {
      print('Error cleaning old cache: $e');
    }
  }
  
  /// Enforce cache size limit
  Future<void> _enforceCacheSizeLimit() async {
    try {
      if (_cacheDirectory == null || !await _cacheDirectory!.exists()) return;
      
      final files = _cacheDirectory!.listSync();
      int totalSize = 0;
      final fileStats = <Map<String, dynamic>>[];
      
      // Calculate total size and collect file stats
      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
          fileStats.add({
            'file': file,
            'size': stat.size,
            'modified': stat.modified,
          });
        }
      }
      
      // If over limit, delete oldest files
      if (totalSize > _maxDiskCacheSize) {
        // Sort by modified date (oldest first)
        fileStats.sort((a, b) => 
          (a['modified'] as DateTime).compareTo(b['modified'] as DateTime)
        );
        
        int deletedSize = 0;
        for (final fileStat in fileStats) {
          if (totalSize - deletedSize <= _maxDiskCacheSize) break;
          
          final file = fileStat['file'] as File;
          await file.delete();
          deletedSize += fileStat['size'] as int;
        }
      }
    } catch (e) {
      print('Error enforcing cache size limit: $e');
    }
  }
  
  /// Clear all image cache
  Future<void> clearCache() async {
    try {
      // Clear memory cache
      _memoryCache.clear();
      _memoryCacheKeys.clear();
      
      // Clear disk cache
      if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
        await _cacheDirectory!.delete(recursive: true);
        await _cacheDirectory!.create(recursive: true);
      }
    } catch (e) {
      print('Error clearing image cache: $e');
    }
  }
  
  /// Get cache size
  Future<int> getCacheSize() async {
    try {
      if (_cacheDirectory == null || !await _cacheDirectory!.exists()) return 0;
      
      final files = _cacheDirectory!.listSync();
      int totalSize = 0;
      
      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
        }
      }
      
      return totalSize;
    } catch (e) {
      print('Error getting cache size: $e');
      return 0;
    }
  }
  
  /// Get cache stats
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final diskSize = await getCacheSize();
      final fileCount = _cacheDirectory != null && await _cacheDirectory!.exists()
          ? _cacheDirectory!.listSync().length
          : 0;
      
      return {
        'memoryCount': _memoryCache.length,
        'diskCount': fileCount,
        'diskSize': diskSize,
        'diskSizeMB': (diskSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      print('Error getting cache stats: $e');
      return {};
    }
  }
}

/// Cached network image widget with fallback
class CachedNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const CachedNetworkImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<CachedNetworkImage> createState() => _CachedNetworkImageState();
}

class _CachedNetworkImageState extends State<CachedNetworkImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final bytes = await ImageCacheService.instance.getImage(widget.imageUrl);

      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
          _hasError = bytes == null;
        });
      }
    } catch (e) {
      print('Error loading image: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_isLoading) {
      child = widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
    } else if (_hasError || _imageBytes == null) {
      child = widget.errorWidget ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
    } else {
      child = Image.memory(
        _imageBytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit ?? BoxFit.cover,
      );
    }

    if (widget.borderRadius != null) {
      child = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: child,
      );
    }

    return child;
  }
}