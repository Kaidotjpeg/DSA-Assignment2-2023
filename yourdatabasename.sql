-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 25, 2023 at 10:59 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.0.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `yourdatabasename`
--

-- --------------------------------------------------------

--
-- Table structure for table `departmentobjectives`
--

CREATE TABLE `departmentobjectives` (
  `departmentObjectiveID` int(11) NOT NULL,
  `departmentName` varchar(255) NOT NULL,
  `objectiveDescription` text DEFAULT NULL,
  `departmentGoalPercentage` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `employeekpiscores`
--

CREATE TABLE `employeekpiscores` (
  `employeeID` int(11) NOT NULL,
  `kpiID` int(11) NOT NULL,
  `score` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `employees`
--

CREATE TABLE `employees` (
  `employeeID` int(11) NOT NULL,
  `firstName` varchar(50) NOT NULL,
  `lastName` varchar(50) NOT NULL,
  `jobTitle` varchar(100) DEFAULT NULL,
  `position` varchar(100) DEFAULT NULL,
  `role` varchar(50) DEFAULT NULL,
  `departmentID` int(11) DEFAULT NULL,
  `supervisorID` int(11) DEFAULT NULL,
  `departmentObjectiveID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `keyperformanceindicators`
--

CREATE TABLE `keyperformanceindicators` (
  `kpiID` int(11) NOT NULL,
  `description` varchar(255) NOT NULL,
  `unit` varchar(50) DEFAULT NULL,
  `departmentObjectiveID` int(11) DEFAULT NULL,
  `departmentID` int(11) DEFAULT NULL,
  `weight` float DEFAULT NULL,
  `maxScore` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `departmentobjectives`
--
ALTER TABLE `departmentobjectives`
  ADD PRIMARY KEY (`departmentObjectiveID`);

--
-- Indexes for table `employeekpiscores`
--
ALTER TABLE `employeekpiscores`
  ADD PRIMARY KEY (`employeeID`,`kpiID`),
  ADD KEY `kpiID` (`kpiID`);

--
-- Indexes for table `employees`
--
ALTER TABLE `employees`
  ADD PRIMARY KEY (`employeeID`),
  ADD KEY `departmentID` (`departmentID`),
  ADD KEY `supervisorID` (`supervisorID`),
  ADD KEY `departmentObjectiveID` (`departmentObjectiveID`);

--
-- Indexes for table `keyperformanceindicators`
--
ALTER TABLE `keyperformanceindicators`
  ADD PRIMARY KEY (`kpiID`),
  ADD KEY `departmentObjectiveID` (`departmentObjectiveID`),
  ADD KEY `departmentID` (`departmentID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `departmentobjectives`
--
ALTER TABLE `departmentobjectives`
  MODIFY `departmentObjectiveID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `employees`
--
ALTER TABLE `employees`
  MODIFY `employeeID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `keyperformanceindicators`
--
ALTER TABLE `keyperformanceindicators`
  MODIFY `kpiID` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `employeekpiscores`
--
ALTER TABLE `employeekpiscores`
  ADD CONSTRAINT `employeekpiscores_ibfk_1` FOREIGN KEY (`employeeID`) REFERENCES `employees` (`employeeID`),
  ADD CONSTRAINT `employeekpiscores_ibfk_2` FOREIGN KEY (`kpiID`) REFERENCES `keyperformanceindicators` (`kpiID`);

--
-- Constraints for table `employees`
--
ALTER TABLE `employees`
  ADD CONSTRAINT `employees_ibfk_1` FOREIGN KEY (`departmentID`) REFERENCES `departments` (`departmentID`),
  ADD CONSTRAINT `employees_ibfk_2` FOREIGN KEY (`supervisorID`) REFERENCES `employees` (`employeeID`),
  ADD CONSTRAINT `employees_ibfk_3` FOREIGN KEY (`departmentObjectiveID`) REFERENCES `departmentobjectives` (`departmentObjectiveID`);

--
-- Constraints for table `keyperformanceindicators`
--
ALTER TABLE `keyperformanceindicators`
  ADD CONSTRAINT `keyperformanceindicators_ibfk_1` FOREIGN KEY (`departmentObjectiveID`) REFERENCES `departmentobjectives` (`departmentObjectiveID`),
  ADD CONSTRAINT `keyperformanceindicators_ibfk_2` FOREIGN KEY (`departmentID`) REFERENCES `departments` (`departmentID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
