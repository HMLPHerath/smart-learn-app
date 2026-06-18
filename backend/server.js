const express = require('express');
const sql = require('mssql/msnodesqlv8');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Configuration for Windows Authentication
const config = {
    server: '.\\SQLEXPRESS',
    database: 'SmartEduDB', // Using the DB name from database.md
    driver: 'SQL Server', // Explicitly specify standard driver
    options: {
        trustedConnection: true,
        encrypt: false // Since it's a local SQLEXPRESS
    }
};

// Test connection endpoint
app.get('/test', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query`SELECT 1 as test`;
        res.json({ success: true, message: 'Successfully connected to SQL Server using Windows Authentication!', result: result.recordset });
    } catch (err) {
        console.error('Database connection failed', err);
        res.status(500).json({ success: false, message: 'Failed to connect to database', error: err.message });
    }
});

// Demo insert endpoint
app.post('/demo-insert', async (req, res) => {
    try {
        await sql.connect(config);
        
        // Ensure table exists, if not, create a basic one for demo
        try {
            await sql.query`
                IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='User' and xtype='U')
                CREATE TABLE [User] (
                    UserID VARCHAR(15) PRIMARY KEY,
                    Email VARCHAR(100),
                    PasswordHash CHAR(64),
                    PhoneNumber VARCHAR(15),
                    AccountStatus VARCHAR(15),
                    ProfilePictureURI VARCHAR(255)
                )
            `;
        } catch(e) {
            console.log('Error creating table:', e.message);
        }

        // Insert demo data
        await sql.query`
            IF NOT EXISTS (SELECT * FROM [User] WHERE UserID = 'ADM-2026-0001')
            INSERT INTO [User] (UserID, Email, PasswordHash, PhoneNumber, AccountStatus, ProfilePictureURI)
            VALUES ('ADM-2026-0001', 'admin@smartedu.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', '0770000000', 'Active', NULL)
        `;
        res.json({ success: true, message: 'Demo data inserted successfully into [User] table.' });
    } catch (err) {
        console.error('Insert failed', err);
        res.status(500).json({ success: false, message: 'Failed to insert data', error: err.message });
    }
});

// Login endpoint
app.post('/api/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        const crypto = require('crypto');
        const hashedPassword = crypto.createHash('sha256').update(password).digest('hex');
        await sql.connect(config);
        
        // Use parameterized query to prevent SQL injection
        const result = await sql.query`SELECT * FROM [User] WHERE Email = ${email} AND PasswordHash = ${hashedPassword}`;
        
        if (result.recordset.length > 0) {
            const user = result.recordset[0];
            
            // Determine role from UserID prefix
            let role = 'unknown';
            if (user.UserID.startsWith('ADM-')) role = 'admin';
            else if (user.UserID.startsWith('STU-')) role = 'student';
            else if (user.UserID.startsWith('TEA-')) role = 'teacher';
            else if (user.UserID.startsWith('PAR-')) role = 'parent';
            
            res.json({
                success: true,
                message: 'Login successful',
                token: 'dummy_jwt_token_12345',
                userId: user.UserID,
                role: role,
                email: user.Email,
                name: user.UserID // We'll use ID as name until we fetch the profile
            });
        } else {
            res.status(401).json({ success: false, message: 'Invalid email or password' });
        }
    } catch (err) {
        console.error('Login failed', err);
        res.status(500).json({ success: false, message: 'Server error during login', error: err.message });
    }
});

// Get user profile endpoint
app.get('/api/users/:id', async (req, res) => {
    try {
        const userId = req.params.id;
        await sql.connect(config);
        
        const result = await sql.query`SELECT * FROM [User] WHERE UserID = ${userId}`;
        
        if (result.recordset.length > 0) {
            const user = result.recordset[0];
            let role = 'unknown';
            if (user.UserID.startsWith('ADM-')) role = 'admin';
            else if (user.UserID.startsWith('STU-')) role = 'student';
            else if (user.UserID.startsWith('TEA-')) role = 'teacher';
            else if (user.UserID.startsWith('PAR-')) role = 'parent';
            
            res.json({
                success: true,
                user: {
                    uid: user.UserID,
                    email: user.Email,
                    role: role,
                    name: user.UserID, // Default name fallback
                    accountStatus: user.AccountStatus,
                    profilePicture: user.ProfilePictureURI
                }
            });
        } else {
            res.status(404).json({ success: false, message: 'User not found' });
        }
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

// Get Students endpoint
app.get('/api/students', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query`
            SELECT s.*, u.Email, u.PhoneNumber, u.AccountStatus, u.ProfilePictureURI 
            FROM Student s 
            JOIN [User] u ON s.StudentID = u.UserID
        `;
        res.json({ success: true, students: result.recordset });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

// Get Student by ID
app.get('/api/students/:id', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query`
            SELECT s.*, u.Email, u.PhoneNumber, u.AccountStatus, u.ProfilePictureURI 
            FROM Student s 
            JOIN [User] u ON s.StudentID = u.UserID
            WHERE s.StudentID = ${req.params.id}
        `;
        if (result.recordset.length > 0) {
            res.json({ success: true, student: result.recordset[0] });
        } else {
            res.status(404).json({ success: false, message: 'Student not found' });
        }
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

// Create Student endpoint
app.post('/api/students', async (req, res) => {
    try {
        const { studentId, email, phoneNumber, fullName, dateOfBirth, address, parentId, studentClass } = req.body;
        const defaultPasswordHash = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92'; // 123456

        await sql.connect(config);
        
        const transaction = new sql.Transaction();
        await transaction.begin();
        
        try {
            const request1 = new sql.Request(transaction);
            await request1.query`
                INSERT INTO [User] (UserID, Email, PasswordHash, PhoneNumber, AccountStatus)
                VALUES (${studentId}, ${email}, ${defaultPasswordHash}, ${phoneNumber}, 'Active')
            `;
            
            const request2 = new sql.Request(transaction);
            await request2.query`
                INSERT INTO Student (StudentID, FullName, DateOfBirth, HomeAddress, BirthCertificatePath, ClassID)
                VALUES (${studentId}, ${fullName}, ${dateOfBirth}, ${address}, '/docs/default.pdf', NULL)
            `;
            
            if (parentId) {
                const request3 = new sql.Request(transaction);
                await request3.query`
                    INSERT INTO ParentStudentAssociation (ParentID, StudentID, Relationship)
                    VALUES (${parentId}, ${studentId}, 'Guardian')
                `;
            }
            
            await transaction.commit();
            res.json({ success: true, message: 'Student created successfully' });
        } catch (err) {
            await transaction.rollback();
            throw err;
        }
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

// Get Teachers endpoint
app.get('/api/teachers', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query`
            SELECT t.*, u.Email, u.PhoneNumber, u.AccountStatus, u.ProfilePictureURI 
            FROM Teacher t 
            JOIN [User] u ON t.TeacherID = u.UserID
        `;
        res.json({ success: true, teachers: result.recordset });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

// Get Teacher by ID
app.get('/api/teachers/:id', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query`
            SELECT t.*, u.Email, u.PhoneNumber, u.AccountStatus, u.ProfilePictureURI 
            FROM Teacher t 
            JOIN [User] u ON t.TeacherID = u.UserID
            WHERE t.TeacherID = ${req.params.id}
        `;
        if (result.recordset.length > 0) {
            res.json({ success: true, teacher: result.recordset[0] });
        } else {
            res.status(404).json({ success: false, message: 'Teacher not found' });
        }
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

// Get all distinct students taught by a teacher
app.get('/api/teacher/:id/students', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query`
            SELECT DISTINCT s.StudentID, s.FullName, c.ClassName, u.AccountStatus 
            FROM Student s 
            JOIN Class c ON s.ClassID = c.ClassID
            JOIN ScheduleItem si ON c.ClassID = si.ClassID
            JOIN [User] u ON s.StudentID = u.UserID
            WHERE si.TeacherID = ${req.params.id}
            ORDER BY s.FullName ASC
        `;
        res.json({ success: true, students: result.recordset });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

// Create Teacher endpoint
app.post('/api/teachers', async (req, res) => {
    try {
        const { teacherId, email, phoneNumber, fullName, subject, qualifications } = req.body;
        const defaultPasswordHash = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92'; // 123456

        await sql.connect(config);
        
        const transaction = new sql.Transaction();
        await transaction.begin();
        
        try {
            const request1 = new sql.Request(transaction);
            await request1.query`
                INSERT INTO [User] (UserID, Email, PasswordHash, PhoneNumber, AccountStatus)
                VALUES (${teacherId}, ${email}, ${defaultPasswordHash}, ${phoneNumber}, 'Active')
            `;
            
            const request2 = new sql.Request(transaction);
            await request2.query`
                INSERT INTO Teacher (TeacherID, FullName, Specialization)
                VALUES (${teacherId}, ${fullName}, ${subject})
            `;
            
            await transaction.commit();
            res.json({ success: true, message: 'Teacher created successfully' });
        } catch (err) {
            await transaction.rollback();
            throw err;
        }
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

// Get Parents endpoint
app.get('/api/parents', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query`
            SELECT p.*, u.Email, u.PhoneNumber, u.AccountStatus, u.ProfilePictureURI 
            FROM Parent p 
            JOIN [User] u ON p.ParentID = u.UserID
        `;
        res.json({ success: true, parents: result.recordset });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

// Get Parent by ID
app.get('/api/parents/:id', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query`
            SELECT p.*, u.Email, u.PhoneNumber, u.AccountStatus, u.ProfilePictureURI,
                   s.FullName AS childName, s.StudentID AS childStudentId, s.ClassID AS className
            FROM Parent p 
            JOIN [User] u ON p.ParentID = u.UserID
            LEFT JOIN ParentStudentAssociation psa ON p.ParentID = psa.ParentID
            LEFT JOIN Student s ON psa.StudentID = s.StudentID
            WHERE p.ParentID = ${req.params.id}
        `;
        if (result.recordset.length > 0) {
            res.json({ success: true, parent: result.recordset[0] });
        } else {
            res.status(404).json({ success: false, message: 'Parent not found' });
        }
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

// Create Parent endpoint
app.post('/api/parents', async (req, res) => {
    try {
        const { parentId, email, phoneNumber, fullName, nic } = req.body;
        const defaultPasswordHash = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92'; // 123456

        await sql.connect(config);
        
        const transaction = new sql.Transaction();
        await transaction.begin();
        
        try {
            const request1 = new sql.Request(transaction);
            await request1.query`
                INSERT INTO [User] (UserID, Email, PasswordHash, PhoneNumber, AccountStatus)
                VALUES (${parentId}, ${email}, ${defaultPasswordHash}, ${phoneNumber}, 'Active')
            `;
            
            const request2 = new sql.Request(transaction);
            await request2.query`
                INSERT INTO Parent (ParentID, FullName, NIC_Number, NIC_CopyPath)
                VALUES (${parentId}, ${fullName}, ${nic}, '/docs/default_nic.pdf')
            `;
            
            await transaction.commit();
            res.json({ success: true, message: 'Parent created successfully' });
        } catch (err) {
            await transaction.rollback();
            throw err;
        }
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

// Get Notices endpoint
app.get('/api/notices', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query`SELECT * FROM Notice ORDER BY CreatedAt DESC`;
        res.json({ success: true, notices: result.recordset });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

// Create Notice endpoint
app.post('/api/notices', async (req, res) => {
    try {
        const { noticeId, authorId, subject, noticeBody, audience, isUrgent } = req.body;
        
        await sql.connect(config);
        
        await sql.query`
            INSERT INTO Notice (CreatorAdminID, Subject, NoticeBody, Audience, IsUrgent)
            VALUES (${authorId}, ${subject}, ${noticeBody}, ${audience}, ${isUrgent ? 1 : 0})
        `;
        
        res.json({ success: true, message: 'Notice created successfully' });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

// Get Courses endpoint
app.get('/api/courses', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query`SELECT * FROM Course`;
        res.json({ success: true, courses: result.recordset });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

const PORT = 3000;

// Get Admin Dashboard Stats
app.get('/api/admin/dashboard-stats', async (req, res) => {
    try {
        await sql.connect(config);
        const countsResult = await sql.query`
            SELECT 
                (SELECT COUNT(*) FROM Student) AS totalStudents,
                (SELECT COUNT(*) FROM Parent) AS totalParents,
                (SELECT COUNT(*) FROM Teacher) AS totalTeachers,
                (SELECT COUNT(*) FROM Notice) AS totalNotices
        `;
        
        const noticesResult = await sql.query`
            SELECT TOP 3 * FROM Notice 
            WHERE IsUrgent = 1
            ORDER BY CreatedAt DESC
        `;
        
        const updatesResult = await sql.query`
            SELECT TOP 3 UserID, Email, AccountStatus 
            FROM [User] 
            ORDER BY UserID DESC
        `;
        
        res.json({ 
            success: true, 
            stats: {
                counts: countsResult.recordset[0],
                recentAlerts: noticesResult.recordset,
                latestUpdates: updatesResult.recordset
            }
        });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

// --- GRADEBOOK ENDPOINTS ---

// Get classes taught by a teacher
app.get('/api/teacher/:id/classes', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query`
            SELECT DISTINCT c.ClassID, c.ClassName 
            FROM ScheduleItem s 
            JOIN Class c ON s.ClassID = c.ClassID 
            WHERE s.TeacherID = ${req.params.id}
        `;
        res.json({ success: true, classes: result.recordset });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

// Get courses taught by a teacher in a specific class
app.get('/api/teacher/:id/courses/:classId', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query`
            SELECT DISTINCT c.CourseID, c.CourseName 
            FROM ScheduleItem s 
            JOIN Course c ON s.CourseID = c.CourseID 
            WHERE s.TeacherID = ${req.params.id} AND s.ClassID = ${req.params.classId}
        `;
        res.json({ success: true, courses: result.recordset });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

// Get students in a specific class
app.get('/api/classes/:classId/students', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query`
            SELECT StudentID, FullName 
            FROM Student 
            WHERE ClassID = ${req.params.classId}
            ORDER BY FullName ASC
        `;
        res.json({ success: true, students: result.recordset });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

// Get grades for a specific class, course, term, and year
app.get('/api/gradebook', async (req, res) => {
    try {
        const { classId, courseId, term, year } = req.query;
        await sql.connect(config);
        const result = await sql.query`
            SELECT g.StudentID, g.RawMarks, g.GradeLetter 
            FROM GradeBookRecord g
            JOIN Student s ON g.StudentID = s.StudentID
            WHERE s.ClassID = ${classId} 
              AND g.CourseID = ${courseId} 
              AND g.AcademicTerm = ${term} 
              AND g.AcademicYear = ${year}
        `;
        res.json({ success: true, grades: result.recordset });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

// Save (upsert) grades
app.post('/api/gradebook', async (req, res) => {
    try {
        const { term, year, courseId, grades } = req.body;
        await sql.connect(config);
        const transaction = new sql.Transaction();
        await transaction.begin();
        try {
            for (const grade of grades) {
                const request = new sql.Request(transaction);
                const exists = await request.query`
                    SELECT RecordID FROM GradeBookRecord 
                    WHERE StudentID = ${grade.studentId} 
                      AND CourseID = ${courseId} 
                      AND AcademicTerm = ${term} 
                      AND AcademicYear = ${year}
                `;
                
                if (exists.recordset.length > 0) {
                    const updateReq = new sql.Request(transaction);
                    await updateReq.query`
                        UPDATE GradeBookRecord 
                        SET RawMarks = ${grade.marks}, GradeLetter = ${grade.gradeLetter}
                        WHERE RecordID = ${exists.recordset[0].RecordID}
                    `;
                } else {
                    const insertReq = new sql.Request(transaction);
                    await insertReq.query`
                        INSERT INTO GradeBookRecord (RawMarks, GradeLetter, AcademicTerm, AcademicYear, StudentID, CourseID)
                        VALUES (${grade.marks}, ${grade.gradeLetter}, ${term}, ${year}, ${grade.studentId}, ${courseId})
                    `;
                }
            }
            await transaction.commit();
            res.json({ success: true, message: 'Grades saved successfully' });
        } catch (err) {
            await transaction.rollback();
            throw err;
        }
    } catch (err) {
        res.status(500).json({ success: false, message: 'Server error', error: err.message });
    }
});

app.listen(PORT, () => {
    console.log(`Backend API running at http://localhost:${PORT}`);
});
