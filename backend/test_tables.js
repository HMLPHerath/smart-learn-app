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
async function check() {
    try {
        await sql.connect(config);
        const tables = await sql.query(`SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'`);
        console.log("Tables:", tables.recordset.map(t => t.TABLE_NAME));
        
        // If there's an exam or result table, let's query it
        if (tables.recordset.some(t => t.TABLE_NAME === 'Result' || t.TABLE_NAME === 'ExamResult' || t.TABLE_NAME === 'Gradebook' || t.TABLE_NAME === 'Exam')) {
             console.log("Found result related table!");
        }
    } catch(e) {
        console.error(e);
    }
    process.exit();
}
check();
