#  SwiftESCL

I needed a Swift implementation of the eSCL protocol for another project and I now want to open source this.

## Using the API

I tried my best document the code, so I recommend to just try using it. I'll still try to describe the most basic tasks here.
I recommend to have the documentation for the actual eSCL protocol handy while working with this. You can find it [here](https://mopria.org/spec-download).

The basic procedure for using eSCL basically consists of four steps:
1. Discover the device using Bonjour(aka zeroconf)
2. Query the devices capabilities and status
3. POST an XML file containing your order to the device
4. GET your results

With my implementation, the procedure is as follows:

### 0. Adding the package as a dependency to your project

Open the Package Dependencies tab of your project configuration and click the "+" to add a dependency.
[Image1]
Now paste the link to this page (https://github.com/LeoKlaus/SwiftESCL) in the search box and click on "Add Package". You may want to include a certain tag to prevent updates to the package from breaking your code.
[Image2]
Click on "Add Package" once more and wait for XCode to download the package.

### 1. Discovering devices

Create an instance of Browser() and a Dictionary to contain the results:
```swift

import SwiftESCL

let browser = SwiftESCL.Browser()
// The string contains the hostname of the device, which should be sufficient to uniquely identify it.
@State var discoveredDevices: [String:SwiftESCL.ScannerRepresentation] = [:]
// As the discovery runs asynchronously, it's easiest to just pass the dictionary as binding
browser.setDevices(scanners: $discoveredDevices)
// Now you just have to start the browser to discover devices:
browser.start()
// Keep in mind that the start() function runs asynchronously, discoveredDevices is still empty at this point.
// It makes sense to call browser.start() on view load or by press of a button and have the user wait for device discovery
```

### 2. Querying capabilities and status of a device

Create an instance of eSCLScanner() and use the methods getCapabilities() and getStatus():
```swift
// Let's just access the first device found
let scannerRep = discoveredDevices.values.first!
let scanner = SwiftESCL.esclScanner(ip: scannerRep.hostname, root: scannerRep.root)
// From V1.2 on, every esclScanner object queries its capabilities on initialisation. Capabilities are stored in the public variable scanner.
// You can now browse your scanners capabilities:
print(scanner.scanner.sourceCapabilities.keys)
// This will print an array containing all source supported by your scanner, for example:
// ["Adf", "Platen"]
print(scanner.scanner.sourceCapabilities["Adf"]?.discreteResolutions)
// Would list all resolutions supported by your scanners ADF, for example:
// [100, 200, 300, 600]

// Status is now most likely "Idle"
let status = scanner.getStatus()
```

### 3. POSTing a scan request

Use the sendPostRequest method to create a POST request:
```swift
let (responseURL, postResponseCode) = scanner.sendPostRequest(resolution: 300, format: "application/pdf", source: "Platen", width: 2480, height: 3508)
// responseURL contains the URL to the document on the scanner, this is where you will derict your GET request to.
// postResponseCode should be 201 (CREATED). If it isn't, there's likely an invalid mix of options and the scanner returned 409 (CONFLICT)
```

### 4. GETting your results

Use the method sendGetRequest to retrieve your image:
```swift
let (imageData, getResponseCode) = scanner.sendGetRequest(uri: responseURL)
```

There's also a method scanDocument(), which takes the same parameters as sendPostRequest() but executes both the POST and GET requests. It returns the binary data of the scanned image and the latest responseCode (which should be 200):
```swift
let (imageData, responseCode) = scanner.scanDocument(resolution: 300, format: "application/pdf", version: capabilities.version, source: "Platen", width: 2480, height: 3508)
// Now you can do with that data whatever you like. In most cases, it's probably a good idea to store the data on disk.
// For that exact case, there's another method scanDocumentAndSaveFile(), which takes the same parameters as sendPostRequest() but returns a URL to the file on disk instead of the data.
// The file is saved to the root of the documents directory of the app by default, a custom path can be specified using the filePath parameter though.
```

If you're stuck, feel free to create an Issue.
