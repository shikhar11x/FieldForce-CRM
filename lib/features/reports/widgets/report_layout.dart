/// Column counts based on the available content width.
int reportSixColumns(double width) =>
    width >= 840 ? 6 : (width >= 520 ? 3 : 2);

int reportFourColumns(double width) => width >= 640 ? 4 : 2;

int reportChartColumns(double width) => width >= 640 ? 2 : 1;