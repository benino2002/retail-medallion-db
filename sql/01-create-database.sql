-- ============================================
-- Retail Medallion Database - Create Database
-- ============================================

USE master;
GO

-- Create database if it doesn't exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'RetailMedallion')
BEGIN
    CREATE DATABASE [RetailMedallion]
    PRINT 'Database RetailMedallion created successfully'
END
ELSE
BEGIN
    PRINT 'Database RetailMedallion already exists'
END
GO

USE [RetailMedallion];
GO
