const fs = require('fs');
const path = require('path');

const polyfill = "const { Pool } = require('pg');\n" +
"require('dotenv').config();\n" +
"\n" +
"const pool = new Pool({\n" +
"    connectionString: process.env.DATABASE_URL,\n" +
"    ssl: { rejectUnauthorized: false }\n" +
"});\n" +
"\n" +
"const sql = {\n" +
"    async query(strings, ...values) {\n" +
"        let text = typeof strings === 'string' ? strings : strings[0];\n" +
"        let vals = values;\n" +
"        if (typeof strings !== 'string') {\n" +
"            for (let i = 0; i < values.length; i++) {\n" +
"                text += '$' + (i + 1) + strings[i + 1];\n" +
"            }\n" +
"        }\n" +
"        text = text.replace(/\\[User\\]/g, '\"User\"');\n" +
"        text = text.replace(/sysobjects WHERE name='([^']+)' and xtype='U'/g, \"information_schema.tables WHERE table_name='$1'\");\n" +
"        text = text.replace(/\\bISNULL\\b/gi, 'COALESCE');\n" +
"        \n" +
"        if (/SELECT TOP (\\d+) ([\\s\\S]*)/i.test(text)) {\n" +
"            const limit = text.match(/SELECT TOP (\\d+)/i)[1];\n" +
"            text = text.replace(/SELECT TOP \\d+/i, 'SELECT');\n" +
"            text = text + ' LIMIT ' + limit;\n" +
"        }\n" +
"        \n" +
"        try {\n" +
"            const res = await pool.query(text, vals);\n" +
"            return { recordset: res.rows.map(row => new Proxy(row, { get: (t, n) => typeof n === 'string' ? (t[n] !== undefined ? t[n] : t[n.toLowerCase()]) : t[n] })) };\n" +
"        } catch (err) {\n" +
"            console.error('DB Error:', text, err.message);\n" +
"            throw err;\n" +
"        }\n" +
"    },\n" +
"    Transaction: class {\n" +
"        async begin() {\n" +
"            this.client = await pool.connect();\n" +
"            await this.client.query('BEGIN');\n" +
"        }\n" +
"        async commit() {\n" +
"            await this.client.query('COMMIT');\n" +
"            this.client.release();\n" +
"        }\n" +
"        async rollback() {\n" +
"            await this.client.query('ROLLBACK');\n" +
"            if (this.client) this.client.release();\n" +
"        }\n" +
"    },\n" +
"    Request: class {\n" +
"        constructor(transaction) {\n" +
"            this.transaction = transaction;\n" +
"        }\n" +
"        async query(strings, ...values) {\n" +
"            let text = typeof strings === 'string' ? strings : strings[0];\n" +
"            let vals = values;\n" +
"            if (typeof strings !== 'string') {\n" +
"                for (let i = 0; i < values.length; i++) {\n" +
"                    text += '$' + (i + 1) + strings[i + 1];\n" +
"                }\n" +
"            }\n" +
"            text = text.replace(/\\[User\\]/g, '\"User\"');\n" +
"            text = text.replace(/sysobjects WHERE name='([^']+)' and xtype='U'/g, \"information_schema.tables WHERE table_name='$1'\");\n" +
"            text = text.replace(/\\bISNULL\\b/gi, 'COALESCE');\n" +
"            \n" +
"            const res = await this.transaction.client.query(text, vals);\n" +
"            return { recordset: res.rows.map(row => new Proxy(row, { get: (t, n) => typeof n === 'string' ? (t[n] !== undefined ? t[n] : t[n.toLowerCase()]) : t[n] })) };\n" +
"        }\n" +
"    },\n" +
"    connect: async () => { return pool; }\n" +
"};\n";

const files = fs.readdirSync(__dirname).filter(f => f.endsWith('.js') && f !== 'migrate.js');

for (const file of files) {
    let content = fs.readFileSync(path.join(__dirname, file), 'utf8');
    
    if (content.includes("require('mssql/msnodesqlv8')") || content.includes('require("mssql/msnodesqlv8")')) {
        content = content.replace(/const sql = require\(['"]mssql\/msnodesqlv8['"]\);/, () => polyfill);
        content = content.replace(/const config = {[\s\S]*?encrypt: false[ \t]*\n[ \t]*}[ \t]*\n?[ \t]*};/m, '');
        fs.writeFileSync(path.join(__dirname, file), content);
        console.log('Migrated ' + file);
    }
}

const pkgPath = path.join(__dirname, 'package.json');
const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
pkg.scripts = pkg.scripts || {};
pkg.scripts.start = 'node server.js';
fs.writeFileSync(pkgPath, JSON.stringify(pkg, null, 2));

let serverJs = fs.readFileSync(path.join(__dirname, 'server.js'), 'utf8');
serverJs = serverJs.replace(/const PORT = 3000;/, 'const PORT = process.env.PORT || 3000;');
fs.writeFileSync(path.join(__dirname, 'server.js'), serverJs);
