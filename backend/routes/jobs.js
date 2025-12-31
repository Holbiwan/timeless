const express = require('express');
const router = express.Router();

// Placeholder for jobs routes
router.get('/', (req, res) => {
  res.json({ message: 'List jobs endpoint' });
});

module.exports = router;
