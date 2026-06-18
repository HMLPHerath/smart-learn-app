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

async function test() {
    try {
        await sql.connect(config);
        const result = await sql.query`SELECT StudentID, FullName, ClassID FROM Student`;
        console.log("Students:", result.recordset);
        const courses = await sql.query`SELECT CourseID, CourseName FROM Course`;
        console.log("Courses:", courses.recordset);
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}
test();
