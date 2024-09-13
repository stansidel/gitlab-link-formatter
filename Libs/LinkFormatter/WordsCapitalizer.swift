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

    private let commonWordsLoader = CommonWordsLoader()
    private let abbreviations: [String: Bool] = [
        "GPB": true,
        "iOS": true,
        "CBDC": true,
        "gazprombank": false,
        "services": false,
        "core": false,
    ]

    private var commonWords = Set<String>()
    private var sortedCommonWords: [String] = []

    init() {
        Task {
            await loadCommonWords()
        }
    }

    func capitalizeWords(in input: String) -> String {
        // Helper function to split the input by abbreviations
        func splitByAbbreviations(_ input: String) -> [(String, Bool)] {
            var parts: [(String, Bool)] = [(input.lowercased(), false)]

            for (abbr, _) in abbreviations {
                var newParts: [(String, Bool)] = []
                for (part, isAbbreviation) in parts {
                    if isAbbreviation {
                        newParts.append((part, true))
                    } else {
                        let split = part.components(separatedBy: abbr.lowercased())

                        for i in 0..<split.count {
                            newParts.append((split[i], false))
                            if i != split.count - 1 {
                                newParts.append((abbr, true))  // Insert the abbreviation as a marked part
                            }
                        }
                    }
                }
                parts = newParts
            }

            return parts.filter { !$0.0.isEmpty } // Remove empty parts
        }

        // Step 1: Split by abbreviations and mark the abbreviation parts
        var processedWords: [String] = []
        let parts = splitByAbbreviations(input)

        // Step 2: Iterate over the parts and find the longest matching common words for non-abbreviation parts
        for (part, isAbbreviation) in parts {
            if isAbbreviation {
                // Process abbreviations according to their specified format (uppercase or capitalized)
                if let preserveCase = abbreviations[part] {
                    processedWords.append(preserveCase ? part : part.capitalized)
                }
                continue // Skip further processing for abbreviations
            }

            var tempPart = part
            while !tempPart.isEmpty {
                var foundMatch = false
                // Find the longest common word at the beginning of the part
                for word in sortedCommonWords {
                    if tempPart.lowercased().hasPrefix(word.lowercased()) {
                        // Add capitalized common word to result
                        processedWords.append(word.capitalized)
                        // Remove the matched part from tempPart
                        tempPart.removeFirst(word.count)
                        foundMatch = true
                        break
                    }
                }
                // If no match is found, take one character and move on
                if !foundMatch {
                    processedWords.append(String(tempPart.first!))
                    tempPart.removeFirst()
                }
            }
        }

        // Step 3: Join the processed words back together to form the final result
        return processedWords.joined()
    }

    private func loadCommonWords() async {
        await commonWordsLoader.loadCommonWords()
        commonWords = await commonWordsLoader.commonWords
        sortedCommonWords = commonWords.sorted(by: { $0.count > $1.count })
    }
}

actor CommonWordsLoader {
    var commonWords: Set<String> = []

    func loadCommonWords() async {
        guard let url = Bundle.main.url(forResource: "common_words", withExtension: "json") else {
            print("Error: common_words.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let words = try JSONDecoder().decode([String].self, from: data)
            commonWords = Set(words)
        } catch {
            print("Error loading common words: \(error)")
        }
    }
}
