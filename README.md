# MetaPi – iOS

MetaPi is an iOS application built with Swift and SwiftUI that enables users to:

-   Browse images on their device
-   View and edit EXIF and IPTC metadata
-   Crop and adjust photos
-   Set or modify location data via CoreLocation integration
-   Prepare and upload images to cloud storage for use in Pi3D digital picture frames

---

## Table of Contents

1. [Tech Stack](#tech-stack)
2. [Architecture](#architecture)
3. [Project Structure](#project-structure)
4. [Features](#features)
5. [Setup & Installation](#setup--installation)
6. [API Keys & Configuration](#api-keys--configuration)
7. [Build & Deployment](#build--deployment)
8. [Planned Enhancements](#planned-enhancements)

---

## Tech Stack

-   **Language:** Swift
-   **UI Framework:** SwiftUI
-   **Architecture:** MVVM (Model-View-ViewModel)
-   **EXIF & IPTC Metadata Handling:** [ImageIO](https://developer.apple.com/documentation/imageio)
-   **Maps Display Integration:** [MapKit](https://developer.apple.com/documentation/mapkit)
-   **Location Retrieval Integration:** [CoreLocation](https://developer.apple.com/documentation/corelocation)
-   **Image Cropping:** [Mantis](https://github.com/guoyingtao/Mantis)

---

## Architecture

The app follows the **MVVM** architecture to ensure separation of concerns:

-   **Model:** Data classes and metadata parsing logic
-   **ViewModel:** Holds UI state and business logic
-   **View (UI):** Composable functions for screens and components

---

## Project Structure

    MetaPi/
    │
    ├── Components/ # Reusable SwiftUI UI components
    ├── Fonts/ # Custom font assets
    ├── Models/ # Data models, including EXIF/IPTC structures
    ├── Styles/ # App-wide styling, colors, typography
    ├── Utils/ # Helper functions (file I/O, date formatting, etc.)
    ├── ViewModels/ # ObservableObjects for managing screen state
    ├── Views/ # Main SwiftUI screens
    │ ├── Dialogs/ # Custom dialogs and alerts
    │ ├── SubViews/ # Smaller components used within main views
    │ ├── WelcomeView/ # Onboarding/welcome flow
    ├── Assets/ # App icons, splash screens, image assets
    ├── Info/ # App configuration (Info.plist)
    └── MetaPiApp.swift # App entry point

---

## Features

-   **Gallery View** – Lists images from the device’s photo library
-   **Photo Details View** – Displays full image + metadata with editing options
-   **Crop Tool** – Powered by Mantis for intuitive cropping and adjustments
-   **Location Picker** – Uses CoreLocation for geotagging & MapKit for map display
-   **Metadata Editing** – Edit EXIF/IPTC data fields directly in-app
-   **Cloud Upload Preparation** – Images ready for Pi3D frame sync

---

## Setup & Installation

1. **Clone the Repository**

    ```bash
    git clone <repo-link>
    cd MetaPi-iOS
    ```

2. **Open in Xcode**

3. **Install Dependencies**

-   Uses Swift Package Manager (SPM)
-   In Xcode: File → Add Packages... → Ensure Mantis (v2.26.0) is installed

4. **Run the App**

-   Select an emulator and click Run.

---

## Build and Deployment

1. Build

-   Select target device/simulator in Xcode
-   Press Cmd + R to run

2. TestFlight

-   Archive via Product → Archive
-   Upload to App Store Connect
-   Add testers in TestFlight

---

## Planned Enhancements

-   Direct Pi3D Picture Frame integration via MQTT or cloud sync.
-   Frame preview simulation.
