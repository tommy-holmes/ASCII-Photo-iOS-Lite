# ASCII-Photo-iOS-Lite
A watered down version of my ASCII Photo iOS app. I intend to use this project to sell myself to teams of iOS engineers for their own assessment of my skills as a developer, basically a "tech test". 

## Assessment info
- 100% SwiftUI
- Unit tests included for the `ImageModel`
- iOS 16+ (to allow for the use of newer APIs and tools such as [Transferable](https://developer.apple.com/documentation/coretransferable/transferable))
- Mainly uses architecture that SwiftUI enforces, i.e. Models are closely tied to Views via `StateObject` which react to changes in `Published` values and propergated through the `environment` and any lower level processing (such as the image generation algorithm) are isolated and _only_ the Model can directly interact with it
- Implements async-await in the `Camera` object for assessing permissions, recieving image steams and processing captured photos.  

## Features
- [x] Camera
- [x] Photo library 
- [x] Drag and drop
- [x] Copy generated art to clipboard 
- [x] Image preview
- [x] Generated art inversion
- [x] Light and dark mode support
- [ ] Convert generated art to image
- [ ] Better UI and UX for art preview
