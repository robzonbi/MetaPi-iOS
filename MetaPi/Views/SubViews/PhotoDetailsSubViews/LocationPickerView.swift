//
//  LocationPickerView.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-06-27.
//

import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var cameraPosition: MapCameraPosition
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var selectedIsFromSuggestion = false
    @State private var showSelectLocationAlert = false
    @State private var isProgrammaticTextUpdate = false

    @StateObject private var suggestionsVM = LocationSearchViewModel()

    var initialCoordinate: CLLocationCoordinate2D?
    var onLocationSelected: (CLLocationCoordinate2D) -> Void

    init(initialCoordinate: CLLocationCoordinate2D? = nil,
         onLocationSelected: @escaping (CLLocationCoordinate2D) -> Void) {
        let center = initialCoordinate ?? CLLocationCoordinate2D(latitude: 45.4215, longitude: -75.6997)
        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        _cameraPosition = State(initialValue: .region(region))
        _selectedCoordinate = State(initialValue: initialCoordinate)
        self.onLocationSelected = onLocationSelected
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
             
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)

                    TextField("Type your location", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(AppFont.inter(.regular, size: 14))
                        .submitLabel(.done) // no Search action
                        .onChange(of: searchText) { _, newValue in
                            if !isProgrammaticTextUpdate {
                                selectedIsFromSuggestion = false
                                selectedCoordinate = nil
                            }
                            suggestionsVM.updateSearch(newValue)
                        }

                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            selectedIsFromSuggestion = false
                            selectedCoordinate = nil
                            suggestionsVM.suggestions = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.gray)
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .background(.backgroundGrey)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
                .padding(.top, 12)

                if !searchText.isEmpty && !suggestionsVM.suggestions.isEmpty {
                    List(suggestionsVM.suggestions, id: \.self) { suggestion in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(suggestion.title)
                                .font(AppFont.inter(.medium, size: 14))
                                .foregroundColor(.textBlack)
                            Text(suggestion.subtitle)
                                .font(AppFont.inter(.regular, size: 12))
                                .foregroundColor(.textGrey)
                        }
                        .padding(.vertical, 4)
                        .onTapGesture { selectSuggestion(suggestion) }
                    }
                    .listStyle(.plain)
                    .background(.backgroundWhite)
                } else {
                    Map(position: $cameraPosition) {
                        if let coord = selectedCoordinate {
                            Annotation("Selected", coordinate: coord) {
                                Image("location_filled_icon")
                                    .foregroundStyle(.locationPin)
                                    .imageScale(.large)
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .background(.backgroundWhite)
            .navigationTitle("Edit Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(AppFont.inter(.medium, size: 16))
                        .foregroundStyle(.textHighlight.opacity(0.7))
                }
                ToolbarItem(placement: .principal) {
                    Text("Edit Location")
                        .font(AppFont.inter(.bold, size: 16))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if selectedIsFromSuggestion, let coord = selectedCoordinate {
                            onLocationSelected(coord)
                            dismiss()
                        } else {
                            showSelectLocationAlert = true
                        }
                    }
                    .font(AppFont.inter(.semibold, size: 16))
                    .foregroundStyle(.textHighlight)
                }
            }
            .customDialog(
                title: "Please select a location",
                isPresented: $showSelectLocationAlert,
                icon: "warning_icon"
            ) {
                HStack(spacing: 8) {
                    AppButton(
                        title: "OK",
                        action: { showSelectLocationAlert = false },
                        style: .secondary,
                        fullWidth: true
                    )
                }
            } message: {
                Text("Choose a place from the suggestions list.")
            }
        }
    }

    private func selectSuggestion(_ suggestion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: suggestion)
        MKLocalSearch(request: request).start { response, _ in
            guard let mapItem = response?.mapItems.first else { return }

            let coordinate = mapItem.placemark.coordinate
            selectedCoordinate = coordinate
            selectedIsFromSuggestion = true

            let title = suggestion.title
            let subtitle = suggestion.subtitle

            isProgrammaticTextUpdate = true
            searchText = subtitle.isEmpty ? title : "\(title), \(subtitle)"
            DispatchQueue.main.async { isProgrammaticTextUpdate = false }

            suggestionsVM.suggestions = []

            withAnimation {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                )
            }

            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil, from: nil, for: nil)
        }
    }
}
