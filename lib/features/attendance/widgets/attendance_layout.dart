/// Column count for the 6-card summary grids.
int attendanceStatColumns(double width) =>
    width >= 900 ? 6 : (width >= 520 ? 3 : 2);