abstract class SearchConstants {
  static const int itemsPerPage = 20;
  static const double searchFieldHeight = 65;
  static const double searchFieldFloatingThreshold = -5;
  static const Duration appearanceAnimationDuration = Duration(milliseconds: 300);
}

enum SearchListScrollState {
  start,
  update,
  end,
}