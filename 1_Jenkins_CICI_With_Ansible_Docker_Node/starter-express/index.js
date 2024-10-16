const express = require('express')
const app = express()
app.get('/', (req, res) => {
    console.log("Just got a request!")
    res.send('Sample Node ')
    res.send('Node JS Applications ')
})
app.listen(process.env.PORT || 3000)
