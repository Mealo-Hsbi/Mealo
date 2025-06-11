// lib/common/utils/html_util.dart
import 'package:html_unescape/html_unescape.dart';

class HtmlUtil {
  static String stripHtmlTags(String htmlString) {
    if (htmlString.isEmpty) {
      return '';
    }
    // Entferne HTML-Tags mit einem regulären Ausdruck
    String strippedString = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
    // Entschlüssele HTML-Entities (z.B. &amp; zu &)
    var unescape = HtmlUnescape();
    return unescape.convert(strippedString);
  }
}