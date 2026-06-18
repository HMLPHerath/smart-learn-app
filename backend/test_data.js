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
        const students = await sql.query(`SELECT StudentID, FullName, ClassID FROM Student`);
        console.log("Students:", students.recordset);
        
        const classes = await sql.query(`SELECT * FROM Class`);
        console.log("Classes:", classes.recordset);

        const schedule = await sql.query(`SELECT * FROM ScheduleItem`);
        console.log("Schedules:", schedule.recordset);
    } catch(e) {
        console.error(e);
    }
    process.exit();
}
check();
