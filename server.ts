import express from 'express';
import { createServer as createViteServer } from 'vite';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';
import { initDbPool, getDbStatus } from './src/server/db.js';
import { apiRouter } from './src/server/routes.js';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function startServer() {
  const app = express();
  const preferredPort = Number(process.env.PORT) || 3000;

  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));

  // Basic CORS & security headers
  app.use((req, res, next) => {
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'SAMEORIGIN');
    next();
  });

  // Health check endpoint (Required by Section 7)
  const healthHandler = (req: express.Request, res: express.Response) => {
    const status = getDbStatus();
    res.json({
      success: true,
      server: 'running',
      database: status.connected ? 'connected' : 'disconnected',
    });
  };
  app.get('/health', healthHandler);
  app.get('/api/health', healthHandler);

  // Mount API endpoints
  app.use('/api', apiRouter);

  // Attempt MySQL Connection at startup
  console.log('[LIFEDROP] Initializing MySQL Database Connection Pool...');
  try {
    await initDbPool();
  } catch (err: any) {
    console.error('[LIFEDROP] Database initialization notice:', err.message);
  }

  const isProduction = process.env.NODE_ENV === 'production';

  if (!isProduction) {
    // Mount Vite middleware in development
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: 'spa',
    });
    app.use(vite.middlewares);
  } else {
    // Serve production static assets
    const distPath = path.resolve(__dirname, 'dist');
    app.use(express.static(distPath));
    app.get('*', (req, res) => {
      res.sendFile(path.resolve(distPath, 'index.html'));
    });
  }

  // Graceful server startup with automatic port fallback if occupied
  function tryListen(port: number, fallbackPort?: number) {
    const server = app.listen(port, '0.0.0.0', () => {
      console.log(`====================================================`);
      console.log(`🩸 LIFEDROP Blood Bank Management System Server`);
      console.log(`🌐 Server running at: http://localhost:${port}`);
      console.log(`====================================================`);
    });

    server.on('error', (err: any) => {
      if (err.code === 'EADDRINUSE' && fallbackPort && fallbackPort !== port) {
        console.warn(`[PORT NOTICE] Port ${port} is currently in use on your machine.`);
        console.warn(`[PORT NOTICE] Automatically switching to backup port: http://localhost:${fallbackPort}...`);
        tryListen(fallbackPort);
      } else {
        console.error('[FATAL SERVER ERROR]', err);
        process.exit(1);
      }
    });
  }

  tryListen(preferredPort, preferredPort === 5000 ? 3000 : 5000);
}

startServer().catch((err) => {
  console.error('[LIFEDROP FATAL] Failed to start server:', err);
  process.exit(1);
});
