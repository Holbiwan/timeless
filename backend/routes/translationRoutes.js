const express = require('express');
const router = express.Router();
const { TranslationServiceClient } = require('@google-cloud/translate');
const path = require('path');

// Initialize TranslationServiceClient with service account key
const credentialsPath = path.join(__dirname, '..', 'service-account.json');
const translationClient = new TranslationServiceClient({
  keyFilename: credentialsPath,
});

// Translation endpoint
router.post('/', async (req, res) => {
  const { text, targetLanguage } = req.body;
  const projectId = process.env.GOOGLE_CLOUD_PROJECT_ID; // Make sure to set this in your .env
  const location = 'global'; // Or your specific region, e.g., 'us-central1'

  if (!text || !targetLanguage) {
    return res.status(400).json({ error: 'Text and targetLanguage are required.' });
  }
  if (!projectId) {
    return res.status(500).json({ error: 'GOOGLE_CLOUD_PROJECT_ID is not set in environment variables.' });
  }

  try {
    const request = {
      parent: `projects/${projectId}/locations/${location}`,
      contents: [text],
      targetLanguageCode: targetLanguage,
    };

    const [response] = await translationClient.translateText(request);
    const translatedText = response.translations[0].translatedText;

    res.json({ translatedText });
  } catch (error) {
    console.error('Translation error:', error);
    res.status(500).json({ error: 'Failed to translate text.', details: error.message });
  }
});

module.exports = router;
