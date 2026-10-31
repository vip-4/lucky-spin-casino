// luckyspin-pages-proxy
// 将 luckyspin.vip01.cc.cd 的请求转发到 Cloudflare Pages 生产别名
// 用于绕开 *.vip01.cc.cd/* 通配 Worker 路由

const PAGES_ORIGIN = "https://lucky-spin-casino-6kd.pages.dev";

addEventListener("fetch", (event) => {
  event.respondWith(handleRequest(event.request));
});

async function handleRequest(request) {
  const url = new URL(request.url);
  const target = PAGES_ORIGIN + url.pathname + url.search;

  const init = {
    method: request.method,
    headers: request.headers,
    redirect: "manual",
  };
  if (request.method !== "GET" && request.method !== "HEAD") {
    init.body = request.body;
  }

  const response = await fetch(new Request(target, init));

  // 透传 Pages 的响应（含 CSP 等安全头），仅补充代理标识
  const headers = new Headers(response.headers);
  headers.set("X-Served-By", "lucky-spin-pages-proxy");

  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}
