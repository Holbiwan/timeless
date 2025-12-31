const express = require('express');
const router = express.Router();

// Placeholder for user routes
router.get('/:id', (req, res) => {
  res.json({ message: `Get user ${req.params.id}` });
});

module.exports = router;
