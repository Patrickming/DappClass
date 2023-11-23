const express = require('express')
const app = express()

app.get('/', function (req, res) {
  res.send('Hello World')
})

app.get('/app', function (req, res) {
    res.send('app')
  })
app.listen(3000)