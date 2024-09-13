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
    @Published var shortMessage: String = ""
    @Published var copiedToClipboard = false

    private let parser: LinkParserProtocol = LinkParser()
    private let messageBuilder: MessageBuilderProtocol = GPBMessageBuilder()
    private let pasteBoard: NSPasteboard = NSPasteboard.general

    private var isUrlEdited = false

    func formatAndCopy() {
        let parsedLink = parser.parse(link: gitLabURL)
        let formattedURL = messageBuilder.format(link: parsedLink)
        setClipboardString(toAttributedString(formattedURL))
        clearUrl()
    }

    func addToMessage() {
        guard parser.isLink(gitLabURL) else { return }
        
        let parsedLink = parser.parse(link: gitLabURL)
        messageBuilder.add(link: parsedLink)
        message = toAttributedString(messageBuilder.message)
        shortMessage = buildShortMessage()
        clearUrl()
    }

    func resetMessage() {
        messageBuilder.clear()
        message = ""
        shortMessage = ""
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

    func onAppAppear() {
        NSApp.setActivationPolicy(.regular)
    }

    func onAppDisappear() {
        NSApp.setActivationPolicy(.accessory)
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

    func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    func showAppWindow(action: OpenWindowAction) {
        if let window = NSApplication.shared.windows.first(where: { $0.isVisible && $0.level == .normal }) {
            window.makeKeyAndOrderFront(nil)
        } else {
            NSApp.setActivationPolicy(.regular)
            action(id: GitLab_Link_FormatterApp.id)
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

    private func buildShortMessage() -> String {
        let linksCount = messageBuilder.linksCount
        return "Collected \(linksCount) \(linksCount == 1 ? "MR" : "MRs")"
    }
}
