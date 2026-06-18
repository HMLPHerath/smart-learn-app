const fs = require('fs');
const path = require('path');

const files = fs.readdirSync(__dirname).filter(f => f.endsWith('.js') && f !== 'patch.js');

for (const file of files) {
    let content = fs.readFileSync(path.join(__dirname, file), 'utf8');
    
    if (content.includes("return { recordset: res.rows };")) {
        content = content.replace(/return \{ recordset: res\.rows \};/g, "return { recordset: res.rows.map(row => new Proxy(row, { get: (t, n) => typeof n === 'string' ? (t[n] !== undefined ? t[n] : t[n.toLowerCase()]) : t[n] })) };");
        fs.writeFileSync(path.join(__dirname, file), content);
        console.log('Patched ' + file);
    }
}
