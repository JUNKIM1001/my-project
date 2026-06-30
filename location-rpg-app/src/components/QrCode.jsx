import { useEffect, useRef } from 'react'
import QRCode from 'qrcode'

export default function QrCode({ value, size = 200 }) {
  const canvasRef = useRef(null)

  useEffect(() => {
    if (canvasRef.current) {
      QRCode.toCanvas(canvasRef.current, value, { width: size }, () => {})
    }
  }, [value, size])

  return <canvas ref={canvasRef} />
}
