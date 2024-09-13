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

    private let parser: LinkParserProtocol = LinkParser()
    private let messageBuilder: MessageBuilderProtocol = GPBMessageBuilder()
    private let pasteBoard: NSPasteboard = NSPasteboard.general

    init() {
        print(">>>> ContentViewModel inited")
    }

    private var isUrlEdited = false

    func formatAndCopy() {
        let parsedLink = parser.parse(link: gitLabURL)
        let formattedURL = messageBuilder.format(link: parsedLink)
        setClipboardString(toAttributedString(formattedURL))
        clearUrl()
    }

    func addToMessage() {
        let parsedLink = parser.parse(link: gitLabURL)
        messageBuilder.add(link: parsedLink)
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

    func onAppear() {
        if !isUrlEdited || gitLabURL.isEmpty {
            let clipboardContent = getClipboardString()
            if parser.isLink(clipboardContent) {
                gitLabURL = clipboardContent
            }
        }
    }

    func onDisappear() {
        if !isUrlEdited {
            gitLabURL.removeAll()
        }
    }

    func onUrlChanged() {
        isUrlEdited = true
    }

    private func clearUrl() {
        gitLabURL = ""
        isUrlEdited = false
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
