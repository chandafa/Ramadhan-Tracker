import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuoteService {
  final List<String> _quotes = [
    "Allah does not burden a soul beyond that it can bear. (Baqarah: 286)",
    "So verily, with the hardship, there is relief. (Ash-Sharh: 6)",
    "The best of you are those who learn the Quran and teach it. (Bukhari)",
    "Fasting is a shield. (Muslim)",
    "When Ramadhan comes, the gates of Paradise are opened. (Bukhari)",
    "He who observes fasting during the month of Ramadan with Faith while seeking its reward from Allah, will have his past sins forgiven. (Bukhari)",
    "Practice charity, for it protects you from calamity.",
    "Do not lose hope, nor be sad. (Ali Imran: 139)",
    "Allah is with the patient. (Baqarah: 153)",
    "Speak good or remain silent. (Bukhari)",
    // Add more...
  ];

  String getQuote(int day) {
    // Return a quote based on the day of Ramadhan (1-30)
    // Use modulo to cycle if day > list length
    int index = (day - 1) % _quotes.length;
    if (index < 0) index = 0;
    return _quotes[index];
  }
}

final quoteServiceProvider = Provider<QuoteService>((ref) => QuoteService());
