//
//  WordsCapitalizer.swift
//  GitLab Link Formatter
//
//  Created by Stan Sidel Work on 9/13/24.
//

import Foundation

protocol WordsCapitalizer {
    func capitalizeWords(in string: String) -> String
}

final class EnglishWordsCapitalizer: WordsCapitalizer {

    func capitalizeWords(in string: String) -> String {
        return string
    }
}
