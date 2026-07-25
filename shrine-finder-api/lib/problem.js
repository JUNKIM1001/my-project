// RFC 9457 Problem Details 形式のエラー応答（API_SPEC §4）
const BASE = 'https://api.omairi-navi.app/errors/'

export function problem(res, { code, status, title, detail, instance }) {
  res.statusCode = status
  res.setHeader('Content-Type', 'application/problem+json; charset=utf-8')
  res.setHeader('Cache-Control', 'no-store')
  res.end(
    JSON.stringify({
      type: BASE + code,
      title,
      status,
      ...(detail ? { detail } : {}),
      ...(instance ? { instance } : {}),
    })
  )
}

export const badRequest = (res, detail, instance) =>
  problem(res, { code: 'invalid-parameter', status: 400, title: 'パラメータが不正です', detail, instance })

export const notFound = (res, detail, instance) =>
  problem(res, { code: 'not-found', status: 404, title: '対象が見つかりません', detail, instance })

export const serverError = (res, instance) =>
  problem(res, { code: 'internal', status: 500, title: 'サーバ内部エラー', instance })
