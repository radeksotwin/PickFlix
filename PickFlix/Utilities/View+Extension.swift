//
//  View+Extension.swift
//  PickFlix
//
//  Created by Rdm on 14/04/2026.
//

import SwiftUI

extension View {
    /// Navigate to a new view.
    /// - Parameters:
    ///   - view: View to navigate to.
    ///   - binding: Only navigates when this condition is `true`.
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
        NavigationStack {
            ZStack {
                self
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .navigationDestination(isPresented: binding) {
                        view
                            .navigationBarTitle("")
                            .navigationBarHidden(true)
                    }
            }
        }
        .navigationViewStyle(.stack)
    }
}
