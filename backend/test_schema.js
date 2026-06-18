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
        const res = await sql.query(`SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ScheduleItem'`);
        console.log(res.recordset);
    } catch(e) {
        console.error(e);
    }
    process.exit();
}
check();
