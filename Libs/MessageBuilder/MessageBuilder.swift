//
//  MessageBuilder.swift
//  GitLab Link Formatter
//
//  Created by Stan Sidel Work on 9/13/24.
//

protocol MessageBuilderProtocol {
    var message: String { get }

    func add(link: String)
    func clear()
}

final class GPBMessageBuilder: MessageBuilderProtocol {
    private var links = [String]()

    var message: String {
        let introString = "Have a look at my \(links.count > 1 ? "MRs" : "MR")"
        let linksStirng = links.map { "* \($0)" }.joined(separator: "\n")
        return "\(introString)\n\n\(linksStirng)"
    }

    func add(link: String) {
        links.append(link)
    }

    func clear() {
        links.removeAll()
    }
}
