//
//  ContentViewModel.swift
//  GitLab Link Formatter
//
//  Created by Stan Sidel Work on 9/13/24.
//

import SwiftUI

final class ContentViewModel: ObservableObject {

    @Published var gitLabURL = ""
    @Published var message: AttributedString = ""
    @Published var copiedToClipboard = false

    private let formatter: LinkFormatterProtocol = LinkFormatter()
    private let messageBuilder: MessageBuilderProtocol = GPBMessageBuilder()
    private let pasteBoard: NSPasteboard = NSPasteboard.general

    func formatAndCopy() {
        let formattedURL = formatter.format(link: gitLabURL)
        setClipboardString(toAttributedString(formattedURL))
        clearUrl()
    }

    func addToMessage() {
        let formattedURL = formatter.format(link: gitLabURL)
        messageBuilder.add(link: formattedURL)
        message = toAttributedString(messageBuilder.message)
        clearUrl()
    }

    func resetMessage() {
        messageBuilder.clear()
        message = ""
    }

    func copyMessageToClipboard() {
        setClipboardString(message)
    }

    func toAttributedString(_ string: String) -> AttributedString {
        try! AttributedString(
            markdown: string,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        )
    }

    private func clearUrl() {
        gitLabURL = ""
    }

    private func getClipboardString() -> String {
        pasteBoard.string(forType: .string) ?? ""
    }

    private func setClipboardString(_ string: AttributedString) {
        pasteBoard.clearContents()
        let nsAttributedString = NSAttributedString(string)

        do {
            let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtf]
            let rtfData = try nsAttributedString.data(from: NSMakeRange(0, nsAttributedString.length), documentAttributes: documentAttributes)
            pasteBoard.setData(rtfData, forType: .rtf)
        }
        catch {
            print("error creating RTF from Attributed String")
            return
        }
        notifyCopied()
    }

    private func notifyCopied() {
        withAnimation(.snappy) {
            copiedToClipboard = true
        }

        DispatchQueue.main.asyncAfter (deadline: .now() + 1.5) {
            withAnimation(.snappy) {
                self.copiedToClipboard = false
            }
        }

    }
}
