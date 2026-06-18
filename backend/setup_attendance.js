const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});

const sql = {
    async query(strings, ...values) {
        let text = typeof strings === 'string' ? strings : strings[0];
        let vals = values;
        if (typeof strings !== 'string') {
            for (let i = 0; i < values.length; i++) {
                text += '$' + (i + 1) + strings[i + 1];
            }
        }
        text = text.replace(/\[User\]/g, '"User"');
        text = text.replace(/sysobjects WHERE name='([^']+)' and xtype='U'/g, "information_schema.tables WHERE table_name='$1'");
        text = text.replace(/\bISNULL\b/gi, 'COALESCE');
        
        if (/SELECT TOP (\d+) ([\s\S]*)/i.test(text)) {
            const limit = text.match(/SELECT TOP (\d+)/i)[1];
            text = text.replace(/SELECT TOP \d+/i, 'SELECT');
            text = text + ' LIMIT ' + limit;
        }
        
        try {
            const res = await pool.query(text, vals);
            return { recordset: res.rows.map(row => new Proxy(row, { get: (t, n) => typeof n === 'string' ? (t[n] !== undefined ? t[n] : t[n.toLowerCase()]) : t[n] })) };
        } catch (err) {
            console.error('DB Error:', text, err.message);
            throw err;
        }
    },
    Transaction: class {
        async begin() {
            this.client = await pool.connect();
            await this.client.query('BEGIN');
        }
        async commit() {
            await this.client.query('COMMIT');
            this.client.release();
        }
        async rollback() {
            await this.client.query('ROLLBACK');
            if (this.client) this.client.release();
        }
    },
    Request: class {
        constructor(transaction) {
            this.transaction = transaction;
        }
        async query(strings, ...values) {
            let text = typeof strings === 'string' ? strings : strings[0];
            let vals = values;
            if (typeof strings !== 'string') {
                for (let i = 0; i < values.length; i++) {
                    text += '$' + (i + 1) + strings[i + 1];
                }
            }
            text = text.replace(/\[User\]/g, '"User"');
            text = text.replace(/sysobjects WHERE name='([^']+)' and xtype='U'/g, "information_schema.tables WHERE table_name='$1'");
            text = text.replace(/\bISNULL\b/gi, 'COALESCE');
            
            const res = await this.transaction.client.query(text, vals);
            return { recordset: res.rows.map(row => new Proxy(row, { get: (t, n) => typeof n === 'string' ? (t[n] !== undefined ? t[n] : t[n.toLowerCase()]) : t[n] })) };
        }
    },
    connect: async () => { return pool; }
};



async function createAndSeed() {
    try {
        await sql.connect();
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
