# Shopping Assistant for Visually Impaired Users

A Flutter-based mobile application designed to improve the shopping experience for partially visually impaired individuals. This app integrates accessibility features like product identification using TensorFlow Lite, video calling via ZEGOCLOUD, and the ability to create community posts and record emergency voice notes.

## Table of Contents
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Installation](#installation)
- [Usage](#usage)
- [Screenshots](#screenshots)
- [Contributing](#contributing)
- [License](#license)

## Features
- **Product Identification**: Users can scan a product, and the app will identify it using TensorFlow Lite.
- **Video Calls**: Seamlessly make video calls to contacts using ZEGOCLOUD.
- **Community Posts**: Users can create and share posts with the community.
- **Emergency Voice Notes**: Record and send voice notes for emergencies.
- **Accessible UI**: Designed with accessibility in mind, offering a clean, simple interface tailored to the needs of partially visually impaired users.

## Technology Stack
- **Flutter**: Cross-platform mobile application development.
- **TensorFlow Lite**: On-device machine learning for product identification.
- **ZEGOCLOUD SDK**: Video call functionality.
- **Firebase**: Backend for storing user data and managing community posts.
- **Custom Assets**: Custom images for navigation, designed to assist users with visual impairments.

## Installation
To run this project locally, follow these steps:

1. Clone the repository:
    ```bash
    git clone https://github.com/your-username/repo-name.git
    ```

2. Navigate to the project directory:
    ```bash
    cd repo-name
    ```

3. Install dependencies:
    ```bash
    flutter pub get
    ```

4. Set up Firebase by adding your `google-services.json` for Android and `GoogleService-Info.plist` for iOS in the respective directories.

5. Run the app on your device or emulator:
    ```bash
    flutter run
    ```

## Usage
- **Product Identification**: Tap the "Scan Product" button in the navigation bar, point your device's camera at the product, and the app will identify it.
- **Video Calls**: Select a contact and initiate a video call using the integrated ZEGOCLOUD SDK.
- **Community Posts**: Navigate to the community section to create, view, or interact with posts from other users.
- **Emergency Voice Notes**: Record an emergency voice note by pressing the "Emergency" button and share it quickly.

## Screenshots
Click the thumbnails to view full-size images.

<p align="center">
    <img src="https://github.com/user-attachments/assets/a31a28e4-7cfc-4ea8-9821-f3814247ee55" alt="Screenshot_1" width="150" />
    <img src="https://github.com/user-attachments/assets/4c8e9c79-9eef-4838-b0c0-123efef4f49e" alt="Screenshot_2" width="150" />
    <img src="https://github.com/user-attachments/assets/bc170c4b-1343-491a-b913-c0d48a275156" alt="Screenshot_3" width="150" />
    <img src="https://github.com/user-attachments/assets/54249190-beec-4371-aae2-ae2ec7d6c9fc" alt="Screenshot_4" width="150" />
    <img src="https://github.com/user-attachments/assets/59c892a4-74ee-44ac-9113-2f1e428d1c4c" alt="Screenshot_5" width="150" />
    <img src="https://github.com/user-attachments/assets/0fbecbd0-f053-466d-9fb7-3451afe3d6a9" alt="Screenshot_6" width="150" />
    <img src="https://github.com/user-attachments/assets/635866f8-db9e-4321-b78b-e04a010aa94b" alt="Screenshot_7" width="150" />
</p>

## Screen Record
Download the screen record of the app [here](https://github.com/user-attachments/files/17276375/1007.zip).

## Contributing
We welcome contributions to enhance the app. Please follow these steps to contribute:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes.
4. Commit and push to your fork.
5. Create a pull request to the main repository.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
