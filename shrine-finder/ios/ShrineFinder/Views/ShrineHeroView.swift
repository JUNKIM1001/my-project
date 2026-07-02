import SwiftUI

/// 社寺のヒーロー画像。優先順: ①同梱CC0/PD写真 → ②Wikipedia自由ライセンス実写(実行時読込) → ③シンボルアート。
struct ShrineHeroView: View {
    @EnvironmentObject var store: DataStore
    let shrine: Shrine
    var showsCredit: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let img = store.photo(for: shrine) {
                Image(uiImage: img).resizable().scaledToFill()
                    .accessibilityLabel("\(shrine.name)の写真")
                creditLabel(store.photoCredit(for: shrine))
            } else if let url = shrine.photoURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                            .accessibilityLabel("\(shrine.name)の写真")
                    case .empty:
                        ZStack { ShrineMotifView(shrine: shrine); ProgressView().tint(.white) }
                    case .failure:
                        ShrineMotifView(shrine: shrine)
                    @unknown default:
                        ShrineMotifView(shrine: shrine)
                    }
                }
                creditLabel(shrine.imageCredit)
            } else {
                ShrineMotifView(shrine: shrine)
            }
        }
        .clipped()
    }

    @ViewBuilder
    private func creditLabel(_ text: String?) -> some View {
        if showsCredit, let text {
            Text(text)
                .font(.caption2)
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background(.black.opacity(0.38))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .padding(6)
        }
    }
}
