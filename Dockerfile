# -----------------------------------------------------------------------------
# This Dockerfile.bun is specifically configured for projects using Bun
# For npm/pnpm or yarn, refer to the Dockerfile instead
# -----------------------------------------------------------------------------

# Use Bun's official image
FROM oven/bun:1 AS base

# Use /src/app for build stage
WORKDIR /src/app

# Install dependencies with bun
FROM base AS deps
COPY package.json bun.lock* ./
# Note: For many environments, this still creates a Node.js-compatible node_modules
# Bun is generally compatible with Next.js dependencies
RUN bun install --no-save --frozen-lockfile

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /src/app
COPY --from=deps /src/app/node_modules ./node_modules
COPY . .

# Run the build. Next.js creates the standalone server bundle here.
RUN --mount=type=secret,id=TELEGRAM_BOT_TOKEN \
    --mount=type=secret,id=BETTER_AUTH_SECRET \
    --mount=type=secret,id=BETTER_AUTH_URL \
    --mount=type=secret,id=DATABASE_URL \
    --mount=type=secret,id=GOOGLE_CLIENT_ID \
    --mount=type=secret,id=GOOGLE_CLIENT_SECRET \
    /bin/sh -lc '\
      export TELEGRAM_BOT_TOKEN="$(cat /run/secrets/TELEGRAM_BOT_TOKEN)" && \
      export BETTER_AUTH_SECRET="$(cat /run/secrets/BETTER_AUTH_SECRET)" && \
      export BETTER_AUTH_URL="$(cat /run/secrets/BETTER_AUTH_URL)" && \
      export DATABASE_URL="$(cat /run/secrets/DATABASE_URL)" && \
      export GOOGLE_CLIENT_ID="$(cat /run/secrets/GOOGLE_CLIENT_ID)" && \
      export GOOGLE_CLIENT_SECRET="$(cat /run/secrets/GOOGLE_CLIENT_SECRET)" && \
      bun run build'

# Production image, copy all the files and run next
FROM base AS runner
# Use /app for the final deployment stage
WORKDIR /app

# Uncomment the following line in case you want to disable telemetry during runtime.
# ENV NEXT_TELEMETRY_DISABLED=1

ENV NODE_ENV=production \
    PORT=3025 \
    HOSTNAME="0.0.0.0"

# Setup the non-root user (good practice)
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# COPY commands are now fixed to use /src/app/ path from the builder stage
COPY --from=builder /src/app/public ./public 

# Automatically leverage output traces to reduce image size
# Copy the entire standalone server output into the /app root
# Copy the standalone Next.js server build (for src/ architecture)
COPY --from=builder /src/app/.next/standalone ./
# Copy the static assets
COPY --from=builder /src/app/.next/static ./.next/static

USER nextjs

EXPOSE 3025

# FIX: When using standalone mode, you must run the generated server.js file directly
# instead of relying on the 'next' CLI.
CMD ["node", "server.js"]