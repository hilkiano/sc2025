FROM oven/bun:1 AS base
WORKDIR /src/app

# Variables for both build and run stages
ARG APP_ENV=production
ENV NODE_ENV=production
ENV APP_ENV=${APP_ENV}

FROM base AS deps
COPY package.json bun.lock* ./
# Install dependencies
RUN bun install --no-save --frozen-lockfile

FROM base AS builder
WORKDIR /src/app

# --- START BUILD-TIME SECRET INJECTION FIX (Modified for Local Dev) ---
# Define build arguments for all secrets required by Next.js during `bun run build`.
# IMPORTANT: Added default values (e.g., DUMMY_...) to prevent local `docker build`
# or `docker compose build` from breaking when ARGs are not supplied.
ARG TELEGRAM_BOT_TOKEN=DUMMY_TOKEN
ARG BETTER_AUTH_SECRET=DUMMY_SECRET_FOR_BUILD
ARG BETTER_AUTH_URL=http://localhost:3000
ARG DATABASE_URL=postgresql://user:pass@host:5432/db-dummy
ARG GOOGLE_CLIENT_ID=DUMMY_CLIENT_ID
ARG GOOGLE_CLIENT_SECRET=DUMMY_CLIENT_SECRET

# Set the environment variables so they are available to bun run build.
# These will use the ARG value (real secret from CI, or DUMMY from local build).
ENV TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
ENV BETTER_AUTH_SECRET=${BETTER_AUTH_SECRET}
ENV BETTER_AUTH_URL=${BETTER_AUTH_URL}
ENV DATABASE_URL=${DATABASE_URL}
ENV GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID}
ENV GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET}
# --- END BUILD-TIME SECRET INJECTION FIX ---

COPY --from=deps /src/app/node_modules ./node_modules
COPY . .

# Run the build command
RUN bun run build

FROM base AS runner
WORKDIR /app

# Variables for the runner stage (these should include all runtime secrets)
ARG APP_ENV=production
# Redefine ARGs for runner stage (no defaults needed here, as they carry over from the build or are explicitly set at run time)
ARG TELEGRAM_BOT_TOKEN
ARG BETTER_AUTH_SECRET
ARG BETTER_AUTH_URL
ARG DATABASE_URL
ARG GOOGLE_CLIENT_ID
ARG GOOGLE_CLIENT_SECRET

ENV NODE_ENV=production
ENV APP_ENV=${APP_ENV}
ENV PORT=3025 \
    HOSTNAME="0.0.0.0"

# Set runtime environment variables using the ARGs passed during the build or at run time.
# For production, these values will be overridden by runtime ENV variables (e.g., in Docker Compose, Kubernetes, or GitHub Actions deployment).
ENV TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
ENV BETTER_AUTH_SECRET=${BETTER_AUTH_SECRET}
ENV BETTER_AUTH_URL=${BETTER_AUTH_URL}
ENV DATABASE_URL=${DATABASE_URL}
ENV GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID}
ENV GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET}

# Create non-root user for security
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy Next.js artifacts
COPY --from=builder /src/app/public ./public
COPY --from=builder --chown=nextjs:nodejs /src/app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /src/app/.next/static ./.next/static

USER nextjs
EXPOSE 3025

CMD ["node", "server.js"]
