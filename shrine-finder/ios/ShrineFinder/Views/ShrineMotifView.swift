import SwiftUI

/// 社寺の象徴ビジュアル（当方オリジナルの生成アート・著作権フリー）。
/// 神社は鳥居、寺院は五重塔のシルエットを色グラデーション上に描く。
/// ※外部の実写は著作権配慮のため使用しない。
struct ShrineMotifView: View {
    let shrine: Shrine

    var body: some View {
        ZStack {
            LinearGradient(colors: palette, startPoint: .topLeading, endPoint: .bottomTrailing)
            Canvas { ctx, size in
                if shrine.isShrine { drawTorii(&ctx, size) } else { drawPagoda(&ctx, size) }
            }
            // 山並みのうっすらしたシルエット
            Canvas { ctx, size in
                var p = Path()
                p.move(to: CGPoint(x: 0, y: size.height))
                p.addLine(to: CGPoint(x: 0, y: size.height * 0.82))
                p.addQuadCurve(to: CGPoint(x: size.width * 0.5, y: size.height * 0.9),
                               control: CGPoint(x: size.width * 0.25, y: size.height * 0.72))
                p.addQuadCurve(to: CGPoint(x: size.width, y: size.height * 0.85),
                               control: CGPoint(x: size.width * 0.78, y: size.height * 0.74))
                p.addLine(to: CGPoint(x: size.width, y: size.height))
                p.closeSubpath()
                ctx.fill(p, with: .color(.white.opacity(0.12)))
            }
        }
        .clipped()
    }

    private var palette: [Color] {
        if shrine.isShrine {
            return [toriiRed, Color(red: 0.88, green: 0.48, blue: 0.28)]
        } else {
            return [Color(red: 0.24, green: 0.33, blue: 0.55), Color(red: 0.15, green: 0.45, blue: 0.55)]
        }
    }

    private func drawTorii(_ ctx: inout GraphicsContext, _ s: CGSize) {
        let w = s.width, h = s.height
        let ink = GraphicsContext.Shading.color(.white.opacity(0.95))
        let pillarW = w * 0.045
        let top = h * 0.30, base = h * 0.82
        let lx = w * 0.34, rx = w * 0.66
        for x in [lx, rx] {
            ctx.fill(Path(CGRect(x: x - pillarW/2, y: top, width: pillarW, height: base - top)), with: ink)
        }
        // 笠木（上の横木・両端が反る）
        var kasagi = Path()
        let ky = h * 0.24
        kasagi.move(to: CGPoint(x: w * 0.18, y: ky + h*0.02))
        kasagi.addQuadCurve(to: CGPoint(x: w * 0.82, y: ky + h*0.02), control: CGPoint(x: w*0.5, y: ky - h*0.02))
        kasagi.addLine(to: CGPoint(x: w * 0.82, y: ky + h*0.065))
        kasagi.addQuadCurve(to: CGPoint(x: w * 0.18, y: ky + h*0.065), control: CGPoint(x: w*0.5, y: ky + h*0.025))
        kasagi.closeSubpath()
        ctx.fill(kasagi, with: ink)
        // 貫（下の横木）
        ctx.fill(Path(CGRect(x: w*0.26, y: h*0.40, width: w*0.48, height: h*0.045)), with: ink)
    }

    private func drawPagoda(_ ctx: inout GraphicsContext, _ s: CGSize) {
        let w = s.width, h = s.height
        let ink = GraphicsContext.Shading.color(.white.opacity(0.95))
        let cx = w * 0.5
        // 3層の屋根（上から）
        let roofs: [(y: CGFloat, half: CGFloat)] = [
            (h*0.30, w*0.16), (h*0.45, w*0.22), (h*0.60, w*0.28)
        ]
        for r in roofs {
            var p = Path()
            p.move(to: CGPoint(x: cx - r.half, y: r.y + h*0.06))
            p.addQuadCurve(to: CGPoint(x: cx, y: r.y), control: CGPoint(x: cx - r.half*0.4, y: r.y))
            p.addQuadCurve(to: CGPoint(x: cx + r.half, y: r.y + h*0.06), control: CGPoint(x: cx + r.half*0.4, y: r.y))
            p.closeSubpath()
            ctx.fill(p, with: ink)
        }
        // 相輪（てっぺん）
        ctx.fill(Path(CGRect(x: cx - w*0.008, y: h*0.20, width: w*0.016, height: h*0.10)), with: ink)
        // 軸部
        ctx.fill(Path(CGRect(x: cx - w*0.05, y: h*0.66, width: w*0.10, height: h*0.16)), with: ink)
    }
}
