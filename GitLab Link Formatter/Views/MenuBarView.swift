//
//  MenuBarView.swift
//  GitLab Link Formatter
//
//  Created by Stan Sidel Work on 9/13/24.
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack {
            TextField("Enter GitLab URL", text: $viewModel.gitLabURL)
                .onSubmit {
                    viewModel.addToMessage()
                }
                .onKeyPress() { _ in
                    viewModel.onUrlChanged()
                    return .ignored
                }
            HStack {
                Button("Format & Copy") {  viewModel.formatAndCopy() }
                Button("Add to Message") { viewModel.addToMessage() }
            }
            if !viewModel.message.characters.isEmpty {
                HStack {
                    Text(viewModel.shortMessage)
                    Button("Copy") { viewModel.copyMessageToClipboard() }
                    Button("Reset") { viewModel.resetMessage() }
                }
            }
            HStack {
                Button("Open App") { viewModel.showAppWindow(action: openWindow) }
                Button("Quit") { viewModel.quitApp() }
            }
        }
        .padding()
        .overlay(alignment: .bottomTrailing) {
            if viewModel.copiedToClipboard {
                Text("Copied to Clipboard")
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.orange.cornerRadius(10))
                    .padding([.trailing, .bottom])
                    .shadow (radius: 5)
                    .transition(.move(edge: .bottom))
                    .frame (maxHeight: .infinity, alignment: .bottom)
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear() {
            viewModel.onDisappear()
        }
    }
}

#Preview {
    let viewModel = ContentViewModel()
    MenuBarView()
        .environmentObject(viewModel)
}
