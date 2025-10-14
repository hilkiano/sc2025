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

# Declare build-time args
ARG TELEGRAM_BOT_TOKEN
ARG BETTER_AUTH_SECRET
ARG BETTER_AUTH_URL
ARG DATABASE_URL
ARG GOOGLE_CLIENT_ID
ARG GOOGLE_CLIENT_SECRET

# Make them available as runtime ENV
ENV TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
ENV BETTER_AUTH_SECRET=$BETTER_AUTH_SECRET
ENV BETTER_AUTH_URL=$BETTER_AUTH_URL
ENV DATABASE_URL=$DATABASE_URL
ENV GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID
ENV GOOGLE_CLIENT_SECRET=$GOOGLE_CLIENT_SECRET

# Run the build. Next.js creates the standalone server bundle here.
RUN bun run build

# Production image, copy all the files and run next
FROM base AS runner
# Use /app for the final deployment stage
WORKDIR /app

# Uncomment the following line in case you want to disable telemetry during runtime.
# ENV NEXT_TELEMETRY_DISABLED=1

ENV NODE_ENV=production \
    PORT=3000 \
    HOSTNAME="0.0.0.0"

# Setup the non-root user (good practice)
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# COPY commands are now fixed to use /src/app/ path from the builder stage
COPY --from=builder /src/app/public ./public 

# Automatically leverage output traces to reduce image size
# Copy the entire standalone server output into the /app root
COPY --from=builder --chown=nextjs:nodejs /src/app/.next/standalone ./
# Copy static assets
COPY --from=builder --chown=nextjs:nodejs /src/app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

# FIX: When using standalone mode, you must run the generated server.js file directly
# instead of relying on the 'next' CLI.
CMD ["node", "server.js"]