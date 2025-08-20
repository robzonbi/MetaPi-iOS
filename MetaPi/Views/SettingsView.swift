//
//  SettingsView.swift
//  MetaPi
//
//  Created by Jordan Tippins on 2025-06-22.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject var preferences = UserPreferences.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundGrey.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Settings")
                            .font(AppFont.inter(.bold, size: 24))
                            .foregroundStyle(.textBlack)
                        Spacer()
                    }
                    .frame(height: 64)
                    .padding(.horizontal)
                    
                    List {
                        //Themes
                        Section {
                            Picker("Appearance", selection: $preferences.theme) {
                                Text("Light").tag(AppTheme.light)
                                Text("Dark").tag(AppTheme.dark)
                                Text("System").tag(AppTheme.system)
                            }
                            .pickerStyle(.menu)
                        }
                        
                        //Metadata
                        Section {
                            Picker("Default Metadata Tags", selection: $preferences.tags) {
                                Text("All Tags").tag(DefaultMetadataTag.allTags)
                                Text("EXIF").tag(DefaultMetadataTag.exif)
                                Text("IPTC").tag(DefaultMetadataTag.iptc)
                                Text("Pi3D").tag(DefaultMetadataTag.pi3d)
                            }
                            .pickerStyle(.menu)
                        }
                        
                        //Info Links
                        Section {
                          ForEach(["About", "FAQs"], id: \.self) { item in
                            NavigationLink(value: item) {
                              HStack {
                                Text(item)
                                Spacer()
                              }
                              .foregroundStyle(.textBlack)
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                              viewModel.onTap(item)
                            })
                          }
                        }

                        
                        //Storage
                        Section {
                            HStack {
                                Text("Storage Usage")
                                Spacer()
                                Text(viewModel.storageUsage)
                                    .foregroundStyle(.textHighlight)
                            }
                        }
                        
                        //Missing Location
                        Section {
                            Toggle("Location Missing Indicator", isOn: $viewModel.isMissingLocationOn)
                                .onChange(of: viewModel.isMissingLocationOn) {
                                    viewModel.toggleMissingLocation()
                                }
                                .tint(.buttonPrimaryBg)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationDestination(for: String.self) { item in
                infoDestination(for: item)
            }
        }
        .environmentObject(preferences)
        .onAppear {
            viewModel.storageUsage = viewModel.displayStorage()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(UserPreferences.shared)
    }
}


@ViewBuilder
private func infoDestination(for item: String) -> some View {
  switch item {
  case "About":   AboutView()
  case "FAQs":    FAQView()
  default:       EmptyView()
  }
}
