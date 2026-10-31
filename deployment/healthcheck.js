// Strict readiness: a 200 DEGRADED response is not considered fully ready.
async function main() {
  const response = await fetch(`http://127.0.0.1:${process.env.PORT}/health`, {
    signal: AbortSignal.timeout(3000),
  });
  const body = await response.json();
  process.exit(response.ok && body.status === 'UP' ? 0 : 1);
}
main().catch(() => process.exit(1));
