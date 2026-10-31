FROM node:24-bookworm-slim
ENV NODE_ENV=production
WORKDIR /app
COPY services/quiz-service/package.json services/quiz-service/package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund
COPY --chown=node:node services/quiz-service/src ./src
COPY --chown=node:node services/quiz-service/openapi.yaml ./openapi.yaml
COPY --chown=node:node deployment/healthcheck.js ./healthcheck.js
USER node
EXPOSE 3002
HEALTHCHECK --interval=10s --timeout=5s --start-period=45s --retries=12 CMD ["node", "healthcheck.js"]
CMD ["node", "src/index.js"]
