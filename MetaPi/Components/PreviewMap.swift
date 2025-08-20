//
//  PreviewMap.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-07-13.
//

import SwiftUI
import MapKit

struct PreviewMap: View {
    let coordinate: CLLocationCoordinate2D
    let markerTitle: String
    let onTap: () -> Void

    init(
        coordinate: CLLocationCoordinate2D,
        markerTitle: String = "Photo Location",
        onTap: @escaping () -> Void
    ) {
        self.coordinate = coordinate
        self.markerTitle = markerTitle
        self.onTap = onTap
    }

    var body: some View {
        ZStack {
            Map(initialPosition: .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )) {
                Annotation("", coordinate: coordinate) {
                    Image("location_filled_icon")
                        .renderingMode(.template)
                        .foregroundStyle(.locationPin)
                }
            }
            .id(HashableCoordinate(coordinate))
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Color.clear
                .frame(height: 160)
                .contentShape(Rectangle())
                .onTapGesture {
                    onTap()
                }
        }
    }
}
