FROM node:24-bookworm-slim
ENV NODE_ENV=production
WORKDIR /app
COPY services/payment-service/package.json services/payment-service/package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund
COPY --chown=node:node services/payment-service/src ./src
COPY --chown=node:node services/payment-service/openapi.yaml ./openapi.yaml
COPY --chown=node:node deployment/healthcheck.js ./healthcheck.js
USER node
EXPOSE 3004
HEALTHCHECK --interval=10s --timeout=5s --start-period=45s --retries=12 CMD ["node", "healthcheck.js"]
CMD ["node", "src/index.js"]
