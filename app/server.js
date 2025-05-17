const express = require('express')
const app = express()
const os = require('os');
app.get('/whoami', function(req, res) {
    res.send(`<h3>I am ${os.hostname()}</h3>`);
})
app.listen(8081, function() {
    console.log('app listening on port 8081!')
})
