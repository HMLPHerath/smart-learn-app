const sql = require('msnodesqlv8');

const connectionString = "server=localhost\\SQLEXPRESS;Database=SmartEduDB;Trusted_Connection=Yes;Driver={ODBC Driver 17 for SQL Server}";

async function setupGuideBooks() {
    console.log("Connecting to SQL Server...");
    
    return new Promise((resolve, reject) => {
        sql.open(connectionString, (err, conn) => {
            if (err) {
                console.error("Connection Failed:", err.message);
                return reject(err);
            }
            console.log("Connected successfully.");

            const query = `
                IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='GuideBook' and xtype='U')
                BEGIN
                    CREATE TABLE GuideBook (
                        BookID INT IDENTITY(1,1) PRIMARY KEY,
                        Title VARCHAR(100) NOT NULL,
                        Subtitle VARCHAR(255),
                        IconName VARCHAR(50),
                        ColorHex VARCHAR(10),
                        FileUrl VARCHAR(255),
                        Category VARCHAR(50)
                    )
                    
                    INSERT INTO GuideBook (Title, Subtitle, IconName, ColorHex, FileUrl, Category)
                    VALUES 
                    ('DBMS Handbook', 'Advanced database concepts', 'storage', '#D7DDF4', 'https://example.com/dbms.pdf', 'All'),
                    ('Algebra Guide', 'Equations, functions and graphs', 'functions', '#F5DE9B', 'https://example.com/algebra.pdf', 'Recent'),
                    ('Physics Guide', 'Motion, energy and forces', 'science', '#CBE8C7', 'https://example.com/physics.pdf', 'Popular'),
                    ('English Workbook', 'Grammar and writing practice', 'book', '#D7DDF4', 'https://example.com/english.pdf', 'All'),
                    ('ICT Practical Guide', 'Flowcharts, logic and systems', 'computer', '#CBE8C7', 'https://example.com/ict.pdf', 'All');
                    
                    SELECT 'GuideBook table created and seeded' as Result;
                END
                ELSE
                BEGIN
                    SELECT 'GuideBook table already exists' as Result;
                END
            `;

            conn.query(query, (err, results) => {
                if (err) {
                    console.error("Error executing query:", err.message);
                    conn.close();
                    return reject(err);
                }
                
                console.log("Query Results:", results);
                conn.close();
                resolve(results);
            });
        });
    });
}

setupGuideBooks().then(() => {
    console.log("Setup completed.");
}).catch(e => {
    console.error("Setup failed:", e);
});
