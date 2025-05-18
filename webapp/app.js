// Basic Express App Setup
const express = require('express');
const app = express();
const dotenv = require('dotenv');

dotenv.config();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

app.get('/', (req, res) => {
    res.send('Hello from WebApp!');
});

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
