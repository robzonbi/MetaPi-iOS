//
//  FAQModels.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-08-09.
//

import Foundation

struct FAQItem: Identifiable, Hashable {
    let id = UUID()
    let question: String
    let answer: String
}

struct FAQSectionModel: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let items: [FAQItem]
}
