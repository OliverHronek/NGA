require('dotenv').config();
const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;

app.get('/health', (req, res) => {
    res.json({ status: 'OK', message: 'Minimal server running' });
});

app.listen(PORT, () => {
    console.log(`✅ Minimal server running on port ${PORT}`);
});
