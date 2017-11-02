//
//  ViewController.swift
//  HowToUseCamera1
//
//  Created by Jing Wang on 11/1/17.
//  Copyright © 2017 figur8. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var cameraView: UIView!
    
    var captureSession = AVCaptureSession()
    var videoOutput = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var settings = AVCapturePhotoSettings()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cameraView.layer.cornerRadius = cameraView.frame.size.width/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Change the shape of cameraView to circular
        cameraView.layer.cornerRadius = cameraView.frame.size.width/2
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            
            captureSession.startRunning()
            
                        settings.isAutoStillImageStabilizationEnabled = true
                        settings.flashMode = .off
            
//            let settings = AVCapturePhotoSettings()
//            let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
//            let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType, kCVPixelBufferWidthKey as String: 160, kCVPixelBufferHeightKey as String: 160]
//            settings.previewPhotoFormat = previewFormat

            

//
//            let desiredPreviewPixelFormat = NSNumber(value: kCVPixelFormatType_32BGRA)
//            if settings.availablePreviewPhotoPixelFormatTypes.contains(desiredPreviewPixelFormat) {
//                settings.previewPhotoFormat = [
//                    kCVPixelBufferPixelFormatTypeKey as String : desiredPreviewPixelFormat,
//                    kCVPixelBufferWidthKey as String : NSNumber(value: 512),
//                    kCVPixelBufferHeightKey as String : NSNumber(value: 512)
//                ]
//            }
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
//                videoOutput.photoSettingsForSceneMonitoring
            
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer.connection.videoOrientation = .landscapeRight
            cameraView.layer.addSublayer(previewLayer)
            previewLayer.position = CGPoint(x: self.cameraView.frame.width/2, y: self.cameraView.frame.height/2)
            previewLayer.bounds = cameraView.frame
                
            }
            
        }
        catch {
            print("Fail to initialize device!")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    func capture(_ output: AVCapturePhotoOutput, didFinishCaptureForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
//        print("Here we go!")
//    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {

        
                // Method #1
        // Make sure we get some photo sample buffer
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
                print("Error capturing photo: \(String(describing: error))")
                return
        }
        // Convert photo same buffer to a jpeg image data by using AVCapturePhotoOutput
        guard let imageData =
            AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
                print("Fail to convert image to JPEG")
                return
        }


        // Initialize a UIImage with image data
        
        guard let capturedImage = UIImage.init(data: imageData , scale: 1.0) else {
            print("Fail to convert image data to UIImage")
            return
        }
        
        // Get original image width/height
        let imgWidth = capturedImage.size.width
        let imgHeight = capturedImage.size.height
        // Get origin of cropped image
        let imgOrigin = CGPoint(x: (imgWidth - imgHeight)/2, y: (imgHeight - imgHeight)/2)
        // Get size of cropped iamge
        let imgSize = CGSize(width: imgHeight, height: imgHeight)
        
        // Get cropped image ref
        guard let imageRef = capturedImage.cgImage?.cropping(to: CGRect(origin: imgOrigin, size: imgSize)) else {
            print("Fail to crop image")
            return
        }
        
        // Convert cropped image ref to UIImage
        let imageToSave = UIImage(cgImage: imageRef, scale: 1.0, orientation: .down)
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        
        // Stop video capturing session
        captureSession.stopRunning()

    }
    
    @IBAction func TakePhoto(_ sender: UIButton) {
        if let videoConnection = videoOutput.connection(withMediaType: AVMediaTypeVideo) {
        let capturePhotoSetting = AVCapturePhotoSettings.init(from: settings)
            videoConnection.videoOrientation = previewLayer.connection.videoOrientation
            self.videoOutput.capturePhoto(with: capturePhotoSetting, delegate: self)
        }
    }
    
    @IBAction func ReTakePhoto(_ sender: UIButton) {
        //Restart video capturing session
        captureSession.startRunning()
    }
    
}



