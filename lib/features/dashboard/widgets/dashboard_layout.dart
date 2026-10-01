/// Column counts based on the available *content* width (after padding).
abstract final class DashboardLayout {
  static int kpiColumns(double width) =>
      width >= 900 ? 6 : (width >= 520 ? 3 : 2);

  static int chartColumns(double width) => width >= 640 ? 2 : 1;

  static int actionColumns(double width) => width >= 520 ? 4 : 2;

  static int overviewColumns(double width) => width >= 640 ? 4 : 2;

  static int teamColumns(double width) =>
      width >= 900 ? 3 : (width >= 600 ? 2 : 1);
}