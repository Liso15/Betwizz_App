# Project Challenges for Betwizz App

This document tracks the development status of key challenges for the Betwizz Flutter application.

## Challenge Status Legend
-   **Uncompleted:** The challenge has been identified but work has not yet started or is in the very early stages.
-   **In Progress:** Active development is underway for this challenge.
-   **Completed:** The challenge has been implemented according to the initial requirements outlined in the PRD.
-   **Optimised:** The completed challenge implementation has been reviewed and improved for performance, readability, security, or other criteria.
-   **Blocked:** Progress on this challenge is currently impeded by an external factor or dependency.

---

## 1. Authentication Module (PRD Section 5.1)

### 1.1 Firebase Integration
-   **Description:** Integrate Firebase Authentication for user sign-up, sign-in, and session management.
-   **PRD Ref:** 5.1 Authentication
-   **Status:** Uncompleted

### 1.2 FICA Verification Flow
-   **Description:** Implement the FICA verification process, potentially involving ID scanning and validation against relevant services.
-   **PRD Ref:** 5.1 Authentication; 6.1 Gambling Regulations (Age verification gate)
-   **Status:** Uncompleted

---

## 2. Receipt Processing Module (PRD Section 5.1)

### 2.1 Betway OCR Parser
-   **Description:** Develop and integrate an OCR parser using Firebase ML Kit to extract data from Betway bet slips.
-   **PRD Ref:** 5.1 Receipt Processing
-   **Status:** Uncompleted

### 2.2 Hollywood Bets Integration
-   **Description:** Develop and integrate an OCR parser or other method to process Hollywood Bets bet slips.
-   **PRD Ref:** 5.1 Receipt Processing
-   **Status:** Uncompleted

---

## 3. Channels Module (PRD Section 2 & 5.1)

### 3.1 Agora Implementation for Live Streaming
-   **Description:** Integrate Agora RTC for in-app live video streaming capabilities, including portrait/landscape support and performance overlays.
-   **PRD Ref:** 2.1 Core Features; 2.2 Technical Requirements; 5.1 Channels
-   **Status:** Uncompleted

### 3.2 PayFast Integration for Monetization
-   **Description:** Implement the PayFast payment gateway for channel subscriptions and creator payouts.
-   **PRD Ref:** 2.1 Monetization Flow; 2.2 Technical Requirements; 5.1 Channels
-   **Status:** Uncompleted

### 3.3 Encrypted Chat
-   **Description:** Implement E2E encrypted chat functionality within channels using `flutter_secure_chat` or similar.
-   **PRD Ref:** 2.2 Technical Requirements
-   **Status:** Uncompleted

### 3.4 Strategy Sharing & Vault
-   **Description:** Develop functionality for users to share strategies, including encryption (`AES256`) and storage.
-   **PRD Ref:** 2.1 Strategy Sharing
-   **Status:** Uncompleted

---

## 4. AI Integration Module (PRD Section 1.1 & 5.1)

### 4.1 Mfethu Chat Interface (Dialogflow)
-   **Description:** Build the user interface and integration logic for the Mfethu chatbot using Dialogflow.
-   **PRD Ref:** 1.1 AI Integration; 5.1 AI
-   **Status:** Uncompleted

### 4.2 Khanyo Prediction Engine (TensorFlow Lite)
-   **Description:** Integrate the TensorFlow Lite model for Khanyo predictions and display these insights within the app.
-   **PRD Ref:** 1.1 AI Integration; 5.1 AI
-   **Status:** Uncompleted

---

## 5. Core UI/UX and Mobile Specifics (PRD Section 3 & 4)

### 5.1 Channel Dashboard Implementation
-   **Description:** Build the Channel Dashboard screen as per wireframes and PRD specifications.
-   **PRD Ref:** 3.1.1 Channel Dashboard
-   **Status:** Uncompleted

### 5.2 Stream Overlay UI
-   **Description:** Implement the Stream Overlay UI including WebRTC renderer, real-time bet slip, viewer count, and donation button.
-   **PRD Ref:** 3.1.2 Stream Overlay UI
-   **Status:** Uncompleted

### 5.3 Offline Capabilities
-   **Description:** Implement offline support for cached strategy documents, leaderboard snapshots, draft bet receipts, and basic Mfethu Q&A.
-   **PRD Ref:** 4.2 Offline Capabilities
-   **Status:** Uncompleted

### 5.4 Performance Benchmarking & Optimization
-   **Description:** Continuously monitor and optimize for performance benchmarks (app launch, stream startup, OCR processing, battery impact).
-   **PRD Ref:** 4.1 Performance Benchmarks
-   **Status:** Uncompleted

---

## 6. Compliance & Localization (PRD Section 6)

### 6.1 POPIA Compliance Measures
-   **Description:** Ensure all data handling, encryption (Hive with AES), and storage meet POPIA requirements.
-   **PRD Ref:** 6.1 SA-Specific Requirements
-   **Status:** Uncompleted

### 6.2 Gambling Regulation Features
-   **Description:** Implement features for age verification, loss limits, and responsible gambling information.
-   **PRD Ref:** 6.1 SA-Specific Requirements
-   **Status:** Uncompleted

### 6.3 ZAR Localization
-   **Description:** Implement ZAR currency formatting and other localization requirements.
-   **PRD Ref:** 6.2 Localization
-   **Status:** Uncompleted
