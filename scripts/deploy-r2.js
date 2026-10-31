/**
 * Lucky Spin Casino - R2 部署脚本
 * 将静态文件上传到 Cloudflare R2 存储桶
 *
 * 前置要求:
 *   npm install @aws-sdk/client-s3 @aws-sdk/s3-request-presigner
 *
 * 环境变量（部署前请设置）:
 *   R2_ACCESS_KEY_ID      - R2 S3 兼容 Access Key ID
 *   R2_SECRET_ACCESS_KEY  - R2 S3 兼容 Secret Access Key
 *   R2_ENDPOINT           - 例如 https://<ACCOUNT_ID>.r2.cloudflarestorage.com
 *   R2_BUCKET_NAME        - R2 存储桶名称
 *   R2_PUBLIC_URL         - 可选，R2 绑定的自定义域或 r2.dev 域（用于生成 public URL 列表）
 *
 * 用法:
 *   node scripts/deploy-r2.js
 */

import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { readFileSync, readdirSync, statSync, createReadStream } from "node:fs";
import { join, relative, extname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = typeof globalThis !== "undefined" && globalThis.__dirname
  ? globalThis.__dirname
  : fileURLToPath(new URL(".", import.meta.url));

const LOCAL_DIR = process.env.R2_LOCAL_DIR || join(__dirname, "..");
const BUCKET = process.env.R2_BUCKET_NAME || "lucky-spin-casino";
const ENDPOINT = process.env.R2_ENDPOINT || "";
const ACCESS_KEY = process.env.R2_ACCESS_KEY_ID || "";
const SECRET_KEY = process.env.R2_SECRET_ACCESS_KEY || "";
const PUBLIC_URL = process.env.R2_PUBLIC_URL || "";

// Content-Type 映射
const CONTENT_TYPES = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".json": "application/json",
  ".xml": "application/xml",
  ".txt": "text/plain; charset=utf-8",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
  ".webp": "image/webp",
  ".woff2": "font/woff2",
  ".woff": "font/woff",
  ".ttf": "font/ttf",
};

// 默认缓存策略（按文件类型）
const CACHE_CONTROL = {
  ".html": "public, max-age=0, must-revalidate",
  ".css": "public, max-age=31536000, immutable",
  ".js": "public, max-age=31536000, immutable",
  ".json": "public, max-age=31536000, immutable",
  ".xml": "public, max-age=86400, must-revalidate",
  ".txt": "public, max-age=86400, must-revalidate",
  ".png": "public, max-age=31536000, immutable",
  ".jpg": "public, max-age=31536000, immutable",
  ".jpeg": "public, max-age=31536000, immutable",
  ".svg": "public, max-age=31536000, immutable",
  ".ico": "public, max-age=31536000, immutable",
  ".webp": "public, max-age=31536000, immutable",
  ".woff2": "public, max-age=31536000, immutable",
  ".woff": "public, max-age=31536000, immutable",
  ".ttf": "public, max-age=31536000, immutable",
};

function getContentType(ext) {
  return CONTENT_TYPES[ext.toLowerCase()] || "application/octet-stream";
}

function getCacheControl(ext) {
  return CACHE_CONTROL[ext.toLowerCase()] || "public, max-age=3600, must-revalidate";
}

// 递归收集所有文件（排除 node_modules、.git、scripts 自身）
function collectFiles(dir, results = []) {
  const entries = readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = join(dir, entry.name);
    if (entry.isDirectory()) {
      if (["node_modules", ".git", ".vite", "dist", "build"].includes(entry.name)) continue;
      collectFiles(fullPath, results);
    } else {
      results.push(fullPath);
    }
  }
  return results;
}

async function main() {
  if (!ACCESS_KEY || !SECRET_KEY || !ENDPOINT || !BUCKET) {
    console.error("❌ 缺少必要环境变量，请设置:");
    console.error("   R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY, R2_ENDPOINT, R2_BUCKET_NAME");
    process.exit(1);
  }

  const client = new S3Client({
    endpoint: ENDPOINT,
    region: "auto", // R2 固定使用 "auto"
    credentials: {
      accessKeyId: ACCESS_KEY,
      secretAccessKey: SECRET_KEY,
    },
    // 强制使用路径风格 URL（R2 要求）
    forcePathStyle: true,
  });

  const files = collectFiles(LOCAL_DIR);
  console.log(`📦 发现 ${files.length} 个文件，准备上传到 R2 存储桶: ${BUCKET}`);

  let success = 0;
  let failed = 0;

  for (const filePath of files) {
    // 跳过脚本自身
    if (filePath.includes("/scripts/") && filePath.endsWith("deploy-r2.js")) continue;

    const relPath = relative(LOCAL_DIR, filePath).split("\\").join("/");
    const ext = extname(filePath);
    const contentType = getContentType(ext);
    const cacheControl = getCacheControl(ext);

    try {
      const fileBuffer = readFileSync(filePath);

      await client.send(
        new PutObjectCommand({
          Bucket: BUCKET,
          Key: relPath,
          Body: fileBuffer,
          ContentType: contentType,
          CacheControl: cacheControl,
        })
      );

      const publicUrl = PUBLIC_URL ? `${PUBLIC_URL.replace(/\/$/, "")}/${relPath}` : relPath;
      console.log(`✅ ${relPath}  -> ${publicUrl}`);
      success++;
    } catch (err) {
      console.error(`❌ 上传失败 ${relPath}:`, err.message);
      failed++;
    }
  }

  console.log(`\n🎉 上传完成: 成功 ${success}, 失败 ${failed}`);

  if (failed > 0) {
    process.exit(1);
  }

  console.log("\n🔗 下一步:");
  console.log("   1. 在 Cloudflare 控制台将 R2 存储桶设为公共读取（Public Bucket Access）");
  console.log("   2. 绑定自定义域名（Custom Domains）或使用 <bucket>.r2.dev");
  console.log("   3. 确保 index.html 为存储桶的索引文件（Index Document）");
}

main().catch((err) => {
  console.error("脚本异常:", err);
  process.exit(1);
});