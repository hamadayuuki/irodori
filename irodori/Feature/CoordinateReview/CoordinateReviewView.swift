//
//  CoordinateReviewView.swift
//  irodori
//
//  Created by 濵田　悠樹 on 2025/03/22.
//

import SwiftUI

struct CoordinateReviewView: View {
    let coordinateImage: UIImage
    let coordinateReview: CoordinateReview

    private let criterionShortText = 50
    @State private var reviewText = ""
    @State private var isShowFullReview = false
    @State private var tappedRecommendItem: RecommendItem? = nil

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 48) {
                Image(uiImage: coordinateImage)
                    .resizable()
                    .frame(width: 300/1.5, height: 400/1.5)   // WEARのコーデ画像サイズ をリサイズ
                    .scaledToFit()

                ReviewText()

                RecommendItems()
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            Task {
                let client: GPTClient = .init()
                reviewText = try await client.postImageToGPT(image: coordinateImage)
                print(reviewText)
                isShowFullReview = reviewText.count < criterionShortText
            }
        }
//        .sheet(item: $tappedRecommendItem) { tappedRecommendItem in
//            WebView(url: URL(string: tappedRecommendItem.itemURL))
//        }
        .onChange(of: tappedRecommendItem) {
            let url = URL(string: tappedRecommendItem!.itemURL)!   // TODO: エラーハンドリング
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func ReviewText() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AIからのコーデコメント")
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            // TODO: enumを使いステータスを表現する
            if !reviewText.isEmpty {
                if isShowFullReview {
                    Text("\(reviewText)")
                        .font(.system(size: 16, weight: .light))
                } else {
                    ZStack(alignment: .bottomTrailing) {
                        Text("\(reviewText.prefix(criterionShortText)) ...")
                            .font(.system(size: 16, weight: .light))
                        Button(action: {
                            isShowFullReview = true
                        }) {
                            Text("続きを見る")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundStyle(.blue)
                                .padding(.top, 26)
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
    }

    private func RecommendItems() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("おすすめアイテム")
                .font(.system(size: 20, weight: .bold))

            ForEach(coordinateReview.recommend, id: \.id) { recommend in
                Text("\(recommend.title)")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(recommend.recommendItems, id: \.id) { recommendItem in
                            Button(action: {
                                tappedRecommendItem = recommendItem
                            }) {
                                ItemCard(recommendItem: recommendItem)
                            }
                        }
                    }
                }
            }
        }
    }

    private func ItemCard(recommendItem: RecommendItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                AsyncImage(url: URL(string: recommendItem.imageURL)!) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 215/2, height: 258/2)   // ZOZOTOWN の商品画像サイズ をリサイズ
                .scaledToFill()
            }

            Text("\(recommendItem.company)")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.black)
                .padding(.top, -6)
            Text("¥\(recommendItem.price)")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)

        }
    }
}

#Preview {
    CoordinateReviewView(
        coordinateImage: UIImage(resource: .coordinate1),
        coordinateReview: .mock()
    )
}
