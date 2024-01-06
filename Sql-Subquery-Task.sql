-- Database yaradilmasi
USE master
CREATE DATABASE AcademyDB
--DROP DATABASE AcademyDB

-- #############################

-- Curators table yaradilmasi
CREATE TABLE Curators (
    Id int PRIMARY KEY IDENTITY(1,1) NOT NULL,
    [Name] nvarchar(MAX) NOT NULL,
    Surname nvarchar(MAX) NOT NULL
);

INSERT INTO Curators ([Name], Surname) VALUES ('John', 'Doe'), ('Jane', 'Smith'), ('Michael', 'Johnson');

-- #############################

-- Faculties table yaradilmasi
CREATE TABLE Faculties (
    Id int PRIMARY KEY IDENTITY(1,1) NOT NULL,
    [Name] nvarchar(100) NOT NULL UNIQUE
);

INSERT INTO Faculties ([Name]) VALUES ('Engineering'), ('Science'), ('Arts');

-- #############################

-- Departments table yaradilmasi
CREATE TABLE Departments (
    Id int PRIMARY KEY IDENTITY(1,1) NOT NULL,
    Building int NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Financing money NOT NULL DEFAULT 0,
    [Name] nvarchar(100) NOT NULL UNIQUE,
    FacultyId int NOT NULL,
    FOREIGN KEY (FacultyId) REFERENCES Faculties(Id)
);

INSERT INTO Departments (Building, Financing, [Name], FacultyId) VALUES 
(1, 50000, 'Computer Science', 1), 
(2, 75000, 'Mechanical Engineering', 1),
(3, 60000, 'Physics', 2),
(4, 90000, 'Biology', 2),
(5, 80000, 'Literature', 3);

-- #############################

-- Groups table yaradilmasi
CREATE TABLE Groups (
    Id int PRIMARY KEY IDENTITY(1,1) NOT NULL,
    [Name] nvarchar(10) NOT NULL UNIQUE,
    [Year] int NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId int NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

INSERT INTO Groups ([Name], [Year], DepartmentId) VALUES 
('CS101', 1, 1),
('ME201', 2, 2),
('PHY301', 3, 3),
('BIO401', 4, 4),
('LIT501', 5, 5);

-- #############################

-- GroupsCurators table
CREATE TABLE GroupsCurators (
    Id int PRIMARY KEY IDENTITY(1,1) NOT NULL,
    CuratorId int NOT NULL,
    GroupId int NOT NULL,
    FOREIGN KEY (CuratorId) REFERENCES Curators(Id),
    FOREIGN KEY (GroupId) REFERENCES Groups(Id)
);

INSERT INTO GroupsCurators (CuratorId, GroupId) VALUES 
(1, 1),
(2, 2),
(3, 3),
(1, 4),
(2, 5);

-- #############################

-- Teachers table
CREATE TABLE Teachers (
    Id int PRIMARY KEY IDENTITY(1,1) NOT NULL,
    IsProfessor bit NOT NULL DEFAULT 0,
    [Name] nvarchar(MAX) NOT NULL,
    Salary money NOT NULL CHECK (Salary > 0),
    Surname nvarchar(MAX) NOT NULL
);

INSERT INTO Teachers (IsProfessor, [Name], Salary, Surname) VALUES 
(1, 'Professor', 80000, 'Anderson'),
(0, 'Dr. Wilson', 60000, 'Taylor'),
(1, 'Professor', 85000, 'Clarkson'),
(0, 'Dr. Roberts', 65000, 'Wright');

-- #############################

-- Subjects table
CREATE TABLE Subjects (
    Id int PRIMARY KEY IDENTITY(1,1) NOT NULL,
    [Name] nvarchar(100) NOT NULL UNIQUE
);

INSERT INTO Subjects ([Name]) VALUES 
('Algorithms'),
('Thermodynamics'),
('Quantum Physics'),
('Genetics'),
('Poetry');

-- #############################

-- Lectures table
CREATE TABLE Lectures (
    Id int PRIMARY KEY IDENTITY(1,1) NOT NULL,
    LectureDate date NOT NULL CHECK (LectureDate <= GETDATE()),
    SubjectId int NOT NULL,
    TeacherId int NOT NULL,
    FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

INSERT INTO Lectures (LectureDate, SubjectId, TeacherId) VALUES 
('2023-09-15', 1, 1),
('2023-09-20', 2, 2),
('2023-09-25', 3, 3),
('2023-09-30', 4, 4),
('2023-10-05', 5, 1);

-- #############################

-- GroupsLectures table
CREATE TABLE GroupsLectures (
    Id int PRIMARY KEY IDENTITY(1,1) NOT NULL,
    GroupId int NOT NULL,
    LectureId int NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);

INSERT INTO GroupsLectures (GroupId, LectureId) VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- ############################

-- Students table
CREATE TABLE Students (
    Id int PRIMARY KEY IDENTITY(1,1) NOT NULL,
    [Name] nvarchar(MAX) NOT NULL,
    Rating int NOT NULL CHECK (Rating BETWEEN 0 AND 5),
    Surname nvarchar(MAX) NOT NULL
);

INSERT INTO Students ([Name], Rating, Surname) VALUES 
('Alice', 4, 'Johnson'),
('Bob', 5, 'Williams'),
('Charlie', 3, 'Brown'),
('Daisy', 4, 'Davis'),
('Ethan', 5, 'Miller');

-- ############################

-- GroupsStudents table
CREATE TABLE GroupsStudents (
    Id int PRIMARY KEY IDENTITY(1,1) NOT NULL,
    GroupId int NOT NULL,
    StudentId int NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (StudentId) REFERENCES Students(Id)
);

INSERT INTO GroupsStudents (GroupId, StudentId) VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- =========================================================================


-- ~ ~ ~ ~ ~ ~ ~ ~ ~ Queries ~ ~ ~ ~ ~ ~ ~ ~ ~ ~


-- Task 1. Print numbers of buildings if the total 
-- financing fund of the departments located in them exceeds 100,000.

SELECT Building, SUM(Financing) AS TotalFinancing
FROM Departments
GROUP BY Building
HAVING SUM(Financing) > 10000;

-- ======================================================================

-- Task 2. Print names of the 5th year groups of the 
-- Software Development department that have more than 10 double periods in the first week.

SELECT Groups.[Name]
FROM Groups
JOIN Departments ON Groups.DepartmentId = Departments.Id
WHERE Departments.[Name] = 'Computer Science' AND Groups.[Year] = 5
AND Groups.Id IN (
    SELECT GroupsLectures.GroupId
    FROM GroupsLectures
    JOIN Lectures ON GroupsLectures.LectureId = Lectures.Id
    WHERE Lectures.LectureDate BETWEEN '2023-01-01' AND '2023-01-07'
    GROUP BY GroupsLectures.GroupId
    HAVING COUNT(DISTINCT Lectures.LectureDate) > 10
);

-- =======================================================================

-- Task 3. Print names of the groups whose rating (average rating of all
-- students in the group) is greater than the rating of the "D221" group.

SELECT Groups.[Name]
FROM Groups
JOIN GroupsStudents ON Groups.Id = GroupsStudents.GroupId
JOIN Students ON GroupsStudents.StudentId = Students.Id
WHERE AVG(Students.Rating) > (
    SELECT AVG(Students.Rating)
    FROM Groups AS Group1
    JOIN GroupsStudents ON Group1.Id = GroupsStudents.GroupId
    JOIN Students ON GroupsStudents.StudentId = Students.Id
    WHERE Group1.[Name] = 'D221'
);

-- ======================================================================

--Task 5. Print names of groups with more than one curator

SELECT Groups.[Name]
FROM Groups
JOIN GroupsCurators ON Groups.Id = GroupsCurators.GroupId
GROUP BY Groups.[Name]
HAVING COUNT(GroupsCurators.CuratorId) > 1;

-- ======================================================================

-- Task 7. Print names of the faculties with total financing 
-- fund of the departments greater than the total financing fund of the Computer Science department.

SELECT Faculties.[Name]
FROM Faculties
JOIN Departments ON Faculties.Id = Departments.FacultyId
GROUP BY Faculties.[Name]
HAVING SUM(Departments.Financing) > (
    SELECT SUM(Financing)
    FROM Departments
    WHERE Name = 'Computer Science'
);

-- =================================================================

-- Task 9. Print name of the subject in which the least number of lectures
-- are delivered.


SELECT Subjects.[Name] AS SubjectName
FROM Subjects
LEFT JOIN Lectures ON Subjects.Id = Lectures.SubjectId
GROUP BY Subjects.[Name]

