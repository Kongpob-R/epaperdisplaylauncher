# e-paper display launcher

Android launcher designed for e-paper devices to simplified the UI and a build-in cloud books fetcher. This launcher work with public library stand server which provide a website. This will allow user to browse and find the e-books avalible to in the cloud. When user click download buttons, it will send the selected e-book path to a launcher over Web-Socket to be downloaded on the device.

# Software
### Tech Stack
* Web-socket: get action from server and response a status
* http request: download e-books from api
* Android intent: utilize Android devices functionality Ex. open settings or launch apps
* Barcode generator: to generate QR-code for our websites url
* Epubx: read metadata of .epub books
* Flutter: main framework for this android launcher
### Flutter packages
* android_intent_plus: ^3.1.1
* epubx: ^3.0.0
* web_socket_channel: ^2.2.0
* flutter_dotenv: ^5.0.2
* device_info_plus: ^3.2.3
* battery_plus: ^2.1.3
* html: ^0.15.0
* barcode_widget: ^2.0.2

# Installing
### Hardware requirement
* Android 4.4+
* able to download and install .apk / or enable developer mode and install through debuging.
* Pre-install with any books reader app that capable of opening .pdf and .epub
### build launcher to devices options
* build APK and send to devices
* install over development mode
* checkout flutter guide for more info

# Screenshot
<img src="https://drive.google.com/uc?export=view&id=1LqkF7kcUv6WAkxRztyCP1k1c7PKVqW3u" width="200">
<img src="https://drive.google.com/uc?export=view&id=1LlNRkJP8Ew_AkZ6805HodbOVCTecuk7N" width="200">
<img src="https://drive.google.com/uc?export=view&id=1LXL0BQlLHQ3DtJG_miLXEPTRjZ_ADc8F" width="200">
<img src="https://drive.google.com/uc?export=view&id=1LXFbUpODswkaUOgV_UMh_rjpPFbUdbAE" width="200">
<img src="https://drive.google.com/uc?export=view&id=1LR4a9jjIKsL6z4VpxxbQuUtD9t-Q6ql_" width="200">
<img src="https://drive.google.com/uc?export=view&id=1LR_CZcM46gZuBqkXWqGtncpjOiiiO__6" width="200">
