import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.svg'],
      workbox: {
        // appdata.json / appdata-details.json も precache してオフライン閲覧を可能に
        globPatterns: ['**/*.{js,css,html,svg,json,webmanifest}'],
        maximumFileSizeToCacheInBytes: 3 * 1024 * 1024,
      },
      manifest: {
        name: 'おまいりナビ',
        short_name: 'おまいりナビ',
        description: '願い事と現在地から、最適な神社・お寺と神仏が見つかるアプリ。',
        lang: 'ja',
        display: 'standalone',
        theme_color: '#bf3830',
        background_color: '#ffffff',
        icons: [
          { src: 'favicon.svg', sizes: 'any', type: 'image/svg+xml', purpose: 'any' },
        ],
      },
    }),
  ],
  server: { host: true },
})
