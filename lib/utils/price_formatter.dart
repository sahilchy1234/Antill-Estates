class PriceFormatter {
  /// Format price string to Indian Rupee format with commas
  /// 
  /// Examples:
  /// - "4500000" -> "₹45,00,000"
  /// - "₹45 Lakh" -> "₹45,00,000"
  /// - "₹85 Lakh - ₹1 Cr" -> "₹85,00,000 - ₹1,00,00,000"
  /// - "₹50 Lakh - ₹1 Cr" -> "₹50,00,000 - ₹1,00,00,000"
  static String formatPrice(String priceString) {
    if (priceString.isEmpty) return '₹0';
    
    // Remove existing ₹ symbol and extra spaces
    String cleanPrice = priceString.replaceAll('₹', '').trim();
    
    // Handle range prices (e.g., "45 Lakh - 1 Cr")
    if (cleanPrice.contains(' - ')) {
      List<String> parts = cleanPrice.split(' - ');
      String minPrice = _formatSinglePrice(parts[0].trim());
      String maxPrice = _formatSinglePrice(parts[1].trim());
      return '$minPrice - $maxPrice';
    }
    
    // Handle single price
    return _formatSinglePrice(cleanPrice);
  }
  
  /// Format a single price value
  static String _formatSinglePrice(String price) {
    if (price.isEmpty) return '₹0';
    
    // Handle different formats
    if (price.toLowerCase().contains('lakh')) {
      return _formatLakhPrice(price);
    } else if (price.toLowerCase().contains('cr') || price.toLowerCase().contains('crore')) {
      return _formatCrorePrice(price);
    } else if (price.toLowerCase().contains('k') && !price.toLowerCase().contains('lakh')) {
      return _formatThousandPrice(price);
    } else {
      // Assume it's a raw number
      return _formatRawNumber(price);
    }
  }
  
  /// Format Lakh prices (e.g., "45 Lakh" -> "₹45,00,000")
  static String _formatLakhPrice(String price) {
    // Extract number from "45 Lakh" format
    RegExp regex = RegExp(r'(\d+(?:\.\d+)?)');
    Match? match = regex.firstMatch(price);
    
    if (match != null) {
      double lakhValue = double.parse(match.group(1)!);
      int rupees = (lakhValue * 100000).round();
      return _formatRawNumber(rupees.toString());
    }
    
    return '₹0';
  }
  
  /// Format Crore prices (e.g., "1 Cr" -> "₹1,00,00,000")
  static String _formatCrorePrice(String price) {
    // Extract number from "1 Cr" format
    RegExp regex = RegExp(r'(\d+(?:\.\d+)?)');
    Match? match = regex.firstMatch(price);
    
    if (match != null) {
      double croreValue = double.parse(match.group(1)!);
      int rupees = (croreValue * 10000000).round();
      return _formatRawNumber(rupees.toString());
    }
    
    return '₹0';
  }
  
  /// Format Thousand prices (e.g., "45K" -> "₹45,000")
  static String _formatThousandPrice(String price) {
    // Extract number from "45K" format
    RegExp regex = RegExp(r'(\d+(?:\.\d+)?)');
    Match? match = regex.firstMatch(price);
    
    if (match != null) {
      double thousandValue = double.parse(match.group(1)!);
      int rupees = (thousandValue * 1000).round();
      return _formatRawNumber(rupees.toString());
    }
    
    return '₹0';
  }
  
  /// Format raw number with Indian numbering system (lakhs and crores)
  static String _formatRawNumber(String numberString) {
    // Remove any non-digit characters except decimal point
    String cleanNumber = numberString.replaceAll(RegExp(r'[^\d.]'), '');
    
    if (cleanNumber.isEmpty) return '₹0';
    
    // Parse the number
    double number = double.parse(cleanNumber);
    int rupees = number.round();
    
    // Format with Indian numbering system
    if (rupees >= 10000000) { // 1 Crore and above
      double crores = rupees / 10000000;
      if (crores == crores.roundToDouble()) {
        return '₹${crores.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{2})+(?!\d))'), (Match m) => '${m[1]},')} Cr';
      } else {
        return '₹${crores.toStringAsFixed(1).replaceAllMapped(RegExp(r'(\d)(?=(\d{2})+(?!\d))'), (Match m) => '${m[1]},')} Cr';
      }
    } else if (rupees >= 100000) { // 1 Lakh and above
      double lakhs = rupees / 100000;
      if (lakhs == lakhs.roundToDouble()) {
        return '₹${lakhs.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{2})+(?!\d))'), (Match m) => '${m[1]},')} Lakh';
      } else {
        return '₹${lakhs.toStringAsFixed(1).replaceAllMapped(RegExp(r'(\d)(?=(\d{2})+(?!\d))'), (Match m) => '${m[1]},')} Lakh';
      }
    } else {
      // Below 1 Lakh - use standard comma formatting
      return '₹${rupees.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    }
  }
  
  /// Get a simplified price range for display
  /// Returns the minimum price in a readable format
  static String getMinPrice(String priceString) {
    if (priceString.isEmpty) return '₹0';
    
    String cleanPrice = priceString.replaceAll('₹', '').trim();
    
    if (cleanPrice.contains(' - ')) {
      String minPrice = cleanPrice.split(' - ')[0].trim();
      return _formatSinglePrice(minPrice);
    }
    
    return _formatSinglePrice(cleanPrice);
  }
  
  /// Check if price is in a range format
  static bool isRangePrice(String priceString) {
    return priceString.contains(' - ');
  }
  
  /// Format a numeric price value (double/int) to Indian Rupee format
  /// 
  /// Examples:
  /// - 4500000 -> "₹45 Lakh"
  /// - 85000000 -> "₹8.5 Cr"
  /// - 45000 -> "₹45,000"
  static String formatNumericPrice(double price) {
    if (price.isNaN || price.isInfinite || price < 0) {
      return '₹0';
    }
    
    int rupees = price.round();
    
    // Format with Indian numbering system
    if (rupees >= 10000000) { // 1 Crore and above
      double crores = rupees / 10000000;
      if (crores == crores.roundToDouble()) {
        return '₹${crores.round()} Cr';
      } else {
        return '₹${crores.toStringAsFixed(1)} Cr';
      }
    } else if (rupees >= 100000) { // 1 Lakh and above
      double lakhs = rupees / 100000;
      if (lakhs == lakhs.roundToDouble()) {
        return '₹${lakhs.round()} Lakh';
      } else {
        return '₹${lakhs.toStringAsFixed(1)} Lakh';
      }
    } else {
      // Below 1 Lakh - use standard comma formatting
      return '₹${rupees.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    }
  }
}
