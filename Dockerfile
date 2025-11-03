# ---------- BUILD STAGE ----------
FROM node:20-alpine AS builder
WORKDIR /app

# copy whole repo package files first for caching (optional)
COPY package*.json ./
# install top-level deps if you have root-level scripts (optional)
# RUN npm ci

# Install frontend deps and build frontend
COPY frontend/package*.json frontend/
RUN npm ci --prefix frontend
COPY frontend/ frontend/
RUN npm run build --prefix frontend

# Install backend deps
COPY backend/package*.json backend/
RUN npm ci --prefix backend --production

# Copy backend source (so backend/src etc exists)
COPY backend/ backend/

# ---------- RUNTIME STAGE ----------
FROM node:20-alpine AS runner
WORKDIR /app

# copy backend code & node_modules from builder
COPY --from=builder /app/backend/ /app/

# copy the built frontend dist into backend/frontend/dist
COPY --from=builder /app/frontend/dist /app/frontend/dist

# set env defaults (override with real env at runtime)
ENV NODE_ENV=production
ENV PORT=5001

EXPOSE 5001

# start command (change if your start script differs)
CMD ["node", "src/server.js"]
