//
//  PhotoTimer.swift
//  UnifyChallenge
//
//  Created by Gungor Basa on 5/28/17.
//  Copyright © 2017 Gungor Basa. All rights reserved.
//

import UIKit
import AVFoundation


protocol ImageRetrieveProtocol {
    func didImagesTaken(names: [String])
}

class PhotoTimerViewController: UIViewController {
    
    var captureSession = AVCaptureSession();
    var sessionOutput = AVCapturePhotoOutput();
    var sessionOutputSetting = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecJPEG]);
    var previewLayer = AVCaptureVideoPreviewLayer();
    var photoTimer: Timer?
    var counter = 0
    var capturedImages = [UIImage]()
    var photoIds = [String]()
    var delegate: ImageRetrieveProtocol?
    
    @IBOutlet var videPreviewView: UIView!
    
    @IBOutlet var cameraView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createCamera()
        captureSession.startRunning()
        photoTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(PhotoTimerViewController.capturePhoto), userInfo: nil, repeats: true)
    }
}

// AVCaptureDelegate and required camera functions
extension PhotoTimerViewController: AVCapturePhotoCaptureDelegate {
    func createCamera() {
        let deviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInDualCamera, AVCaptureDeviceType.builtInTelephotoCamera,AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: AVCaptureDevicePosition.front)
        for device in (deviceDiscoverySession?.devices)! {
            if(device.position == AVCaptureDevicePosition.front){
                do{
                    let input = try AVCaptureDeviceInput(device: device)
                    if(captureSession.canAddInput(input)){
                        captureSession.addInput(input);
                        
                        if(captureSession.canAddOutput(sessionOutput)){
                            captureSession.addOutput(sessionOutput);
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
                            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                            previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait;
                            previewLayer.frame = cameraView.frame
                            cameraView.layer.addSublayer(previewLayer);
                        }
                    }
                }
                catch{
                    print("exception!");
                }
            }
        }
    }
    
    
    func capturePhoto() {
        
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat
        self.sessionOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            
            if let capturedImage = UIImage(data: dataImage) {
                let uniqueId = String(dataImage.hashValue)
                photoIds.append(uniqueId)
                let status = SecureDataAdapter.save(key: uniqueId, data: dataImage)
                if status == OSStatus.allZeros {
                    self.counter += 1
                    self.capturedImages.append(capturedImage)
                    if self.counter == 10 {
                        self.photoTimer?.invalidate()
                        delegate?.didImagesTaken(names: self.photoIds)
                        captureSession.stopRunning()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
            }
            
        }
        
    }
}
