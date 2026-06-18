const sql = require('mssql/msnodesqlv8');
const config = {
    server: '.\\SQLEXPRESS',
    database: 'SmartEduDB',
    driver: 'SQL Server',
    options: {
        trustedConnection: true,
        encrypt: false
    }
};

async function createAndSeed() {
    try {
        await sql.connect(config);
        console.log("Connected to database...");

        // 1. Create Attendance table
        await sql.query`
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Attendance' and xtype='U')
            BEGIN
                CREATE TABLE Attendance (
                    AttendanceID INT IDENTITY(1,1) NOT NULL,
                    StudentID VARCHAR(15) NOT NULL,
                    CourseID CHAR(8) NOT NULL,
                    AttendanceDate DATE NOT NULL,
                    IsPresent BIT NOT NULL,
                    CONSTRAINT PK_Attendance PRIMARY KEY (AttendanceID),
                    CONSTRAINT FK_Attendance_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID) ON UPDATE CASCADE ON DELETE CASCADE,
                    CONSTRAINT FK_Attendance_Course FOREIGN KEY (CourseID) REFERENCES Course(CourseID) ON UPDATE CASCADE ON DELETE CASCADE
                );
                PRINT 'Attendance table created.'
            END
            ELSE
            BEGIN
                PRINT 'Attendance table already exists.'
            END
        `;

        // 2. Insert dummy attendance data for STU-2026-0001
        // We'll insert 20 days of data for the first student: 18 present, 2 absent (90% attendance)
        await sql.query`
            IF NOT EXISTS (SELECT * FROM Attendance WHERE StudentID = 'STU-2026-0001')
            BEGIN
                DECLARE @Course CHAR(8) = 'SUB-MATH';
                DECLARE @CurrentDate DATE = DATEADD(day, -20, GETDATE());
                DECLARE @EndDate DATE = GETDATE();
                DECLARE @IsPresent BIT;
                
                WHILE @CurrentDate <= @EndDate
                BEGIN
                    -- Make weekend days absent or just randomly pick 2 days to be absent
                    IF (DATENAME(dw, @CurrentDate) = 'Saturday' OR DATENAME(dw, @CurrentDate) = 'Sunday')
                        SET @IsPresent = 0;
                    ELSE
                        SET @IsPresent = 1;

                    INSERT INTO Attendance (StudentID, CourseID, AttendanceDate, IsPresent)
                    VALUES ('STU-2026-0001', @Course, @CurrentDate, @IsPresent);
                    
                    SET @CurrentDate = DATEADD(day, 1, @CurrentDate);
                END
                
                PRINT 'Sample attendance data inserted for STU-2026-0001.'
            END
        `;

        // Let's insert a few for STU-2026-0002 as well
        await sql.query`
            IF NOT EXISTS (SELECT * FROM Attendance WHERE StudentID = 'STU-2026-0002')
            BEGIN
                DECLARE @Course CHAR(8) = 'SUB-ENG ';
                DECLARE @CurrentDate DATE = DATEADD(day, -20, GETDATE());
                DECLARE @EndDate DATE = GETDATE();
                DECLARE @IsPresent BIT;
                
                WHILE @CurrentDate <= @EndDate
                BEGIN
                    IF (DATENAME(dw, @CurrentDate) = 'Saturday')
                        SET @IsPresent = 0;
                    ELSE
                        SET @IsPresent = 1;

                    INSERT INTO Attendance (StudentID, CourseID, AttendanceDate, IsPresent)
                    VALUES ('STU-2026-0002', @Course, @CurrentDate, @IsPresent);
                    
                    SET @CurrentDate = DATEADD(day, 1, @CurrentDate);
                END
                
                PRINT 'Sample attendance data inserted for STU-2026-0002.'
            END
        `;

        console.log("Script completed successfully.");
        process.exit(0);
    } catch (err) {
        console.error("Error:", err);
        process.exit(1);
    }
}
createAndSeed();
