//
//  LinkParser.swift
//  GitLab Link Formatter
//
//  Created by Stan Sidel Work on 9/13/24.
//

import Foundation

enum ParsedLinkType {
    case mergeRequest(ParsedMRInfo)
    case unknown(String)
}

struct ParsedMRInfo {
    let url: String
    let group: String
    let project: String
    let mrNumber: String
}

protocol LinkParserProtocol {
    func parse(link: String) -> ParsedLinkType
}

final class LinkParser: LinkParserProtocol {

    private let wordsCapitalizer: WordsCapitalizer

    init(wordsCapitalizer: WordsCapitalizer = EnglishWordsCapitalizer()) {
        self.wordsCapitalizer = wordsCapitalizer
    }

    func parse(link: String) -> ParsedLinkType {
        guard let mrInfo = parseMR(from: link) else {
            return .unknown(link)
        }

        let group = wordsCapitalizer.capitalizeWords(in: mrInfo.group)
        let project = wordsCapitalizer.capitalizeWords(in: mrInfo.project)

        return .mergeRequest(ParsedMRInfo(url: link, group: group, project: project, mrNumber: mrInfo.mrNumber))
    }

    private func parseMR(from link: String) -> ParsedMRInfo? {
        let pattern = ".*\\/([^\\/]+)\\/([^\\/]+)\\/[^\\/]*\\/merge_requests\\/(\\d+)"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])

        if let match = regex?.firstMatch(in: link, options: [], range: NSRange(location: 0, length: link.utf16.count)) {
            let groupRange = Range(match.range(at: 1), in: link)
            let projectRange = Range(match.range(at: 2), in: link)
            let mrNumberRange = Range(match.range(at: 3), in: link)

            if let group = groupRange.flatMap({ String(link[$0]) }),
               let project = projectRange.flatMap({ String(link[$0]) }),
               let mrNumber = mrNumberRange.flatMap({ String(link[$0]) }) {
                return ParsedMRInfo(url: link, group: group, project: project, mrNumber: mrNumber)
            }
        }

        return nil
    }
}
