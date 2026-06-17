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
            VALUES ('ADM-2026-0001', 'admin@smartedu.com', 'demo_hash_here', '0770000000', 'Active', NULL)
        `;
        
        res.json({ success: true, message: 'Demo data inserted successfully into [User] table.' });
    } catch (err) {
        console.error('Insert failed', err);
        res.status(500).json({ success: false, message: 'Failed to insert data', error: err.message });
    }
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Backend API running at http://localhost:${PORT}`);
});
