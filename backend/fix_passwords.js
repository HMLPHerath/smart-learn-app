const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});

async function fixPasswords() {
    // SHA256 hash for '123456'
    const hash123456 = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92'; 
    try {
        const res = await pool.query(`UPDATE "User" SET PasswordHash = $1 WHERE Email IN ('teacher@smartedu.com', 'parent@smartedu.com', 'student@smartedu.com')`, [hash123456]);
        console.log(`Passwords fixed successfully! Rows updated: ${res.rowCount}`);
    } catch(err) {
        console.error('Error fixing passwords:', err);
    } finally {
        pool.end();
    }
}

fixPasswords();
