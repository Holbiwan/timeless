const express = require('express');
const router = express.Router();
const { JobServiceClient } = require('@google-cloud/talent');
const path = require('path');

const credentialsPath = path.join(__dirname, '..', 'service-account.json');
const jobClient = new JobServiceClient({
  keyFilename: credentialsPath,
});

// Search jobs endpoint
router.post('/search', async (req, res) => {
  const { query, languageCode, pageSize, pageToken } = req.body;
  const projectId = process.env.GOOGLE_CLOUD_PROJECT_ID;
  const tenantId = process.env.GOOGLE_CLOUD_TENANT_ID; // Required for Cloud Talent Solution
  const parent = `projects/${projectId}/tenants/${tenantId}`;

  if (!projectId || !tenantId) {
    return res.status(500).json({ error: 'GOOGLE_CLOUD_PROJECT_ID and GOOGLE_CLOUD_TENANT_ID must be set in environment variables.' });
  }

  const request = {
    parent,
    searchQuery: {
      query,
      languageCodes: languageCode ? [languageCode] : [],
    },
    pageSize: pageSize || 10,
    pageToken: pageToken || '',
  };

  try {
    const [response] = await jobClient.searchJobs(request);
    res.json(response);
  } catch (error) {
    console.error('Job search error:', error);
    res.status(500).json({ error: 'Failed to search jobs.', details: error.message });
  }
});

// Optionally, add an endpoint to create or update jobs if your app manages jobs in CTS
/*
router.post('/jobs', async (req, res) => {
  const { jobData } = req.body;
  const projectId = process.env.GOOGLE_CLOUD_PROJECT_ID;
  const tenantId = process.env.GOOGLE_CLOUD_TENANT_ID;
  const parent = `projects/${projectId}/tenants/${tenantId}`;

  if (!projectId || !tenantId) {
    return res.status(500).json({ error: 'GOOGLE_CLOUD_PROJECT_ID and GOOGLE_CLOUD_TENANT_ID must be set in environment variables.' });
  }

  const request = {
    parent,
    job: jobData, // jobData should conform to the Job object structure
  };

  try {
    const [response] = await jobClient.createJob(request);
    res.json(response);
  } catch (error) {
    console.error('Create job error:', error);
    res.status(500).json({ error: 'Failed to create job.', details: error.message });
  }
});
*/

module.exports = router;
