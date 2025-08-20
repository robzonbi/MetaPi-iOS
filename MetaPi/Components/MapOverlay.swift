//
//  MapOverlay.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-07-11.
//
import SwiftUI
import MapKit

struct MapOverlay: View {
    let coordinate: CLLocationCoordinate2D
    let locationText: String
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Map(initialPosition: .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))) {
                
                Annotation(locationText, coordinate: coordinate) {
                    Image("location_filled_icon")
                        .renderingMode(.template)
                        .foregroundStyle(.locationPin)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Close")
                            .font(AppFont.inter(.medium, size: 16))
                            .foregroundStyle(.textHighlight)
                    }
                }
            }
            .toolbarBackground(Color.backgroundWhite, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
