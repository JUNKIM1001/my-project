// ローカル検証用サーバ（Vercelのルーティングを模す）。
//   node scripts/dev-server.mjs [port]
// 本番は Vercel Functions が同じハンドラを呼ぶ。
import { createServer } from 'node:http'

const routes = [
  [/^\/v1\/shrines\/[^/]+$/, () => import('../api/v1/shrines/[id].js')],
  [/^\/v1\/shrines\/?$/, () => import('../api/v1/shrines/index.js')],
  [/^\/v1\/areas\/?$/, () => import('../api/v1/areas.js')],
  [/^\/v1\/goriyaku\/?$/, () => import('../api/v1/goriyaku.js')],
  [/^\/(v1\/meta\/?)?$/, () => import('../api/v1/meta.js')],
]

const port = Number(process.argv[2] || 8787)

createServer(async (req, res) => {
  const path = new URL(req.url, 'http://localhost').pathname
  const hit = routes.find(([re]) => re.test(path))
  if (!hit) {
    res.statusCode = 404
    res.setHeader('Content-Type', 'application/problem+json')
    return res.end(JSON.stringify({ type: 'https://api.omairi-navi.app/errors/not-found', title: 'そのパスはありません', status: 404 }))
  }
  const mod = await hit[1]()
  await mod.default(req, res)
}).listen(port, () => console.log(`http://localhost:${port}/v1/shrines`))
