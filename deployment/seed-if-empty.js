const { spawnSync } = require('node:child_process');
const { URLS, api } = require('../scripts/lib/common');

async function main() {
  const response = await api('GET', `${URLS.catalog}/api/v1/products`);
  if (response.status !== 200 || !Array.isArray(response.body.items)) {
    throw new Error('Could not read the product catalog before seeding');
  }
  if (response.body.items.length > 0) {
    console.log('Catalog already contains products; keeping existing stock and data.');
    return;
  }
  const result = spawnSync(process.execPath, ['scripts/seed.js'], { stdio: 'inherit' });
  if (result.status !== 0) process.exit(result.status || 1);
}
main().catch((error) => { console.error(error.message); process.exit(1); });
