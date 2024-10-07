# Shopping Assistant for Visually Impaired Users

A Flutter-based mobile application designed to improve the shopping experience for partially visually impaired individuals. This app integrates various accessibility features, including product identification using TensorFlow Lite, video calling using ZEGOCLOUD, and the ability to create community posts and record emergency voice notes.

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
- **TensorFlow Lite**: For on-device machine learning and product identification.
- **ZEGOCLOUD SDK**: For video call functionality.
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
- **Product Identification**: Tap on the "Scan Product" button in the navigation bar, point your device's camera at the product, and let the app identify it.
- **Video Calls**: Select a contact and initiate a video call using the integrated ZEGOCLOUD SDK.
- **Community Posts**: Navigate to the community section to create, view, or interact with posts from other users.
- **Emergency Voice Notes**: Record an emergency voice note by pressing the "Emergency" button and share it quickly.

## Screenshots
Add screenshots of your app in this section to showcase the UI and features.

## Contributing
We welcome contributions to enhance the app. Please follow these steps to contribute:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes.
4. Commit and push to your fork.
5. Create a pull request to the main repository.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
