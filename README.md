# Hacky Pizza POS

## Backend deployment

The backend service is located in `backend/`.

- `backend/package.json` defines the backend package and start script.
- `backend/src/server.js` is the Express server entrypoint.
- `backend/.env.example` shows the environment variables required for MongoDB and JWT secrets.

### Local run

1. Open a terminal in `backend/`
2. Run `npm install`
3. Create a `.env` file using `backend/.env.example`
4. Set `MONGODB_URI` to your MongoDB Atlas connection string
5. Run `npm start`

If `MONGODB_URI` is empty, the backend will start without connecting to MongoDB.

### Render setup

Use `render.yaml` in the root to configure Render with:

- `root: backend`
- `buildCommand: npm install`
- `startCommand: npm start`

On Render, set these environment variables in the service settings:

- `MONGODB_URI`
- `JWT_SECRET`
- `JWT_REFRESH_SECRET`

Do not commit real secrets or `.env` files to GitHub.
