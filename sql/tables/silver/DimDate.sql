-- ============================================
-- Silver Layer: Dim Date (Calendar Dimension)
-- ============================================

IF OBJECT_ID('Silver.DimDate', 'U') IS NOT NULL
    DROP TABLE Silver.DimDate;
GO

CREATE TABLE Silver.DimDate (
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL,
    DayOfWeek INT,
    DayName NVARCHAR(20),
    DayOfMonth INT,
    DayOfYear INT,
    WeekOfYear INT,
    MonthNumber INT,
    MonthName NVARCHAR(20),
    Quarter INT,
    QuarterName NVARCHAR(10),
    Year INT,
    YearMonth NVARCHAR(7),
    YearQuarter NVARCHAR(7),
    IsWeekend BIT,
    IsHoliday BIT DEFAULT 0,
    HolidayName NVARCHAR(100),
    FiscalYear INT,
    FiscalQuarter INT,
    FiscalMonth INT
);
GO

CREATE INDEX IX_DimDate_FullDate ON Silver.DimDate(FullDate);
CREATE INDEX IX_DimDate_YearMonth ON Silver.DimDate(YearMonth);
GO
