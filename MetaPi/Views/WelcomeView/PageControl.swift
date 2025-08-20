//
//  PageControl.swift
//  MetaPi
//
//  Created by Yuhang Zhou on 2025-07-12.
//

import SwiftUI
import UIKit

struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int

    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.currentPageIndicatorTintColor = UIColor(named: "pageControlActive")
        control.pageIndicatorTintColor = UIColor(named: "pageControlInactive")
        control.numberOfPages = numberOfPages
        control.isUserInteractionEnabled = false
        return control
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }
}


