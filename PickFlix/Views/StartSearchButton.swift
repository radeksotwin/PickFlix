//
//  StartSearchButton.swift
//  PickFlix
//
//  Created by Rdm on 17/07/2026.
//
import SwiftUI

struct StartSearchButton: View {
    let action: () -> Void

    @State private var animateGlow = false
    @State private var animateShimmer = false

    var body: some View {
        Button {
            Haptics.generateImpact(.soft)
            action()
        } label: {
            ZStack {
                // Glow layer
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        AngularGradient(
                            colors: [
                                .yellow,
                                .red,
                                .purple,
                                .yellow
                            ],
                            center: .center
                        ),
                        lineWidth: 3
                    )
                    .blur(radius: animateGlow ? 10 : 3)
                    .opacity(animateGlow ? 0.9 : 0.4)

                // Main button
                RoundedRectangle(cornerRadius: 26)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.red,
                                Color.orange
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // Shimmer
                RoundedRectangle(cornerRadius: 26)
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.35),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(20))
                    .offset(
                        x: animateShimmer ? 300 : -300
                    )


                HStack(spacing: 10) {

                    Image(systemName: "dice.fill")

                    Text("Pick tonight's movie")
                        .font(.system(
                            size: 17,
                            weight: .semibold
                        ))
                }
                .foregroundColor(.white)

            }
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .clipShape(
                RoundedRectangle(cornerRadius: 26)
            )
            .padding(.horizontal, 24)

        }
        .buttonStyle(.plain)

        .onAppear {

            withAnimation(
                .easeInOut(duration: 2)
                .repeatForever(
                    autoreverses: true
                )
            ) {
                animateGlow = true
            }


            withAnimation(
                .linear(duration: 3.7)
                .repeatForever(
                    autoreverses: false
                )
            ) {
                animateShimmer = true
            }
        }
    }
}
