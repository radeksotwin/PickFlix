//
//  MovieResultView.swift
//  PickFlix
//

import SwiftUI

struct MovieResultView: View {
    let movie: Movie
    let onAnother: () -> Void
    let onWatch: () -> Void

    @State private var appeared = false
    @State private var confirmed = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Poster
                AsyncImage(url: URL(string: movie.posterURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(2/3, contentMode: .fit)
                            .frame(maxWidth: 220)
                            .cornerRadius(18)
                            .shadow(color: .black.opacity(0.5), radius: 20, y: 10)

                    case .failure:
                        posterPlaceholder(icon: "film")

                    case .empty:
                        posterPlaceholder(icon: nil)

                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(.top, 32)

                // Title
                Text(movie.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Overview
                if !movie.overview.isEmpty {
                    Text(movie.overview)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(5)
                        .padding(.horizontal, 28)
                }

                // Platforms
                if !movie.platforms.isEmpty {
                    VStack(spacing: 10) {
                        Text("Dostępne na")
                            .font(.caption)
                            .foregroundStyle(.gray.opacity(0.7))

                        FlowLayout(spacing: 8) {
                            ForEach(movie.platforms, id: \.self) { platform in
                                Text(platform)
                                    .font(.caption.bold())
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(AppColors.cardBackground)
                                    .foregroundStyle(.white)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom, 16)
        }
        .scrollIndicators(.hidden)
        // Przyciski jako inset — scroll wie o ich wysokości i nie chowa pod nimi treści
        .safeAreaInset(edge: .bottom) {
            buttons
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(duration: 0.5, bounce: 0.15)) {
                appeared = true
            }
        }
    }

    // MARK: - Buttons

    private var buttons: some View {
        VStack(spacing: 12) {
            Button(action: handleWatch) {
                HStack(spacing: 8) {
                    if confirmed {
                        Image(systemName: "checkmark")
                            .transition(.scale.combined(with: .opacity))
                    }
                    Text(confirmed ? "Dobrego seansu!" : "Oglądam!")
                        .transition(.opacity)
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(confirmed ? Color.green.opacity(0.85) : .white)
                .foregroundStyle(confirmed ? .white : .black)
                .cornerRadius(16)
                .animation(.spring(duration: 0.35), value: confirmed)
            }
            .disabled(confirmed)

            Button(action: onAnother) {
                Text("Inny film")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.cardBackground)
                    .foregroundStyle(.white)
                    .cornerRadius(16)
            }
            .disabled(confirmed)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 40)
        .background(
            // delikatne zanikanie tła, żeby przyciski nie "ucinały" gradientu
            LinearGradient(
                colors: [.clear, AppColors.primaryBackground.opacity(0.95)],
                startPoint: .top,
                endPoint: .init(x: 0.5, y: 0.3)
            )
        )
    }

    // MARK: - Actions

    private func handleWatch() {
        Haptics.generateImpact(.medium)
        withAnimation(.spring(duration: 0.35)) {
            confirmed = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            onWatch()
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func posterPlaceholder(icon: String?) -> some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(AppColors.cardBackground)
            .frame(width: 220, height: 330)
            .overlay {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 40))
                        .foregroundStyle(.gray.opacity(0.5))
                } else {
                    ProgressView()
                }
            }
    }
}

// MARK: - Flow layout for platform tags

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        return CGSize(
            width: proposal.width ?? 0,
            height: rows.map { $0.map { $0.height }.max() ?? 0 }.reduce(0) { $0 + $1 + spacing } - spacing
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            let rowHeight = row.map { $0.height }.max() ?? 0
            var x = bounds.minX + (bounds.width - row.map { $0.width + spacing }.reduce(0, +) + spacing) / 2
            for item in row {
                subviews[item.index].place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += item.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private struct Item { let index: Int; let width: CGFloat; let height: CGFloat }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[Item]] {
        var rows: [[Item]] = [[]]
        var rowWidth: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity

        for (i, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width + spacing > maxWidth, !rows[rows.count - 1].isEmpty {
                rows.append([])
                rowWidth = 0
            }
            rows[rows.count - 1].append(Item(index: i, width: size.width, height: size.height))
            rowWidth += size.width + spacing
        }
        return rows
    }
}

#Preview {
    ZStack {
        AppColors.primaryBackground.ignoresSafeArea()
        MovieResultView(
            movie: Movie(
                title: "Scarface",
                overview: "The world is yours. A story of crime, power, and inevitable fall in Miami.",
                posterURL: "",
                platforms: ["Netflix", "HBO Max", "Disney+"]
            ),
            onAnother: {},
            onWatch: {}
        )
    }
}
