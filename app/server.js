const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;
const APP_VERSION = process.env.APP_VERSION || '1.0.0';
const APP_ENV = process.env.APP_ENV || 'development';
const APP_COLOUR = process.env.APP_COLOUR || '#0ea5e9';

app.use(express.json());
app.use(express.static('public'));

// Health endpoint — used by Kubernetes liveness/readiness probes
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    version: APP_VERSION,
    environment: APP_ENV,
    hostname: require('os').hostname(),
    uptime: Math.floor(process.uptime()),
  });
});

// Version endpoint — learners will update this to trigger GitOps sync
app.get('/version', (req, res) => {
  res.json({ version: APP_VERSION, env: APP_ENV });
});

// Simple root page
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>GitOps Demo App</title>
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
          background: #0f172a;
          color: #e2e8f0;
          min-height: 100vh;
          display: flex;
          align-items: center;
          justify-content: center;
        }
        .card {
          background: #1e293b;
          border: 2px solid ${APP_COLOUR};
          border-radius: 12px;
          padding: 2.5rem 3rem;
          text-align: center;
          max-width: 480px;
          width: 90%;
        }
        .badge {
          display: inline-block;
          background: ${APP_COLOUR};
          color: white;
          font-size: 0.75rem;
          font-weight: 700;
          letter-spacing: 0.1em;
          padding: 0.25rem 0.75rem;
          border-radius: 999px;
          text-transform: uppercase;
          margin-bottom: 1rem;
        }
        h1 { font-size: 1.75rem; margin-bottom: 0.5rem; }
        .version {
          font-size: 3rem;
          font-weight: 800;
          color: ${APP_COLOUR};
          margin: 1rem 0;
        }
        .meta { color: #94a3b8; font-size: 0.875rem; line-height: 1.8; }
        .meta strong { color: #e2e8f0; }
      </style>
    </head>
    <body>
      <div class="card">
        <div class="badge">${APP_ENV}</div>
        <h1>GitOps Demo App</h1>
        <div class="version">v${APP_VERSION}</div>
        <div class="meta">
          <p><strong>Hostname:</strong> ${require('os').hostname()}</p>
          <p><strong>Environment:</strong> ${APP_ENV}</p>
          <p><strong>Colour:</strong> ${APP_COLOUR}</p>
        </div>
      </div>
    </body>
    </html>
  `);
});

app.listen(PORT, () => {
  console.log(`GitOps demo app v${APP_VERSION} running on port ${PORT}`);
  console.log(`Environment: ${APP_ENV}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received — shutting down gracefully');
  process.exit(0);
});
