Deploying Hacky Pizza POS backend to Render

This document explains the minimal steps and environment variables to deploy the backend on Render (https://render.com) using MongoDB Atlas.

1. Prepare MongoDB Atlas
- Create a free/paid cluster on MongoDB Atlas.
- Create a database user and copy the connection string (example):
  mongodb+srv://<user>:<password>@cluster0.xxxxx.mongodb.net/hacky_pizza_pos?retryWrites=true&w=majority
- Whitelist Render outgoing IPs or set `Network Access` to allow all (for quick testing).

2. Create a new Web Service on Render
- Repository: connect this repository and select the `backend/` directory as the base.
- Environment: choose Node (starts from package.json). Render will run `npm start` by default.
- Build command: (leave empty) — server runs as Node app.
- Start command: npm start
- Instance type: Select as required (free plan or paid).

3. Important environment variables (set in Render dashboard > Environment)
- MONGO_URI = mongodb+srv://<user>:<password>@.../hacky_pizza_pos?retryWrites=true&w=majority
- FRONTEND_URL = https://your-frontend-domain.example (optional; defaults to '*')
- NODE_ENV = production

4. Health checks & readiness
- The app exposes /health which returns JSON { status: 'ok', name: 'Hacky Pizza POS Backend' }.
- Configure Render health check to point to /health (optional).

5. Socket.IO / Real-time
- The backend serves Socket.IO on the same origin as the web service. When using the frontend hosted on a different host, set FRONTEND_URL to your frontend URL so CORS allows socket connections.

6. Logs and debugging
- Check Render logs via the Render dashboard. The service prints connection and request logs.

Notes:
- This backend uses environment variables for credentials and binds to process.env.PORT recommended by Render.
- If you need help wiring the frontend to point to the deployed backend, provide the frontend domain and I can update the frontend API base URL and Socket.IO connection defaults.
