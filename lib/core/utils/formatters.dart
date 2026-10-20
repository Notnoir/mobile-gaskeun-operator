class Formatters {
  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des'
  ];

  static const List<String> _fullMonths = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  static String points(int points) {
    final formatted = points
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '$formatted pts';
  }

  static String weight(double kg) {
    final str = kg.truncateToDouble() == kg
        ? kg.toInt().toString()
        : kg.toStringAsFixed(1).replaceAll('.', ',');
    return '$str kg';
  }

  static String number(num value) {
    if (value is int || value.truncateToDouble() == value) {
      return value
          .toInt()
          .toString()
          .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    }
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }

  static String dateTime(DateTime dt) {
    final day = dt.day;
    final month = _months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  static String date(DateTime dt) {
    final day = dt.day;
    final month = _fullMonths[dt.month - 1];
    final year = dt.year;
    return '$day $month $year';
  }

  static String time(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String monthYear(DateTime dt) {
    return '${_fullMonths[dt.month - 1]} ${dt.year}';
  }
}
