import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const rootDir = resolve(__dirname, "..");
const outputPath = resolve(rootDir, "data", "aluminum.json");
const yahooUrl = "https://query1.finance.yahoo.com/v8/finance/chart/ALI=F?range=6mo&interval=1d";

async function readExistingData() {
  try {
    return JSON.parse(await readFile(outputPath, "utf8"));
  } catch {
    return null;
  }
}

function buildData(payload) {
  const result = payload?.chart?.result?.[0];
  const timestamps = result?.timestamp || [];
  const closes = result?.indicators?.quote?.[0]?.close || [];
  const history = [];

  timestamps.forEach((timestamp, index) => {
    const priceUsdPerMetricTon = Number(closes[index]);
    if (!Number.isFinite(priceUsdPerMetricTon) || priceUsdPerMetricTon <= 0) return;

    history.push({
      date: new Date(timestamp * 1000).toISOString().slice(0, 10),
      priceUsdPerMetricTon: Number(priceUsdPerMetricTon.toFixed(4)),
      priceUsdPerKg: Number((priceUsdPerMetricTon / 1000).toFixed(6))
    });
  });

  if (history.length < 2) {
    throw new Error("Yahoo Finance returned too few ALI=F data points");
  }

  const latest = history[history.length - 1];

  return {
    updatedAt: new Date().toISOString(),
    source: "Yahoo Finance ALI=F / COMEX Aluminum Futures",
    unit: "USD per metric ton, converted to USD per kg",
    priceUsdPerMetricTon: latest.priceUsdPerMetricTon,
    priceUsdPerKg: latest.priceUsdPerKg,
    history
  };
}

async function main() {
  await mkdir(dirname(outputPath), { recursive: true });

  try {
    const response = await fetch(yahooUrl, {
      headers: {
        "User-Agent": "tal13-github-pages-updater/1.0"
      }
    });

    if (!response.ok) {
      throw new Error(`Yahoo Finance request failed: ${response.status}`);
    }

    const data = buildData(await response.json());
    await writeFile(outputPath, `${JSON.stringify(data, null, 2)}\n`, "utf8");
    console.log(`Updated ${outputPath}`);
  } catch (error) {
    const existing = await readExistingData();
    if (existing) {
      console.warn(`Keeping existing aluminum data: ${error.message}`);
      return;
    }

    throw error;
  }
}

main();
