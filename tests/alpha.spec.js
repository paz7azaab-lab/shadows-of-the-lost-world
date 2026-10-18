const { test, expect } = require('@playwright/test');

test.beforeEach(async ({ page }) => {
  await page.goto('/');
  await page.locator('#start').click();
  await expect(page.locator('#intro')).toHaveClass(/hide/);
});

test('3D canvas and survival HUD start', async ({ page }) => {
  await expect(page.locator('canvas')).toBeVisible();
  await expect(page.locator('#hp')).toHaveText('100');
  await expect(page.locator('#hg')).toHaveText('100');
  await expect(page.locator('#objective')).toContainText('0/3');
});

test('resource gathering and campfire crafting update game state', async ({ page }) => {
  const result = await page.evaluate(() => {
    const g = window.gameDebug;
    g.S.wood = 5; g.S.stone = 3; g.S.hunger = 60;
    g.interact();
    return { fire: g.S.fire, wood: g.S.wood, stone: g.S.stone, hunger: g.S.hunger };
  });
  expect(result.fire).toBe(true);
  expect(result.wood).toBe(0);
  expect(result.stone).toBe(0);
  expect(result.hunger).toBe(95);
});

test('all three shards complete the main objective', async ({ page }) => {
  const result = await page.evaluate(() => {
    const g = window.gameDebug;
    for (const d of g.drops) {
      if (d.type === 'shard' && d.active) {
        g.player.position.copy(d.g.position);
        g.interact();
      }
    }
    return { shards: g.S.shards, objective: document.querySelector('#objective').textContent };
  });
  expect(result.shards).toBe(3);
  expect(result.objective).toContain('ALL SHARDS FOUND');
});

test('keyboard movement changes player position', async ({ page }) => {
  const before = await page.evaluate(() => window.gameDebug.player.position.z);
  await page.keyboard.down('w');
  await page.waitForTimeout(300);
  await page.keyboard.up('w');
  const after = await page.evaluate(() => window.gameDebug.player.position.z);
  expect(after).toBeLessThan(before);
});

test('mobile controls fit a phone viewport', async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await expect(page.locator('[data-k="w"]')).toBeVisible();
  await expect(page.locator('#act')).toBeVisible();
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
});
