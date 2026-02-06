# JoyModels UI
Client desktop and mobile applications for JoyModels written in Flutter for a university project. Mobile app supports Android, while the desktop client application supports Windows and Linux.

## Getting Started

### Prerequisites

Before either clients can be used, the [common API backend](https://github.com/R3FA/joymodels-api) must be setup. 

Currently no binaries are provided, so the project must be compiled and used from source. To start, Flutter must be installed and configured for your system as per the [official docs](https://docs.flutter.dev/get-started/install).

Additonally, if on Linux, the following dependencies must be installed. An example for Arch based systems is:
```bash
sudo pacman -S libsecret
```

### Credentials

For test purposes, the API backend provides some test accounts for the client applications.

### Warning: Root and Admin accounts can be used for desktop and mobile application, while regular accounts with user credentials are only for mobile application.

```bash
# Root account
Username: root1
Password: strinG1!

#Another root account
Username: root2
Password: strinG1!

# Admin account
Username: admin1
Password: strinG1!

# Another admin account
Username: admin2
Password: strinG1!

# Normal user account
Username: user1
Password: strinG1!

# Another normal user account
Username: user2
Password: strinG1!

# Another normal user account
Username: user3
Password: strinG1!

# Another normal user account
Username: user4
Password: strinG1!
```

### Setup

Clone the repository
```bash
git clone https://github.com/R3FA/joymodels-ui.git
```

Install all required dependencies
```bash
flutter pub get
```

To run a client, change into the respective directory (joymodels_desktop or joymodels_mobile) and run the following
```bash
flutter run # Debug mode
flutter run --release # Release mode
```

For the mobile client, you obviously must have a physical device connected or a VM up and running.
