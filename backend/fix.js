const fs = require('fs'); 
let data = fs.readFileSync('server.js', 'utf8'); 
data = data.replace(/ as ([a-zA-Z0-9_]+)/gi, (match, p1) => { 
    if (['DECIMAL', 'INT', 'TIME'].includes(p1.toUpperCase())) return match; 
    return ' AS "' + p1 + '"'; 
}); 
fs.writeFileSync('server.js', data);
