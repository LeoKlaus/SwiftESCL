//
//  XmlParsingTests.swift
//  SwiftESCL
//
//  Created by Leo Wehrfritz on 20.01.25.
//

import Testing
import Foundation
@testable import SwiftESCL

@Test func decodeESCLScannerCapabilities() async throws {
    let xmlData = """
<?xml version="1.0" encoding="UTF-8"?>
<!-- THIS DATA SUBJECT TO DISCLAIMER(S) INCLUDED WITH THE PRODUCT OF
ORIGIN. -->
<scan:ScannerCapabilities xmlns:scan="http://schemas.hp.com/imaging/escl/2011/05/03" xmlns:pwg="http://www.pwg.org/schemas/2010/12/sm" xmlns:dest="http://schemas.hp.com/imaging/destination/2011/06/06" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.hp.com/imaging/escl/2011/05/03../../schemas/eSCL.xsd">
  <pwg:Version>2.5</pwg:Version>
  <pwg:MakeAndModel>OfficeJet Pro 6978 All-in-One</pwg:MakeAndModel>
  <pwg:SerialNumber>TH7....047</pwg:SerialNumber>
  <scan:Platen>
    <scan:PlatenInputCaps>
      <scan:MinWidth>8</scan:MinWidth>
      <scan:MaxWidth>2550</scan:MaxWidth>
      <scan:MinHeight>8</scan:MinHeight>
      <scan:MaxHeight>3550</scan:MaxHeight>
      <scan:MinPageWidth>8</scan:MinPageWidth>
      <scan:MinPageHeight>8</scan:MinPageHeight>
      <scan:MaxScanRegions>1</scan:MaxScanRegions>
      <scan:SettingProfiles>
        <scan:SettingProfile>
          <scan:ColorModes>
            <scan:ColorMode>Grayscale8</scan:ColorMode>
            <scan:ColorMode>RGB24</scan:ColorMode>
          </scan:ColorModes>
          <scan:ContentTypes>
            <pwg:ContentType>Photo</pwg:ContentType>
            <pwg:ContentType>Text</pwg:ContentType>
            <pwg:ContentType>TextAndPhoto</pwg:ContentType>
          </scan:ContentTypes>
          <scan:DocumentFormats>
            <pwg:DocumentFormat>application/octet-stream</pwg:DocumentFormat>
            <pwg:DocumentFormat>image/jpeg</pwg:DocumentFormat>
            <pwg:DocumentFormat>application/pdf</pwg:DocumentFormat>
            <scan:DocumentFormatExt>application/octet-stream</scan:DocumentFormatExt>
            <scan:DocumentFormatExt>image/jpeg</scan:DocumentFormatExt>
            <scan:DocumentFormatExt>application/pdf</scan:DocumentFormatExt>
          </scan:DocumentFormats>
          <scan:SupportedResolutions>
            <scan:DiscreteResolutions>
              <scan:DiscreteResolution>
                <scan:XResolution>75</scan:XResolution>
                <scan:YResolution>75</scan:YResolution>
              </scan:DiscreteResolution>
              <scan:DiscreteResolution>
                <scan:XResolution>100</scan:XResolution>
                <scan:YResolution>100</scan:YResolution>
              </scan:DiscreteResolution>
              <scan:DiscreteResolution>
                <scan:XResolution>200</scan:XResolution>
                <scan:YResolution>200</scan:YResolution>
              </scan:DiscreteResolution>
              <scan:DiscreteResolution>
                <scan:XResolution>300</scan:XResolution>
                <scan:YResolution>300</scan:YResolution>
              </scan:DiscreteResolution>
              <scan:DiscreteResolution>
                <scan:XResolution>600</scan:XResolution>
                <scan:YResolution>600</scan:YResolution>
              </scan:DiscreteResolution>
              <scan:DiscreteResolution>
                <scan:XResolution>1200</scan:XResolution>
                <scan:YResolution>1200</scan:YResolution>
              </scan:DiscreteResolution>
            </scan:DiscreteResolutions>
          </scan:SupportedResolutions>
          <scan:ColorSpaces>
            <scan:ColorSpace>YCC</scan:ColorSpace>
            <scan:ColorSpace>RGB</scan:ColorSpace>
            <scan:ColorSpace>sRGB</scan:ColorSpace>
          </scan:ColorSpaces>
        </scan:SettingProfile>
      </scan:SettingProfiles>
      <scan:SupportedIntents>
        <scan:Intent>Document</scan:Intent>
        <scan:Intent>Photo</scan:Intent>
        <scan:Intent>Preview</scan:Intent>
        <scan:Intent>TextAndGraphic</scan:Intent>
      </scan:SupportedIntents>
      <scan:MaxOpticalXResolution>1200</scan:MaxOpticalXResolution>
      <scan:MaxOpticalYResolution>1200</scan:MaxOpticalYResolution>
      <scan:RiskyLeftMargin>50</scan:RiskyLeftMargin>
      <scan:RiskyRightMargin>18</scan:RiskyRightMargin>
      <scan:RiskyTopMargin>50</scan:RiskyTopMargin>
      <scan:RiskyBottomMargin>15</scan:RiskyBottomMargin>
    </scan:PlatenInputCaps>
  </scan:Platen>
  <scan:Adf>
    <scan:AdfSimplexInputCaps>
      <scan:MinWidth>8</scan:MinWidth>
      <scan:MaxWidth>2550</scan:MaxWidth>
      <scan:MinHeight>8</scan:MinHeight>
      <scan:MaxHeight>4200</scan:MaxHeight>
      <scan:MinPageWidth>1748</scan:MinPageWidth>
      <scan:MinPageHeight>2480</scan:MinPageHeight>
      <scan:MaxScanRegions>1</scan:MaxScanRegions>
      <scan:SettingProfiles>
        <scan:SettingProfile>
          <scan:ColorModes>
            <scan:ColorMode>Grayscale8</scan:ColorMode>
            <scan:ColorMode>RGB24</scan:ColorMode>
          </scan:ColorModes>
          <scan:ContentTypes>
            <pwg:ContentType>Photo</pwg:ContentType>
            <pwg:ContentType>Text</pwg:ContentType>
            <pwg:ContentType>TextAndPhoto</pwg:ContentType>
          </scan:ContentTypes>
          <scan:DocumentFormats>
            <pwg:DocumentFormat>application/octet-stream</pwg:DocumentFormat>
            <pwg:DocumentFormat>image/jpeg</pwg:DocumentFormat>
            <pwg:DocumentFormat>application/pdf</pwg:DocumentFormat>
            <scan:DocumentFormatExt>application/octet-stream</scan:DocumentFormatExt>
            <scan:DocumentFormatExt>image/jpeg</scan:DocumentFormatExt>
            <scan:DocumentFormatExt>application/pdf</scan:DocumentFormatExt>
          </scan:DocumentFormats>
          <scan:SupportedResolutions>
            <scan:DiscreteResolutions>
              <scan:DiscreteResolution>
                <scan:XResolution>75</scan:XResolution>
                <scan:YResolution>75</scan:YResolution>
              </scan:DiscreteResolution>
              <scan:DiscreteResolution>
                <scan:XResolution>100</scan:XResolution>
                <scan:YResolution>100</scan:YResolution>
              </scan:DiscreteResolution>
              <scan:DiscreteResolution>
                <scan:XResolution>200</scan:XResolution>
                <scan:YResolution>200</scan:YResolution>
              </scan:DiscreteResolution>
              <scan:DiscreteResolution>
                <scan:XResolution>300</scan:XResolution>
                <scan:YResolution>300</scan:YResolution>
              </scan:DiscreteResolution>
            </scan:DiscreteResolutions>
          </scan:SupportedResolutions>
          <scan:ColorSpaces>
            <scan:ColorSpace>YCC</scan:ColorSpace>
            <scan:ColorSpace>RGB</scan:ColorSpace>
            <scan:ColorSpace>sRGB</scan:ColorSpace>
          </scan:ColorSpaces>
        </scan:SettingProfile>
      </scan:SettingProfiles>
      <scan:SupportedIntents>
        <scan:Intent>Document</scan:Intent>
        <scan:Intent>Photo</scan:Intent>
        <scan:Intent>Preview</scan:Intent>
        <scan:Intent>TextAndGraphic</scan:Intent>
      </scan:SupportedIntents>
      <scan:EdgeAutoDetection>
        <scan:SupportedEdge>BottomEdge</scan:SupportedEdge>
      </scan:EdgeAutoDetection>
      <scan:MaxOpticalXResolution>300</scan:MaxOpticalXResolution>
      <scan:MaxOpticalYResolution>300</scan:MaxOpticalYResolution>
      <scan:RiskyLeftMargin>16</scan:RiskyLeftMargin>
      <scan:RiskyRightMargin>0</scan:RiskyRightMargin>
      <scan:RiskyTopMargin>35</scan:RiskyTopMargin>
      <scan:RiskyBottomMargin>35</scan:RiskyBottomMargin>
    </scan:AdfSimplexInputCaps>
    <scan:AdfDuplexInputCaps>
      <scan:MinWidth>1748</scan:MinWidth>
      <scan:MaxWidth>2550</scan:MaxWidth>
      <scan:MinHeight>2480</scan:MinHeight>
      <scan:MaxHeight>3507</scan:MaxHeight>
      <scan:MinPageWidth>1748</scan:MinPageWidth>
      <scan:MinPageHeight>2480</scan:MinPageHeight>
      <scan:MaxScanRegions>1</scan:MaxScanRegions>
      <scan:SettingProfiles>
        <scan:SettingProfile>
          <scan:ColorModes>
            <scan:ColorMode>Grayscale8</scan:ColorMode>
            <scan:ColorMode>RGB24</scan:ColorMode>
          </scan:ColorModes>
          <scan:ContentTypes>
            <pwg:ContentType>Photo</pwg:ContentType>
            <pwg:ContentType>Text</pwg:ContentType>
            <pwg:ContentType>TextAndPhoto</pwg:ContentType>
          </scan:ContentTypes>
          <scan:DocumentFormats>
            <pwg:DocumentFormat>application/octet-stream</pwg:DocumentFormat>
            <pwg:DocumentFormat>image/jpeg</pwg:DocumentFormat>
            <pwg:DocumentFormat>application/pdf</pwg:DocumentFormat>
            <scan:DocumentFormatExt>application/octet-stream</scan:DocumentFormatExt>
            <scan:DocumentFormatExt>image/jpeg</scan:DocumentFormatExt>
            <scan:DocumentFormatExt>application/pdf</scan:DocumentFormatExt>
          </scan:DocumentFormats>
          <scan:SupportedResolutions>
            <scan:DiscreteResolutions>
              <scan:DiscreteResolution>
                <scan:XResolution>75</scan:XResolution>
                <scan:YResolution>75</scan:YResolution>
              </scan:DiscreteResolution>
              <scan:DiscreteResolution>
                <scan:XResolution>100</scan:XResolution>
                <scan:YResolution>100</scan:YResolution>
              </scan:DiscreteResolution>
              <scan:DiscreteResolution>
                <scan:XResolution>200</scan:XResolution>
                <scan:YResolution>200</scan:YResolution>
              </scan:DiscreteResolution>
              <scan:DiscreteResolution>
                <scan:XResolution>300</scan:XResolution>
                <scan:YResolution>300</scan:YResolution>
              </scan:DiscreteResolution>
            </scan:DiscreteResolutions>
          </scan:SupportedResolutions>
          <scan:ColorSpaces>
            <scan:ColorSpace>YCC</scan:ColorSpace>
            <scan:ColorSpace>RGB</scan:ColorSpace>
            <scan:ColorSpace>sRGB</scan:ColorSpace>
          </scan:ColorSpaces>
        </scan:SettingProfile>
      </scan:SettingProfiles>
      <scan:SupportedIntents>
        <scan:Intent>Document</scan:Intent>
        <scan:Intent>Photo</scan:Intent>
        <scan:Intent>Preview</scan:Intent>
        <scan:Intent>TextAndGraphic</scan:Intent>
      </scan:SupportedIntents>
      <scan:EdgeAutoDetection>
        <scan:SupportedEdge>BottomEdge</scan:SupportedEdge>
      </scan:EdgeAutoDetection>
      <scan:MaxOpticalXResolution>300</scan:MaxOpticalXResolution>
      <scan:MaxOpticalYResolution>300</scan:MaxOpticalYResolution>
      <scan:RiskyLeftMargin>16</scan:RiskyLeftMargin>
      <scan:RiskyRightMargin>0</scan:RiskyRightMargin>
      <scan:RiskyTopMargin>35</scan:RiskyTopMargin>
      <scan:RiskyBottomMargin>35</scan:RiskyBottomMargin>
    </scan:AdfDuplexInputCaps>
    <scan:FeederCapacity>50</scan:FeederCapacity>
    <scan:Justification>
      <pwg:XImagePosition>Right</pwg:XImagePosition>
      <pwg:YImagePosition>Top</pwg:YImagePosition>
    </scan:Justification>
    <scan:AdfOptions>
      <scan:AdfOption>DetectPaperLoaded</scan:AdfOption>
      <scan:AdfOption>Duplex</scan:AdfOption>
    </scan:AdfOptions>
  </scan:Adf>
  <scan:BrightnessSupport>
    <scan:Min>0</scan:Min>
    <scan:Max>2000</scan:Max>
    <scan:Normal>1000</scan:Normal>
    <scan:Step>1</scan:Step>
  </scan:BrightnessSupport>
  <scan:ContrastSupport>
    <scan:Min>0</scan:Min>
    <scan:Max>2000</scan:Max>
    <scan:Normal>1000</scan:Normal>
    <scan:Step>1</scan:Step>
  </scan:ContrastSupport>
  <scan:ThresholdSupport>
    <scan:Min>0</scan:Min>
    <scan:Max>255</scan:Max>
    <scan:Normal>128</scan:Normal>
    <scan:Step>1</scan:Step>
  </scan:ThresholdSupport>
  <scan:eSCLConfigCap>
    <scan:StateSupport>
      <scan:State>disabled</scan:State>
      <scan:State>enabled</scan:State>
    </scan:StateSupport>
  </scan:eSCLConfigCap>
  <scan:JobSourceInfoSupport>true</scan:JobSourceInfoSupport>
</scan:ScannerCapabilities>
""".data(using: .utf8)!
    
    let capabilities = try EsclScannerCapabilities(xmlData: xmlData)
    
    #expect(capabilities.version == "2.5")
    #expect(capabilities.makeAndModel == "OfficeJet Pro 6978 All-in-One")
    #expect(capabilities.serialNumber == "TH7....047")
    
    guard let platenCaps = capabilities.sourceCapabilities[.platen] else {
        Issue.record("Platen Capabilities Missing")
        return
    }
    
    #expect(platenCaps.minWidth == 8)
    #expect(platenCaps.maxWidth == 2550)
    #expect(platenCaps.minHeight == 8)
    #expect(platenCaps.maxHeight == 3550)
    #expect(platenCaps.minPageWidth == 8)
    #expect(platenCaps.minPageHeight == 8)
    #expect(platenCaps.maxScanRegions == 1)
    
    #expect(platenCaps.colorModes == [.grayscale8, .rgb24])
    #expect(platenCaps.contentTypes == [.photo, .text, .textAndPhoto])
    
    #expect(platenCaps.documentFormats.contains(.data))
    #expect(platenCaps.documentFormats.contains(.pdf))
    #expect(platenCaps.documentFormats.contains(.jpeg))
    
    #expect(platenCaps.supportedResolutions == [75, 100, 200, 300, 600, 1200])
    
    #expect(platenCaps.colorSpaces == [.unknown("YCC"), .unknown("RGB"), .sRGB])
    
    #expect(platenCaps.supportedIntents == [.document, .photo, .preview, .textAndGraphic])
    
    #expect(platenCaps.maxOpticalXResolution == 1200)
    #expect(platenCaps.maxOpticalYResolution == 1200)
    
    #expect(platenCaps.riskyLeftMargin == 50)
    #expect(platenCaps.riskyRightMargin == 18)
    #expect(platenCaps.riskyTopMargin == 50)
    #expect(platenCaps.riskyBottomMargin == 15)
    
    guard let adfSimplexCaps = capabilities.sourceCapabilities[.adf] else {
        Issue.record("ADF Capabilities Missing")
        return
    }
    
    #expect(adfSimplexCaps.minWidth == 8)
    #expect(adfSimplexCaps.maxWidth == 2550)
    #expect(adfSimplexCaps.minHeight == 8)
    #expect(adfSimplexCaps.maxHeight == 4200)
    #expect(adfSimplexCaps.minPageWidth == 1748)
    #expect(adfSimplexCaps.minPageHeight == 2480)
    #expect(adfSimplexCaps.maxScanRegions == 1)
    
    #expect(adfSimplexCaps.colorModes == [.grayscale8, .rgb24])
    #expect(adfSimplexCaps.contentTypes == [.photo, .text, .textAndPhoto])
    
    #expect(adfSimplexCaps.documentFormats.contains(.data))
    #expect(adfSimplexCaps.documentFormats.contains(.pdf))
    #expect(adfSimplexCaps.documentFormats.contains(.jpeg))
    
    #expect(adfSimplexCaps.supportedResolutions == [75, 100, 200, 300])
    
    #expect(adfSimplexCaps.colorSpaces == [.unknown("YCC"), .unknown("RGB"), .sRGB])
    
    #expect(adfSimplexCaps.supportedIntents == [.document, .photo, .preview, .textAndGraphic])
    
    #expect(adfSimplexCaps.edgeAutoDetection == [.bottom])
    
    #expect(adfSimplexCaps.maxOpticalXResolution == 300)
    #expect(adfSimplexCaps.maxOpticalYResolution == 300)
    
    #expect(adfSimplexCaps.riskyLeftMargin == 16)
    #expect(adfSimplexCaps.riskyRightMargin == 0)
    #expect(adfSimplexCaps.riskyTopMargin == 35)
    #expect(adfSimplexCaps.riskyBottomMargin == 35)
    
    #expect(adfSimplexCaps.feederCapacity == 50)
    #expect(adfSimplexCaps.adfOptions == [.detectPaperLoaded, .duplex])
    
    guard let adfDuplexCaps = capabilities.sourceCapabilities[.adfDuplex] else {
        Issue.record("ADF Capabilities Missing")
        return
    }
    
    #expect(adfDuplexCaps.minWidth == 1748)
    #expect(adfDuplexCaps.maxWidth == 2550)
    #expect(adfDuplexCaps.minHeight == 2480)
    #expect(adfDuplexCaps.maxHeight == 3507)
    #expect(adfDuplexCaps.minPageWidth == 1748)
    #expect(adfDuplexCaps.minPageHeight == 2480)
    #expect(adfDuplexCaps.maxScanRegions == 1)
    
    #expect(adfDuplexCaps.colorModes == [.grayscale8, .rgb24])
    #expect(adfDuplexCaps.contentTypes == [.photo, .text, .textAndPhoto])
    
    #expect(adfDuplexCaps.documentFormats.contains(.data))
    #expect(adfDuplexCaps.documentFormats.contains(.pdf))
    #expect(adfDuplexCaps.documentFormats.contains(.jpeg))
    
    #expect(adfDuplexCaps.supportedResolutions == [75, 100, 200, 300])
    
    #expect(adfDuplexCaps.colorSpaces == [.unknown("YCC"), .unknown("RGB"), .sRGB])
    
    #expect(adfDuplexCaps.supportedIntents == [.document, .photo, .preview, .textAndGraphic])
    
    #expect(adfDuplexCaps.edgeAutoDetection == [.bottom])
    
    #expect(adfDuplexCaps.maxOpticalXResolution == 300)
    #expect(adfDuplexCaps.maxOpticalYResolution == 300)
    
    #expect(adfDuplexCaps.riskyLeftMargin == 16)
    #expect(adfDuplexCaps.riskyRightMargin == 0)
    #expect(adfDuplexCaps.riskyTopMargin == 35)
    #expect(adfDuplexCaps.riskyBottomMargin == 35)
    
    #expect(adfDuplexCaps.feederCapacity == 50)
    #expect(adfDuplexCaps.justification?.xImagePosition == .right)
    #expect(adfSimplexCaps.justification?.yImagePosition == .top)
    #expect(adfDuplexCaps.adfOptions == [.detectPaperLoaded, .duplex])
    
    #expect(capabilities.brightnessSupport == SteppedRange(min: 0, max: 2000, normal: 1000, step: 1))
    #expect(capabilities.contrastSupport == SteppedRange(min: 0, max: 2000, normal: 1000, step: 1))
    #expect(capabilities.thresholdSupport == SteppedRange(min: 0, max: 255, normal: 128, step: 1))
}

@Test func decodeScannerStatus() async throws {
    
    
    let xmlData = """
<?xml version="1.0" encoding="UTF-8"?>
<scan:ScannerStatus xmlns:scan="http://schemas.hp.com/imaging/escl/2011/05/03" xmlns:pwg="http://www.pwg.org/schemas/2010/12/sm">
    <pwg:Version>2.9</pwg:Version>
    <pwg:State>Idle</pwg:State>
    <scan:AdfState>ScannerAdfEmpty</scan:AdfState>
    <scan:Jobs>
        <scan:JobInfo>
            <pwg:JobUuid>1ddea9b5-4de6-42a3-942a-ec1e2ae19968</pwg:JobUuid>
            <pwg:JobUri>/eSCL/ScanJobs/1ddea9b5-4de6-42a3-942a-ec1e2ae19968</pwg:JobUri>
            <scan:Age>4</scan:Age>
            <pwg:ImagesCompleted>1</pwg:ImagesCompleted>
            <pwg:JobState>Completed</pwg:JobState>
        </scan:JobInfo>
        <scan:JobInfo>
            <pwg:JobUuid>9e8914c8-39a9-4702-b79a-195aa3af417d</pwg:JobUuid>
            <pwg:JobUri>/eSCL/ScanJobs/9e8914c8-39a9-4702-b79a-195aa3af417d</pwg:JobUri>
            <scan:Age>1275</scan:Age>
            <pwg:ImagesCompleted>1</pwg:ImagesCompleted>
            <pwg:JobState>Processing</pwg:JobState>
        </scan:JobInfo>
    </scan:Jobs>
</scan:ScannerStatus>
""".data(using: .utf8)!
    
    let scannerStatus = try ScannerStatus(xmlData: xmlData)
    
    #expect(scannerStatus.state == .idle)
    #expect(scannerStatus.version == "2.9")
    #expect(scannerStatus.adfState == .empty)
    
    guard let firstJob = scannerStatus.scanJobs["1ddea9b5-4de6-42a3-942a-ec1e2ae19968"] else {
        Issue.record("First scan job missing")
        return
    }
    #expect(firstJob.jobUuid == "1ddea9b5-4de6-42a3-942a-ec1e2ae19968")
    #expect(firstJob.age == 4)
    #expect(firstJob.imagesCompleted == 1)
    #expect(firstJob.jobState == .completed)
    
    guard let secondJob = scannerStatus.scanJobs["9e8914c8-39a9-4702-b79a-195aa3af417d"] else {
        Issue.record("Second scan job missing")
        return
    }
    #expect(secondJob.jobUuid == "9e8914c8-39a9-4702-b79a-195aa3af417d")
    #expect(secondJob.age == 1275)
    #expect(secondJob.imagesCompleted == 1)
    #expect(secondJob.jobState == .processing)
}

@Test func decodeScanImageInfo() async throws {
    let xmlData = """
<?xml version="1.0" encoding="UTF-8"?>
<scan:ScanImageInfo xsi:schemaLocation="http://schemas.hp.com/imaging/escl/2011/05/03 eSCL.xsd" xmlns:scan="http://schemas.hp.com/imaging/escl/2011/05/03" xmlns:pwg="http://www.pwg.org/schemas/2010/12/sm" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <pwg:JobUri>/eSCL/ScanJobs/1ddea9b5-4de6-42a3-942a-ec1e2ae19968</pwg:JobUri>
    <pwg:JobUuid>1ddea9b5-4de6-42a3-942a-ec1e2ae19968</pwg:JobUuid>
    <scan:ActualWidth>1653</scan:ActualWidth>
    <scan:ActualHeight>2338</scan:ActualHeight>
    <scan:ActualBytesPerLine>4959</scan:ActualBytesPerLine>
</scan:ScanImageInfo>
""".data(using: .utf8)!
    
    let scanImageInfo = try EsclScanImageInfo(xmlData: xmlData)
    
    #expect(scanImageInfo.jobUUID == "1ddea9b5-4de6-42a3-942a-ec1e2ae19968")
    #expect(scanImageInfo.actualWidth == 1653)
    #expect(scanImageInfo.actualHeight == 2338)
    #expect(scanImageInfo.actualBytesPerLine == 4959)
}
