//
//  MessageBuilder.swift
//  GitLab Link Formatter
//
//  Created by Stan Sidel Work on 9/13/24.
//

protocol MessageBuilderProtocol {
    var message: String { get }
    var linksCount: Int { get }

    func format(link: ParsedLinkType) -> String
    func add(link: ParsedLinkType)
    func clear()
}

final class GPBMessageBuilder: MessageBuilderProtocol {
    private var links = [ParsedLinkType]()

    var message: String {
        guard !links.isEmpty else { return "" }

        let introPhrase = "Посмотрите, пожалуйста,"
        if links.count == 1 {
            return "\(introPhrase) MR — \(format(link: links[0]))"
        }

        let introString = "\(introPhrase) MRы:"
        let linksStirng = links.map { "* \(format(link: $0))" }.joined(separator: "\n")
        return "\(introString)\n\n\(linksStirng)"
    }

    var linksCount: Int { links.count }

    func format(link: ParsedLinkType) -> String {
        switch link {
        case .mergeRequest(let info):
            return "[\(info.project) #\(info.mrNumber) в \(info.group)](\(info.url))"
        case .unknown(let link):
            return link
        }
    }

    func add(link: ParsedLinkType) {
        links.append(link)
    }

    func clear() {
        links.removeAll()
    }
}
