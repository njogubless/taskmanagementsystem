class StringUtils {
  static List<String> parseTags(String tagsStr) {
    if (tagsStr.isEmpty) return [];
    return tagsStr.split(',').map((tag) => tag.trim()).toList();
  }
  
  static String escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}