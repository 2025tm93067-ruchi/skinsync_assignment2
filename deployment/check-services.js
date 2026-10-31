const { URLS } = require('../scripts/lib/common');

async function main() {
  let failed = false;
  for (const [name, url] of Object.entries(URLS)) {
    try {
      const response = await fetch(`${url}/health`, { signal: AbortSignal.timeout(5000) });
      const body = await response.json();
      console.log(name, JSON.stringify(body));
      if (!response.ok || body.status !== 'UP') failed = true;
    } catch (error) {
      console.error(`${name}: ${error.message}`);
      failed = true;
    }
  }
  process.exit(failed ? 1 : 0);
}
main().catch((error) => { console.error(error.message); process.exit(1); });
