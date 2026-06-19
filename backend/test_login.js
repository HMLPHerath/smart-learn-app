const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});

const sql = {
    connect: async () => {}, // Dummy connect for compatibility
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
            console.error('DB Error Stack:', err.stack);
            throw err;
        }
    }
};

async function testLogin() {
    try {
        const email = 'student@smartedu.com';
        const hashedPassword = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92';
        await sql.connect();
        const result = await sql.query`SELECT * FROM [User] WHERE Email = ${email} AND PasswordHash = ${hashedPassword}`;
        console.log("Recordset length:", result.recordset.length);
    } catch(err) {
        console.error("Test failed:", err.message);
    } finally {
        pool.end();
    }
}
testLogin();
