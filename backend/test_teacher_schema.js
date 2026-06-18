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
