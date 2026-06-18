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


async function check() {
    try {
        await sql.connect();
        const res = await sql.query(`SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Teacher'`);
        console.log("Teacher Columns:", res.recordset);
        const res2 = await sql.query(`SELECT TOP 1 * FROM Teacher`);
        console.log("Sample Data:", res2.recordset);
    } catch(e) {
        console.error(e);
    }
    process.exit();
}
check();
