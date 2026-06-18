const fs = require('fs');
const path = require('path');

const files = fs.readdirSync(__dirname).filter(f => f.endsWith('.js') && f !== 'migrate.js');

for (const file of files) {
    let content = fs.readFileSync(path.join(__dirname, file), 'utf8');
    
    if (content.includes("await sql.connect();")) {
        content = content.replace(/await sql.connect\(config\);/g, "await sql.connect();");
        fs.writeFileSync(path.join(__dirname, file), content);
        console.log('Fixed config in ' + file);
    }
}
