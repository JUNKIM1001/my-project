# リリース前チェックリスト（おまいりナビ）

## A. アプリ側（このリポジトリ・私が対応可）
- [x] バージョン 1.0.0 / ビルド番号設定（project.yml）
- [x] 位置情報の用途説明（Info.plist: NSLocationWhenInUseUsageDescription）
- [x] 免責事項 画面（DisclaimerView）
- [x] ライセンス・出典（謝辞）画面（AcknowledgementsView）＋写真の帰属表示
- [x] アプリアイコン（オリジナル鳥居）
- [ ] アプリアイコンの最終ブラッシュアップ（任意・任せられたら対応）
- [ ] ダークモードの最終目視確認
- [ ] iPadは対象外（TARGETED_DEVICE_FAMILY=1=iPhoneのみ）で問題ないか確認

## B. Apple Developer / 署名（ユーザー作業・代行不可）
- [ ] Apple Developer Program 登録（年¥12,800）
- [ ] Xcodeで Signing & Capabilities → Team を選択（自動署名）
- [ ] 実機（実iPhone）での動作確認：位置情報許可、地図、経路案内、外部リンク、写真読み込み
- [ ] Product → Archive → Distribute App → App Store Connect へアップロード

## C. App Store Connect（ユーザー作業）
- [ ] App を新規作成（バンドルID: com.omairi.shrinefinder）
- [ ] App名・サブタイトル・説明・キーワード・カテゴリ入力（release/APP_STORE_METADATA.md）
- [ ] スクリーンショット登録（6.7"/6.5"）
- [ ] App プライバシー＝「データは収集されません」で回答
- [ ] プライバシーポリシーURL・サポートURL を設定（release/PRIVACY_POLICY.md を掲載）
- [ ] 価格＝無料、配信地域＝日本（必要に応じ拡大）
- [ ] 審査へ提出

## D. 提出時に審査で見られやすい点（対策済みの確認）
- [x] 第三者写真は自由ライセンスのみ＋帰属表示（CC BY-SA等）→ Acknowledgements で明示
- [x] 宗教的効果を断定しない旨の注記（免責事項）
- [x] 位置情報の用途が明確
- [ ] 「最低限の機能」以上の価値があること（願い事検索・地図・図鑑で充足）

## メモ
- サポートURL/問い合わせ先メールは必須。GitHub Pages 等で1ページ用意すると早い。
- 写真は実行時にWikimediaから読み込むため、オフライン時は社寺によりシンボル図表示になる（仕様）。
