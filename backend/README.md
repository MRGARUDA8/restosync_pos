# Hacky Pizza POS Backend

This backend provides a Node.js/Express foundation for Hacky Pizza POS with MongoDB Atlas sync and Socket.IO order updates.

## Setup

1. Copy `.env.example` to `.env`.
2. Set `MONGO_URI` and `PORT`.
   - Use the exact Atlas URI without angle brackets, for example:
     `mongodb+srv://spinadmin:AmanAmanKumar@cluster0.uabkidw.mongodb.net/restosync?retryWrites=true&w=majority&appName=Cluster0`
   - Do not use `<` or `>` around the password.
   - If your password includes special characters, URL-encode them before pasting into `MONGO_URI`.
3. Install dependencies with `npm install`.
4. Start the backend with `npm start`.

## API

- `GET /health` - health check
- `POST /sync/invoices` - sync invoice payload from POS clients
- `GET /sync/status` - check sync readiness

## Real-Time

- Socket.IO namespace broadcasts `order_update` events to connected clients.
