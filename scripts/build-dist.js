#!/usr/bin/env node
/**
 * Build the static dist/ directory for Cloudflare Pages.
 * Copies only public assets; excludes docs, scripts, and build tooling.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(__dirname, "..");
const dist = path.join(root, "dist");
const files = ["index.html", "404.html", "manifest.json", "robots.txt", "sitemap.xml", "_headers"];
const dirs = ["css", "js", "img"];

fs.rmSync(dist, { recursive: true, force: true });
fs.mkdirSync(dist, { recursive: true });

for (const file of files) {
  const src = path.join(root, file);
  if (fs.existsSync(src)) {
    fs.copyFileSync(src, path.join(dist, file));
  }
}

for (const dir of dirs) {
  const src = path.join(root, dir);
  if (fs.existsSync(src)) {
    fs.cpSync(src, path.join(dist, dir), { recursive: true });
  }
}

console.log("Built dist/ successfully");
