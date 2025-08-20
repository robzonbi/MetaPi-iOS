//
//  LocationSearchViewModel.swift
//  MetaPi
//
//  Created by Vinaydeep Singh Padda on 2025-08-01.
//
import SwiftUI
import MapKit


class LocationSearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var suggestions: [MKLocalSearchCompletion] = []
        
        private var completer: MKLocalSearchCompleter

        override init() {
            self.completer = MKLocalSearchCompleter()
            super.init()
            self.completer.delegate = self
            self.completer.resultTypes = [.address, .pointOfInterest]
        }

        func updateSearch(_ query: String) {
            completer.queryFragment = query
        }

        func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            self.suggestions = completer.results
        }

        func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
            print("Autocomplete error: \(error)")
        }
    }
