



-- අලුත් ඩේටාබේස් එක ඇතුළට මාරු වෙයි
USE SmartEduDB;
GO

-- =====================================================
-- 1. BASE ENTITY SCHEMA: USER IDENTITY & SECURITY
-- =====================================================
CREATE TABLE [User] (
    UserID VARCHAR(15) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    PasswordHash CHAR(64) NOT NULL,
    PhoneNumber VARCHAR(15) NOT NULL,
    AccountStatus VARCHAR(15) NOT NULL,
    ProfilePictureURI VARCHAR(255) NULL,
    CONSTRAINT PK_User PRIMARY KEY (UserID),
    CONSTRAINT UQ_User_Email UNIQUE (Email),
    CONSTRAINT CK_User_UserID CHECK (UserID LIKE '[A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
    CONSTRAINT CK_User_Email CHECK (Email LIKE '%_@_%_%'),
    CONSTRAINT CK_User_Status CHECK (AccountStatus IN ('Pending', 'Active', 'Suspended'))
);
GO

-- =====================================================
-- 2. INDEPENDENT ENTITY: CLASS COHORT STRUCTURAL TRACK
-- =====================================================
CREATE TABLE Class (
    ClassID CHAR(8) NOT NULL,
    ClassName VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Class PRIMARY KEY (ClassID),
    CONSTRAINT CK_Class_Name CHECK (ClassName <> '')
);
GO

-- =====================================================
-- 3. INDEPENDENT ENTITY: COURSE CURRICULUM CATALOG
-- =====================================================
CREATE TABLE Course (
    CourseID CHAR(8) NOT NULL,
    CourseName VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Course PRIMARY KEY (CourseID),
    CONSTRAINT UQ_Course_Name UNIQUE (CourseName)
);
GO

-- =====================================================
-- 4. SUBTYPE INHERITED ENTITY: STUDENT PROFILE
-- =====================================================
CREATE TABLE Student (
    StudentID VARCHAR(15) NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    DateOfBirth DATE NOT NULL,
    HomeAddress VARCHAR(255) NOT NULL,
    BirthCertificatePath VARCHAR(255) NOT NULL,
    PreviousRecordPath VARCHAR(255) NULL,
    ClassID CHAR(8) NULL,
    CONSTRAINT PK_Student PRIMARY KEY (StudentID),
    CONSTRAINT FK_Student_User FOREIGN KEY (StudentID)
        REFERENCES [User](UserID) ON UPDATE CASCADE ON DELETE NO ACTION,
    CONSTRAINT FK_Student_Class FOREIGN KEY (ClassID)
        REFERENCES Class(ClassID) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT CK_Student_DOB CHECK (DateOfBirth <= GETDATE())
);
GO

-- =====================================================
-- 5. SUBTYPE INHERITED ENTITY: PARENT / GUARDIAN REGISTRY
-- =====================================================
CREATE TABLE Parent (
    ParentID VARCHAR(15) NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    NIC_Number VARCHAR(12) NOT NULL,
    NIC_CopyPath VARCHAR(255) NOT NULL,
    CONSTRAINT PK_Parent PRIMARY KEY (ParentID),
    CONSTRAINT FK_Parent_User FOREIGN KEY (ParentID)
        REFERENCES [User](UserID) ON UPDATE CASCADE ON DELETE NO ACTION,
    CONSTRAINT UQ_Parent_NIC UNIQUE (NIC_Number)
);
GO

-- =====================================================
-- 6. SUBTYPE INHERITED ENTITY: TEACHER PROFILE
-- =====================================================
CREATE TABLE Teacher (
    TeacherID VARCHAR(15) NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    Specialization VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Teacher PRIMARY KEY (TeacherID),
    CONSTRAINT FK_Teacher_User FOREIGN KEY (TeacherID)
        REFERENCES [User](UserID) ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

-- =====================================================
-- 7. MANY-TO-MANY ASSOCIATION BRIDGE: PARENT-STUDENT LINKAGE
-- =====================================================
CREATE TABLE ParentStudentAssociation (
    ParentID VARCHAR(15) NOT NULL,
    StudentID VARCHAR(15) NOT NULL,
    Relationship VARCHAR(20) NOT NULL,
    CONSTRAINT PK_ParentStudentAssociation PRIMARY KEY (ParentID, StudentID),
    CONSTRAINT FK_PSA_Parent FOREIGN KEY (ParentID)
        REFERENCES Parent(ParentID) ON UPDATE CASCADE ON DELETE NO ACTION,
    CONSTRAINT FK_PSA_Student FOREIGN KEY (StudentID)
        REFERENCES Student(StudentID) ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT CK_PSA_Relationship CHECK (Relationship IN ('Mother', 'Father', 'Guardian'))
);
GO

-- =====================================================
-- 8. WEAK TRANSACTIONAL ENTITY: SPATIOTEMPORAL SCHEDULE ENGINE
-- =====================================================
CREATE TABLE ScheduleItem (
    ScheduleID INT IDENTITY(1,1) NOT NULL,
    DayOfWeek VARCHAR(10) NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    RoomIdentifier VARCHAR(30) NOT NULL,
    ClassID CHAR(8) NOT NULL,
    TeacherID VARCHAR(15) NOT NULL,
    CourseID CHAR(8) NOT NULL,
    CONSTRAINT PK_ScheduleItem PRIMARY KEY (ScheduleID),
    CONSTRAINT FK_Schedule_Class FOREIGN KEY (ClassID)
        REFERENCES Class(ClassID) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_Schedule_Teacher FOREIGN KEY (TeacherID)
        REFERENCES Teacher(TeacherID) ON UPDATE CASCADE ON DELETE NO ACTION,
    CONSTRAINT FK_Schedule_Course FOREIGN KEY (CourseID)
        REFERENCES Course(CourseID) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT CK_Schedule_Times CHECK (EndTime > StartTime),
    CONSTRAINT CK_Schedule_Day CHECK (DayOfWeek IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
    CONSTRAINT UQ_Schedule_Collision UNIQUE (RoomIdentifier, DayOfWeek, StartTime)
);
GO

-- =====================================================
-- 9. WEAK ASSOCIATIVE ENTITY: ACADEMIC PERFORMANCE LEDGER
-- =====================================================
CREATE TABLE GradeBookRecord (
    RecordID INT IDENTITY(1,1) NOT NULL,
    RawMarks DECIMAL(5,2) NOT NULL,
    GradeLetter VARCHAR(3) NOT NULL,
    AcademicTerm VARCHAR(10) NOT NULL,
    AcademicYear INT NOT NULL,
    StudentID VARCHAR(15) NOT NULL,
    CourseID CHAR(8) NOT NULL,
    CONSTRAINT PK_GradeBookRecord PRIMARY KEY (RecordID),
    CONSTRAINT FK_GradeBook_Student FOREIGN KEY (StudentID)
        REFERENCES Student(StudentID) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_GradeBook_Course FOREIGN KEY (CourseID)
        REFERENCES Course(CourseID) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT CK_GradeBook_Marks CHECK (RawMarks >= 0.00 AND RawMarks <= 100.00),
    CONSTRAINT CK_GradeBook_Year CHECK (AcademicYear >= 2026),
    CONSTRAINT CK_GradeBook_Letter CHECK (GradeLetter IN ('A+', 'A', 'B+', 'B', 'C+', 'C', 'S', 'F'))
);
GO

-- =====================================================
-- 10. COMMUNICATION SYSTEM ENTITY: CAMPUS NOTICE BOARD
-- =====================================================
CREATE TABLE Notice (
    NoticeID INT IDENTITY(1,1) NOT NULL,
    Subject VARCHAR(100) NOT NULL,
    NoticeBody TEXT NOT NULL,
    Audience VARCHAR(20) NOT NULL,
    AttachmentPath VARCHAR(255) NULL,
    IsUrgent BIT NOT NULL CONSTRAINT DF_Notice_Urgent DEFAULT 0,
    CreatedAt DATETIME NOT NULL CONSTRAINT DF_Notice_Time DEFAULT GETDATE(),
    CreatorAdminID VARCHAR(15) NOT NULL,
    CONSTRAINT PK_Notice PRIMARY KEY (NoticeID),
    CONSTRAINT FK_Notice_User FOREIGN KEY (CreatorAdminID)
        REFERENCES [User](UserID) ON UPDATE CASCADE ON DELETE NO ACTION,
    CONSTRAINT CK_Notice_Subject CHECK (Subject <> ''),
    CONSTRAINT CK_Notice_Audience CHECK (Audience IN ('Students', 'Parents', 'Teachers', 'All'))
);
GO

-- =====================================================
-- 11. TRIGGERS
-- =====================================================

CREATE TRIGGER trg_OnboardStudentSecurityProfile
ON Student
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO [User] (UserID, Email, PasswordHash, PhoneNumber, AccountStatus, ProfilePictureURI)
        SELECT i.StudentID, LOWER(REPLACE(i.FullName, ' ', '')) + '@smartedu.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', '+94771234567', 'Active', '/assets/img/profiles/default.png'
        FROM inserted i
        WHERE NOT EXISTS (SELECT 1 FROM [User] u WHERE u.UserID = i.StudentID);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW 50001, 'Critical Error: Student identity synchronization failed.', 1;
    END CATCH
END;
GO

CREATE TRIGGER trg_PreventTeacherScheduleCollision
ON ScheduleItem
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM inserted i
        INNER JOIN ScheduleItem s ON i.TeacherID = s.TeacherID AND i.DayOfWeek = s.DayOfWeek AND i.ScheduleID <> s.ScheduleID
        WHERE (i.StartTime < s.EndTime AND i.EndTime > s.StartTime)
    )
    BEGIN
        RAISERROR('Scheduling Collision Error: This teacher is already booked for another class during this time frame.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- =====================================================
-- 12. FUNCTIONS
-- =====================================================

CREATE FUNCTION fn_CalculateStudentTermAverage(@StudentID VARCHAR(15), @AcademicTerm VARCHAR(10), @AcademicYear INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @AverageMarks DECIMAL(5,2);
    SELECT @AverageMarks = AVG(RawMarks) FROM GradeBookRecord WHERE StudentID = @StudentID AND AcademicTerm = @AcademicTerm AND AcademicYear = @AcademicYear;
    RETURN ISNULL(@AverageMarks, 0.00);
END;
GO

CREATE FUNCTION fn_GetClassRosterReport(@TargetClassID CHAR(8))
RETURNS TABLE
AS
RETURN (
    SELECT s.StudentID, s.FullName AS StudentName, c.ClassName, u.Email AS StudentEmail, u.AccountStatus, p.FullName AS PrimaryGuardianName, pu.PhoneNumber AS GuardianContact
    FROM Student s
    INNER JOIN [User] u ON s.StudentID = u.UserID
    INNER JOIN Class c ON s.ClassID = c.ClassID
    LEFT JOIN ParentStudentAssociation psa ON s.StudentID = psa.StudentID AND psa.Relationship IN ('Mother', 'Father', 'Guardian')
    LEFT JOIN Parent p ON psa.ParentID = p.ParentID
    LEFT JOIN [User] pu ON p.ParentID = pu.UserID
    WHERE s.ClassID = @TargetClassID
);
GO

-- =====================================================
-- 13. VIEWS
-- =====================================================

CREATE VIEW vw_StudentAcademicPerformanceSummary AS
SELECT s.StudentID, s.FullName AS StudentName, c.ClassID, c.ClassName, g.AcademicTerm, g.AcademicYear, co.CourseID, co.CourseName, g.RawMarks, g.GradeLetter,
    AVG(g.RawMarks) OVER(PARTITION BY s.StudentID, g.AcademicTerm, g.AcademicYear) AS DynamicTerminalAverage,
    DENSE_RANK() OVER(PARTITION BY s.ClassID, g.CourseID, g.AcademicTerm, g.AcademicYear ORDER BY g.RawMarks DESC) AS InClassSubjectRank
FROM Student s
INNER JOIN Class c ON s.ClassID = c.ClassID
INNER JOIN GradeBookRecord g ON s.StudentID = g.StudentID
INNER JOIN Course co ON g.CourseID = co.CourseID;
GO

CREATE VIEW vw_ActiveLiveClassScheduler AS
SELECT s.ScheduleID, s.DayOfWeek, s.StartTime, s.EndTime, s.RoomIdentifier, c.ClassID, c.ClassName, t.TeacherID, t.FullName AS InstructorName, co.CourseID, co.CourseName,
    CASE WHEN CONVERT(TIME, GETDATE()) BETWEEN s.StartTime AND s.EndTime AND DATENAME(WEEKDAY, GETDATE()) = s.DayOfWeek THEN 'LIVE' ELSE 'UPCOMING' END AS CurrentLiveStatus
FROM ScheduleItem s
INNER JOIN Class c ON s.ClassID = c.ClassID
INNER JOIN Teacher t ON s.TeacherID = t.TeacherID
INNER JOIN Course co ON s.CourseID = co.CourseID;
GO

-- =====================================================
-- 14. STORED PROCEDURES
-- =====================================================

CREATE PROCEDURE sp_GetStudentDashboardPayload @TargetStudentID VARCHAR(15), @CurrentTerm VARCHAR(10), @CurrentYear INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = @TargetStudentID)
        BEGIN
            RAISERROR('Referential Integrity Error: Target student identifier code not found.', 16, 1);
            RETURN;
        END
        SELECT s.StudentID, s.FullName AS StudentName, c.ClassName, u.Email, u.ProfilePictureURI, dbo.fn_CalculateStudentTermAverage(s.StudentID, @CurrentTerm, @CurrentYear) AS CalculatedTermAverage,
            (SELECT COUNT(*) FROM Notice WHERE IsUrgent = 1 AND CreatedAt >= DATEADD(DAY, -7, GETDATE())) AS ActiveUrgentAlertsCount
        FROM Student s
        INNER JOIN [User] u ON s.StudentID = u.UserID
        INNER JOIN Class c ON s.ClassID = c.ClassID
        WHERE s.StudentID = @TargetStudentID;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

CREATE PROCEDURE sp_ExecuteAdministrativeOnboarding @NewUserID VARCHAR(15), @Email VARCHAR(100), @PasswordHash CHAR(64), @PhoneNumber VARCHAR(15), @FullName VARCHAR(100), @DateOfBirth DATE, @HomeAddress VARCHAR(255), @BirthCertificatePath VARCHAR(255), @ClassID CHAR(8)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO [User] (UserID, Email, PasswordHash, PhoneNumber, AccountStatus) VALUES (@NewUserID, @Email, @PasswordHash, @PhoneNumber, 'Active');
        INSERT INTO Student (StudentID, FullName, DateOfBirth, HomeAddress, BirthCertificatePath, ClassID) VALUES (@NewUserID, @FullName, @DateOfBirth, @HomeAddress, @BirthCertificatePath, @ClassID);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- =====================================================
-- 15. SAMPLE DATA INSERTION
-- =====================================================

-- Insert User Records
INSERT INTO [User] (UserID, Email, PasswordHash, PhoneNumber, AccountStatus, ProfilePictureURI) VALUES
('STU-2026-0001', 'student@smartedu.com', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', '+94771234567', 'Active', NULL),
('STU-2026-0002', 'nethmi.p@smartedu.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', '+94772223334', 'Active', NULL),
('STU-2026-0003', 'kavindu.s@smartedu.com', '4813494d137e1631bba301d5acab6e7bb7aa74ce1185d456565ef51d737677b2', '+94773334445', 'Active', NULL),
('STU-2026-0004', 'sashini.f@smartedu.com', '5a8dd3ad0756a93ded72b823b19dd87793d2e60087a5364711142502845c47f5', '+94774445556', 'Active', NULL),
('STU-2026-0005', 'dimuthu.p@smartedu.com', 'd3b07384d113edec49eaa6238ad5ff00', '+94775556667', 'Active', NULL),
('STU-2026-0006', 'bawantha.s@smartedu.com', 'c1572d05424d2d6e1d6c5f6b8c9d3e2a', '+94776667778', 'Active', NULL),
('STU-2026-0007', 'sanduni.f@smartedu.com', 'f5a7924e621b84c9b0a9a2d6e5f7g8h9', '+94777778889', 'Active', NULL),
('STU-2026-0008', 'minura.j@smartedu.com', '9k8j7h6g5f4d3s2a1q2w3e4r5t6y7u8i', '+94778889990', 'Active', NULL),
('STU-2026-0009', 'thilina.w@smartedu.com', '1q2w3e4r5t6y7u8i9o0p1q2w3e4r5t6y', '+94779990001', 'Active', NULL),
('STU-2026-0010', 'anuki.a@smartedu.com', 'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6', '+94770001112', 'Active', NULL),
('PAR-2026-0001', 'parent@smartedu.com', 'fcde2b2edba56bf408601fb721fe9b5c338d10ee429ea04fae5511b68fbf8fb9', '+94771234567', 'Active', NULL),
('PAR-2026-0002', 'kasun.silva@gmail.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', '+94775556667', 'Active', NULL),
('PAR-2026-0003', 'anoma.f@gmail.com', '6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b', '+94776667778', 'Active', NULL),
('PAR-2026-0004', 'ruwan.p@gmail.com', '0d5843c0879612c324bf833a6b8c8d8b139db08c3cf0d9e7943d7c5a0890bf8e', '+94777778889', 'Active', NULL),
('PAR-2026-0005', 'kamal.w@gmail.com', 'e7f6c5d4b3a2q1w2e3r4t5y6u7i8o9p0', '+94778889990', 'Active', NULL),
('PAR-2026-0006', 'sunil.j@gmail.com', 'q1w2e3r4t5y6u7i8o9p0a1s2d3f4g5h6', '+94779990001', 'Active', NULL),
('PAR-2026-0007', 'nirmala.a@gmail.com', 'z1x2c3v4b5n6m7a8s9d0f1g2h3j4k5l', '+94770001112', 'Active', NULL),
('PAR-2026-0008', 'priyantha.d@gmail.com', 'p1o2i3u4y5t6r7e8w9q0a1s2d3f4g5h6', '+94771112223', 'Active', NULL),
('PAR-2026-0009', 'deepika.g@gmail.com', 'l1k2j3h4g5f6d7s8a9q0w1e2r3t4y5u6', '+94772223334', 'Active', NULL),
('PAR-2026-0010', 'asanka.r@gmail.com', 'm1n2b3v4c5x6z7l8k9j0h1g2f3d4s5a', '+94773334445', 'Active', NULL),
('TEA-2026-0001', 'teacher@smartedu.com', 'b3d4f4d2f09d8d6d84a7e8b6b0b2b8d6f8f7e2a4b0b2b4d8d6d8d6f8f8b2b4d8', '+94779876543', 'Active', NULL),
('TEA-2026-0002', 'dilki.p@smartedu.com', '2c624232cdd2217712d44a94e1e9d37bb0ef23f8221c97a5f36e47f9f257b54a', '+94778889990', 'Active', NULL),
('TEA-2026-0003', 'rukshan.f@smartedu.com', '19e66e52cdd2217712d44a94e1e9d37bb0ef23f8221c97a5f36e47f9f257b54a', '+94779990001', 'Active', NULL),
('TEA-2026-0004', 'anoma.j@smartedu.com', 'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7', '+94770001112', 'Active', NULL),
('TEA-2026-0005', 'kusal.m@smartedu.com', 'q1w2e3r4t5y6u7i8o9p0a1s2d3f4g5h6j7', '+94771112223', 'Active', NULL),
('TEA-2026-0006', 'chathuri.a@smartedu.com', 'z1x2c3v4b5n6m7a8s9d0f1g2h3j4k5l6q', '+94772223334', 'Active', NULL),
('TEA-2026-0007', 'upul.t@smartedu.com', 'p1o2i3u4y5t6r7e8w9q0a1s2d3f4g5h6j7k', '+94773334445', 'Active', NULL),
('TEA-2026-0008', 'lasanthi.p@smartedu.com', 'l1k2j3h4g5f6d7s8a9q0w1e2r3t4y5u6i7o', '+94774445556', 'Active', NULL),
('TEA-2026-0009', 'ranjith.p@smartedu.com', 'm1n2b3v4c5x6z7l8k9j0h1g2f3d4s5a6q7w', '+94775556667', 'Active', NULL),
('TEA-2026-0010', 'v.saroja@smartedu.com', 'a1s2d3f4g5h6j7k8l9q0w1e2r3t4y5u6i7o8p', '+94776667778', 'Active', NULL);

-- Insert Class Records
INSERT INTO Class (ClassID, ClassName) VALUES
('CLS-11A', 'Grade 11-A'),
('CLS-11B', 'Grade 11-B'),
('CLS-11C', 'Grade 11-C'),
('CLS-12A', 'Grade 12-A'),
('CLS-12B', 'Grade 12-B'),
('CLS-10A', 'Grade 10-A'),
('CLS-10B', 'Grade 10-B'),
('CLS-09A', 'Grade 09-A'),
('CLS-09B', 'Grade 09-B'),
('CLS-08A', 'Grade 08-A');

-- Insert Course Records
INSERT INTO Course (CourseID, CourseName) VALUES
('SUB-ICT', 'Information & Communication Technology'),
('SUB-MATH', 'Mathematics'),
('SUB-SCI', 'Science'),
('SUB-ENG', 'English'),
('SUB-HIST', 'History'),
('SUB-COMM', 'Commerce'),
('SUB-GEOG', 'Geography'),
('SUB-ART', 'Art & Design'),
('SUB-MUS', 'Music'),
('SUB-TAM', 'Tamil Language');

-- Insert Student Records
INSERT INTO Student (StudentID, FullName, DateOfBirth, HomeAddress, BirthCertificatePath, PreviousRecordPath, ClassID) VALUES
('STU-2026-0001', 'Aruja Wirarathna', '2010-05-14', 'No. 45, Galle Road, Colombo 03', '/docs/birth/birth_stu_0001.pdf', NULL, 'CLS-11B'),
('STU-2026-0002', 'Nethmi Perera', '2010-08-22', 'No. 12/A, Kandy Road, Kiribathgoda', '/docs/birth/birth_stu_0002.pdf', NULL, 'CLS-11B'),
('STU-2026-0003', 'Kavindu Silva', '2010-11-02', 'No. 88, Negombo Road, Wattala', '/docs/birth/birth_stu_0003.pdf', NULL, 'CLS-11B'),
('STU-2026-0004', 'Sashini Fernando', '2010-03-19', 'No. 104, High Level Road, Maharagama', '/docs/birth/birth_stu_0004.pdf', NULL, 'CLS-11B'),
('STU-2026-0005', 'Dimuthu Perera', '2009-12-05', 'No. 14, Station Road, Bambalapitiya', '/docs/birth/birth_stu_0005.pdf', NULL, 'CLS-11A'),
('STU-2026-0006', 'Bawantha Silva', '2011-02-14', 'No. 33, Horana Road, Panadura', '/docs/birth/birth_stu_0006.pdf', NULL, 'CLS-11A'),
('STU-2026-0007', 'Sanduni Fernando', '2010-07-25', 'No. 77, Havelock Road, Colombo 05', '/docs/birth/birth_stu_0007.pdf', NULL, 'CLS-11C'),
('STU-2026-0008', 'Minura Jayasuriya', '2010-01-30', 'No. 5, De Fonseka Road, Colombo 04', '/docs/birth/birth_stu_0008.pdf', NULL, 'CLS-11C'),
('STU-2026-0009', 'Thilina Wijesinghe', '2011-06-12', 'No. 19, Awissawella Road, Hanwella', '/docs/birth/birth_stu_0009.pdf', NULL, 'CLS-12A'),
('STU-2026-0010', 'Anuki Alwis', '2012-04-18', 'No. 2, Baseline Road, Borella', '/docs/birth/birth_stu_0010.pdf', NULL, 'CLS-12A');

-- Insert Parent Records
INSERT INTO Parent (ParentID, FullName, NIC_Number, NIC_CopyPath) VALUES
('PAR-2026-0001', 'Sewwandi Perera', '198254710234', '/docs/nic/nic_par_0001.pdf'),
('PAR-2026-0002', 'Kasun Silva', '198012345678', '/docs/nic/nic_par_0002.pdf'),
('PAR-2026-0003', 'Anoma Fernando', '198598765432', '/docs/nic/nic_par_0003.pdf'),
('PAR-2026-0004', 'Ruwan Perera', '197945612398', '/docs/nic/nic_par_0004.pdf'),
('PAR-2026-0005', 'Kamal Wijesinghe', '197578945612', '/docs/nic/nic_par_0005.pdf'),
('PAR-2026-0006', 'Sunil Jayasuriya', '198114725836', '/docs/nic/nic_par_0006.pdf'),
('PAR-2026-0007', 'Nirmala Alwis', '198436925814', '/docs/nic/nic_par_0007.pdf'),
('PAR-2026-0008', 'Priyantha De Silva', '197825814736', '/docs/nic/nic_par_0008.pdf'),
('PAR-2026-0009', 'Deepika Gunaratne', '198314736925', '/docs/nic/nic_par_0009.pdf'),
('PAR-2026-0010', 'Asanka Rajapaksha', '198036914725', '/docs/nic/nic_par_0010.pdf');

-- ❗ මඟහැරී තිබූ ගුරුවරුන්ගේ දත්ත ඇතුළත් කිරීමේ කොටස (මේක තමයි කලින් අඩු වුණේ) ❗
INSERT INTO Teacher (TeacherID, FullName, Specialization) VALUES
('TEA-2026-0001', 'Mr. Nuwan Silva', 'Information & Communication Technology'),
('TEA-2026-0002', 'Mrs. Dilki Perera', 'Mathematics'),
('TEA-2026-0003', 'Mr. Rukshan Fernando', 'Science'),
('TEA-2026-0004', 'Mrs. Anoma Jayasuriya', 'English'),
('TEA-2026-0005', 'Mr. Kusal Mendis', 'History'),
('TEA-2026-0006', 'Mrs. Chathuri Alwis', 'Commerce'),
('TEA-2026-0007', 'Mr. Upul Tharanga', 'Geography'),
('TEA-2026-0008', 'Mrs. Lasanthi Perera', 'Art & Design'),
('TEA-2026-0009', 'Mr. Ranjith Perera', 'Music'),
('TEA-2026-0010', 'Mrs. V. Saroja', 'Tamil Language');

-- Insert ParentStudentAssociation Records
INSERT INTO ParentStudentAssociation (ParentID, StudentID, Relationship) VALUES
('PAR-2026-0001', 'STU-2026-0001', 'Mother'),
('PAR-2026-0001', 'STU-2026-0002', 'Mother'),
('PAR-2026-0002', 'STU-2026-0003', 'Father'),
('PAR-2026-0003', 'STU-2026-0004', 'Mother'),
('PAR-2026-0004', 'STU-2026-0005', 'Father'),
('PAR-2026-0005', 'STU-2026-0009', 'Father'),
('PAR-2026-0006', 'STU-2026-0008', 'Father'),
('PAR-2026-0007', 'STU-2026-0010', 'Mother'),
('PAR-2026-0008', 'STU-2026-0006', 'Guardian');

-- Insert ScheduleItem Records
INSERT INTO ScheduleItem (DayOfWeek, StartTime, EndTime, RoomIdentifier, ClassID, TeacherID, CourseID) VALUES
('Monday', '08:00:00', '09:30:00', 'Computer Lab', 'CLS-11B', 'TEA-2026-0001', 'SUB-ICT'),
('Monday', '10:00:00', '11:30:00', 'Room 203', 'CLS-11B', 'TEA-2026-0002', 'SUB-MATH'),
('Monday', '13:00:00', '14:30:00', 'Room 101', 'CLS-11B', 'TEA-2026-0003', 'SUB-SCI'),
('Tuesday', '08:00:00', '09:30:00', 'Room 102', 'CLS-11B', 'TEA-2026-0004', 'SUB-ENG'),
('Tuesday', '10:00:00', '11:30:00', 'Computer Lab', 'CLS-11A', 'TEA-2026-0001', 'SUB-ICT'),
('Wednesday', '08:00:00', '09:30:00', 'Room 203', 'CLS-11A', 'TEA-2026-0002', 'SUB-MATH'),
('Wednesday', '10:00:00', '11:30:00', 'Room 101', 'CLS-11A', 'TEA-2026-0003', 'SUB-SCI'),
('Thursday', '08:00:00', '09:30:00', 'Room 102', 'CLS-11A', 'TEA-2026-0004', 'SUB-ENG'),
('Thursday', '13:00:00', '14:30:00', 'Room 203', 'CLS-11C', 'TEA-2026-0001', 'SUB-ICT'),
('Friday', '10:00:00', '11:30:00', 'Computer Lab', 'CLS-11C', 'TEA-2026-0002', 'SUB-MATH');

-- Insert GradeBookRecord Records
INSERT INTO GradeBookRecord (RawMarks, GradeLetter, AcademicTerm, AcademicYear, StudentID, CourseID) VALUES
(92.00, 'A+', 'Term 01', 2026, 'STU-2026-0001', 'SUB-MATH'),
(88.00, 'A', 'Term 01', 2026, 'STU-2026-0001', 'SUB-SCI'),
(79.00, 'B+', 'Term 01', 2026, 'STU-2026-0001', 'SUB-ENG'),
(95.00, 'A+', 'Term 01', 2026, 'STU-2026-0001', 'SUB-ICT'),
(85.00, 'A', 'Term 01', 2026, 'STU-2026-0002', 'SUB-MATH'),
(90.00, 'A+', 'Term 01', 2026, 'STU-2026-0002', 'SUB-SCI'),
(72.00, 'B', 'Term 01', 2026, 'STU-2026-0002', 'SUB-ENG'),
(88.00, 'A', 'Term 01', 2026, 'STU-2026-0002', 'SUB-ICT'),
(65.00, 'B', 'Term 01', 2026, 'STU-2026-0003', 'SUB-MATH'),
(70.00, 'B+', 'Term 01', 2026, 'STU-2026-0003', 'SUB-SCI'),
(45.00, 'C', 'Term 01', 2026, 'STU-2026-0003', 'SUB-ENG'),
(55.00, 'C+', 'Term 01', 2026, 'STU-2026-0003', 'SUB-ICT'),
(78.00, 'B+', 'Term 01', 2026, 'STU-2026-0004', 'SUB-MATH'),
(82.00, 'A', 'Term 01', 2026, 'STU-2026-0004', 'SUB-SCI'),
(90.00, 'A+', 'Term 01', 2026, 'STU-2026-0004', 'SUB-ENG'),
(85.00, 'A', 'Term 01', 2026, 'STU-2026-0004', 'SUB-ICT'),
(60.00, 'C+', 'Term 01', 2026, 'STU-2026-0005', 'SUB-MATH'),
(55.00, 'C+', 'Term 01', 2026, 'STU-2026-0005', 'SUB-SCI'),
(70.00, 'B+', 'Term 01', 2026, 'STU-2026-0005', 'SUB-ENG'),
(75.00, 'B+', 'Term 01', 2026, 'STU-2026-0005', 'SUB-ICT');

-- Insert Notice Records
INSERT INTO Notice (Subject, NoticeBody, Audience, AttachmentPath, IsUrgent, CreatedAt, CreatorAdminID) VALUES
('Portal Maintenance Notice', 'Portal maintenance schedules for Sunday, 02.00 A.M - 08.00 A.M. During this period, some services may not be available.', 'All', NULL, 0, GETDATE(), 'TEA-2026-0001'),
('Term 01 Exam Reports Published', 'Please check the results tab to access the comprehensive digital grade book cards for Term 01.', 'Parents', NULL, 1, GETDATE(), 'TEA-2026-0001'),
('DBMS Homework Sheet Uploaded', 'Teachers have published the advanced relational database tracking homework sheets due by the next session.', 'Students', NULL, 0, GETDATE(), 'TEA-2026-0001'),
('Sports Meet Postponement', 'Due to unpredictable weather patterns, the annual tracking sports meetup is pushed to next Friday.', 'All', NULL, 0, GETDATE(), 'TEA-2026-0001'),
('Teacher General Assembly', 'Operational meeting regarding the deployment of mid-year evaluation analytics blueprints.', 'Teachers', NULL, 1, GETDATE(), 'TEA-2026-0001'),
('ICT Lab Allocation Change', 'Grade 11-B ICT Lab practicals will temporarily use the main campus resource wing room 03.', 'Students', NULL, 0, GETDATE(), 'TEA-2026-0001'),
('Vaccination Drive Registration', 'Please update complete demographic profiles to ensure health compliance logging tracks smoothly.', 'Parents', NULL, 0, GETDATE(), 'TEA-2026-0001'),
('Holiday Notice: Vesak Festival', 'The school will remain closed for academic delivery lines in observance of the Vesak festival.', 'All', NULL, 1, GETDATE(), 'TEA-2026-0001'),
('Advanced SQL Seminar Registration', 'Guest lecture track focusing on query performance optimization and database tuning routines.', 'Students', NULL, 0, GETDATE(), 'TEA-2026-0001'),
('Incomplete Profile Cleanup', 'Administrative auditing flags show multiple parent records with missing contact data chains.', 'Parents', NULL, 1, GETDATE(), 'TEA-2026-0001');
GO

-- =====================================================
-- 16. VERIFICATION QUERIES
-- =====================================================

SELECT COUNT(*) AS UserCount FROM [User];
SELECT COUNT(*) AS StudentCount FROM Student;
SELECT COUNT(*) AS TeacherCount FROM Teacher;
SELECT COUNT(*) AS ParentCount FROM Parent;
SELECT COUNT(*) AS AssociationCount FROM ParentStudentAssociation;

SELECT * FROM vw_StudentAcademicPerformanceSummary;
SELECT dbo.fn_CalculateStudentTermAverage('STU-2026-0001', 'Term 01', 2026) AS AverageMarks;
EXEC sp_GetStudentDashboardPayload 'STU-2026-0001', 'Term 01', 2026;
SELECT * FROM fn_GetClassRosterReport('CLS-11B');