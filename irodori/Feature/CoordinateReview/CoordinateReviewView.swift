//
//  CoordinateReviewView.swift
//  irodori
//
//  Created by 濵田　悠樹 on 2025/03/22.
//

import SwiftUI

struct CoordinateReviewView: View {
    let coordinateImage: UIImage
    let fashionReview: FashionReviewResponse

    private let criterionShortText = 150
    @State private var currentSchedule = ""   // YYYY/MM/DD
    @State private var reviewText = ""
    @State private var isShowFullReview = false
    @State private var tappedURL = ""
    @State private var isPresentedCameraView = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 48) {
                CapturedImage()
                ItemsImage()
                ReviewText()
                CoordinateGraph()
                RecommendItems()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isPresentedCameraView = true
                }, label: {
                    Text("再撮影")
                })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 24)
//        .sheet(item: $tappedRecommendItem) { tappedRecommendItem in
//            WebView(url: URL(string: tappedRecommendItem.itemURL))
//        }
        .onChange(of: tappedURL) {
            let url = URL(string: tappedURL)!   // TODO: エラーハンドリング
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        .navigationDestination(isPresented: $isPresentedCameraView) {
            CameraView()
        }
    }

    private func CapturedImage() -> some View {
        VStack(spacing: 12) {
            Text("\(currentSchedule)")
                .font(.system(size: 16))
                .foregroundStyle(.gray)

            Image(uiImage: coordinateImage)
                .resizable()
                .frame(width: 360/1.8, height: 640/1.8)   // WEARのコーデ画像サイズ をリサイズ
                .scaledToFit()
        }
        .onAppear {
            // TODO: VM に移行
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            dateFormatter.locale = Locale(identifier: "ja_JP")
            let now = Date()
            currentSchedule = dateFormatter.string(from: now)
        }
    }

    private func ItemsImage() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日着用しているアイテム")
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 48) {
                VStack(spacing: 6) {
                    Text("トップス")
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)

                    AsyncImage(url: URL(string: fashionReview.tops_image_url)!) { image in
                        image
                            .resizable()
                            .frame(width: 120, height: 120)
                    } placeholder: {
                        ProgressView()
                    }
                }

                VStack(spacing: 6) {
                    Text("ボトムス")
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)

                    AsyncImage(url: URL(string: fashionReview.bottoms_image_url)!) { image in
                        image
                            .resizable()
                            .frame(width: 120, height: 120)
                    } placeholder: {
                        ProgressView()
                    }
                }
            }
        }
    }

    private func ReviewText() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AIからのコーデコメント")
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            if isShowFullReview {
                Text("\(fashionReview.coordinate.coordinate_review)")
                    .font(.system(size: 16, weight: .light))
            } else {
                ZStack(alignment: .bottomTrailing) {
                    Text("\(fashionReview.coordinate.coordinate_review.prefix(criterionShortText)) ...")
                        .font(.system(size: 16, weight: .light))
                    Button(action: {
                        isShowFullReview = true
                    }) {
                        Text("続きを見る")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(.blue)
                            .background(.white)
                    }
                }
            }
        }
    }

    private func RecommendItems() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("おすすめアイテム")
                .font(.system(size: 20, weight: .bold))

            RecommendItemText(
                // TODO: [BE担当] recommend_item01 と coordinate_item01 を逆にする
//                coordinate_item: fashionReview.coordinate.coordinate_item01,
//                recommend_item: fashionReview.coordinate.recommend_item01,
                coordinate_item: fashionReview.coordinate.recommend_item01,
                recommend_item: fashionReview.coordinate.coordinate_item01,
                recommend_item_url: ""//fashionReview.coordinate.recommend_item01_url!
            )

            RecommendItemText(
//                coordinate_item: fashionReview.coordinate.coordinate_item02,
//                recommend_item: fashionReview.coordinate.recommend_item02,
                coordinate_item: fashionReview.coordinate.recommend_item02,
                recommend_item: fashionReview.coordinate.coordinate_item02,
                recommend_item_url: ""//fashionReview.coordinate.recommend_item02_url!
            )

            RecommendItemText(
//                coordinate_item: fashionReview.coordinate.coordinate_item03,
//                recommend_item: fashionReview.coordinate.recommend_item03,
                coordinate_item: fashionReview.coordinate.recommend_item03,
                recommend_item: fashionReview.coordinate.coordinate_item03,
                recommend_item_url: ""//fashionReview.coordinate.recommend_item03_url!
            )
        }
    }

    private func RecommendItemText(coordinate_item: String, recommend_item: String, recommend_item_url: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Button(action: {
//                tappedURL = recommend_item_url
            }, label: {
                Text("🔍 \(recommend_item)")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
            })
            Text("\(coordinate_item)")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func CoordinateGraph() -> some View {
        VStack(spacing: 48) {
            VStack(spacing: 12) {
                Text("あなたと似ているWEARユーザー")
                    .font(.system(size: 20, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                AsyncImage(url: URL(string: fashionReview.graph_image)!) { image in
                    image
                        .resizable()
                        .frame(maxWidth: 320, maxHeight: 320)
                        .border(.gray, width: 2)
                } placeholder: {
                    ProgressView()
                }
            }

            VStack(spacing: 12) {
                Text("あなたと似ているコーディネート")
                    .font(.system(size: 20, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(fashionReview.recommendations, id: \.self) { similarWearItem in
                            Button(action: {
                                tappedURL = similarWearItem.post_url
                            }, label: {
                                VStack(spacing: 12) {
                                    AsyncImage(url: URL(string: similarWearItem.image_url)!) { image in
                                        image
                                            .resizable()
                                            .frame(width: 30 * 4.5, height: 40 * 4.5)
                                    } placeholder: {
                                        ProgressView()
                                    }

                                    Text("@\(similarWearItem.username)")
                                        .lineLimit(1)
                                }
                            })
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CoordinateReviewView(
        coordinateImage: UIImage(resource: .coordinate1),
        fashionReview: .mock()
    )
}
