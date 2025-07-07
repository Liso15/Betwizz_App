# Betwizz_App

## Description

Betwizz is a Sports Betting Intelligence Platform delivered as a Flutter mobile application, with an initial focus on the South African market. It aims to provide users with advanced tools for betting, strategy sharing, and community interaction, leveraging AI and real-time data.

## Key Features

-   **In-App Streaming:** Watch live sports events directly within the app.
-   **Strategy Sharing:** Securely share and access betting strategies.
-   **OCR Receipt Processing:** Scan and parse bet slips from major platforms like Betway and Hollywood Bets.
-   **AI-Powered Insights:**
    -   **Mfethu:** A Dialogflow-based chatbot for user assistance and Q&A.
    -   **Khanyo:** A TensorFlow Lite-based engine for predictions.
-   **Monetization:** Subscription tiers for accessing premium channel content.
-   **Real-time Bet Overlays:** Display current stake and odds during live streams.
-   **Viewer Engagement Heatmaps:** Visualize viewer interaction during streams.
-   **Encrypted Chat:** Secure communication within channels.
-   **Offline Capabilities:** Access cached strategies, leaderboards, and draft receipts offline.

## Tech Stack

### Mobile
-   **Framework:** Flutter 4.0
-   **State Management:** Riverpod 3.0
-   **Local Storage:** Hive 4.0
-   **Services & SDKs:**
    -   PayFast SDK (for payments)
    -   Agora RTC (for live streaming)
    -   Firebase ML Kit (for OCR and other ML features)
    -   Sportradar API (for sports data)
-   **AI Integration:**
    -   Mfethu: Dialogflow
    -   Khanyo: TensorFlow Lite

### Backend Integration (Key Services)
-   **User Authentication:** Firebase Auth (REST)
-   **Payment Processing:** PayFast API
-   **Live Streaming:** Agora RTC
-   **OCR Processing:** Firebase ML
-   **Sports Data:** Sportradar (WebSockets)

## Getting Started

### Prerequisites

-   Flutter SDK (ensure version compatible with Flutter 4.0 as specified in PRD or project settings)
-   Relevant IDE (Android Studio, VS Code with Flutter extension)
-   Access keys/credentials for:
    -   Firebase
    -   PayFast
    -   Agora
    -   Sportradar
    -   Dialogflow

### Installation

1.  Clone the repo:
    ```sh
    git clone <repository-url>
    ```
2.  Navigate to the project directory:
    ```sh
    cd Betwizz_App
    ```
3.  Install dependencies:
    ```sh
    flutter pub get
    ```
4.  Configure environment variables for API keys and service credentials (details to be added, e.g., via a `.env` file or similar mechanism).
5.  Run any necessary build runners (e.g., for Hive, Riverpod code generation if applicable):
    ```sh
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

### Running the Application
-   Ensure a compatible emulator is running or a device is connected.
-   Run the app:
    ```sh
    flutter run
    ```

## Challenges

This section provides a high-level overview of project challenges. Detailed tracking of challenges, including their status (Uncompleted, Completed, Optimised), can be found in `docs/PROJECT_CHALLENGES.md`.

## Compliance & Localization

-   **South Africa Specific:**
    -   **POPIA Compliance:** Data encryption at rest (Hive with AES), local data residency considerations.
    -   **Gambling Regulations:** Age verification, loss limit features, responsible gambling information.
-   **Localization:** Support for ZAR currency formatting and other regional considerations.

## Contributing

(Details to be added if contributions are expected.)

## License

(To be determined and specified, e.g., MIT License.)