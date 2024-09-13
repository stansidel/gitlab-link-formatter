//
//  ContentView.swift
//  GitLab Link Formatter
//
//  Created by Stan Sidel Work on 9/13/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: ContentViewModel

    var body: some View {
        VStack {
            Text("Hello, world!")
            TextField("Enter GitLab URL", text: $viewModel.gitLabURL)
                .onSubmit {
                    viewModel.formatAndCopy()
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
                Text("Message:")
                Text(viewModel.message)
                    .background(Color.white)
                HStack {
                    Button("Copy") { viewModel.copyMessageToClipboard() }
                    Button("Reset") { viewModel.resetMessage() }
                }
            }
        }
        .padding()
        .overlay {
            if viewModel.copiedToClipboard {
                Text("Copied to Clipboard")
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.orange.cornerRadius(20))
                    .padding(.bottom)
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
    ContentView()
        .environmentObject(ContentViewModel())
}
