//
//  BookFinderViewController.swift
//  RahimRepo
//
//  Created by vd-rahim on 5/25/18.
//  Copyright © 2018 Rahim. All rights reserved.
//

import UIKit
import CoreMedia
import Vision

class BookFinderViewController: UIViewController, UIImagePickerControllerDelegate {
    
    // Outlets to label and view
    @IBOutlet private weak var predictLabel: UILabel!
    @IBOutlet private weak var previewView: UIView!
    
    let bookImageModelMl = bookImageModel()
    private var videoCapture: VideoCapture!
    private var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVision()
        let spec = VideoSpec(fps: 5, size: CGSize(width: 227, height: 227))
        videoCapture = VideoCapture(cameraType: .back,
                                    preferredSpec: spec,
                                    previewContainer: previewView.layer)
        
        videoCapture.imageBufferHandler = {[unowned self] (imageBuffer) in
            self.handleImageBufferWithVision(imageBuffer: imageBuffer)
        }
    }
    
    func handleImageBufferWithCoreML(imageBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(imageBuffer) else {
            return
        }
        do {
            let prediction = try self.bookImageModelMl.prediction(data: self.resize(pixelBuffer: pixelBuffer)!)
            DispatchQueue.main.async {
                if let prob = prediction.loss[prediction.classLabel] {
                    if prob>0.3{
                        self.predictLabel.text = "\(prediction.classLabel) \(String(describing: prob))"
                        ApiService.fetchBooks(with: prediction.classLabel, completion: { (bookModel:[BookDetailModel]!) in
                            
                        })
                    }
                }
            }
        }
        catch let error as NSError {
            fatalError("Unexpected error ocurred: \(error.localizedDescription).")
        }
    }
    
    func handleImageBufferWithVision(imageBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(imageBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let cameraIntrinsicData = CMGetAttachment(imageBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics:cameraIntrinsicData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: UInt32(self.exifOrientationFromDeviceOrientation))!, options: requestOptions)
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: bookImageModelMl.model) else {
            fatalError("can't load Vision ML model")
        }
        let classificationRequest = VNCoreMLRequest(model: visionModel) { (request: VNRequest, error: Error?) in
            guard let observations = request.results else {
                print("no results:\(error!)")
                return
            }
            
            let classifications = observations[0...4]
                .flatMap({ $0 as? VNClassificationObservation })
                .filter({ $0.confidence > 0.3 })
                .map({ "\($0.identifier) \($0.confidence)" })
            DispatchQueue.main.async {
                self.predictLabel.text = classifications.joined(separator: "\n")
                var nameArray = classifications.first?.split(separator: " ")
                nameArray?.removeLast()
                if let count = nameArray?.count{
                    if count > 0 {
                        let name = (nameArray! as NSArray).componentsJoined(by: " ")
                        if (name != nil) {
                            self.videoCapture.stopCapture()
                            ApiService.fetchBooks(with: name, completion: { (bookModel:[BookDetailModel]!) in
                                let vc = BookDetailView(nibName:"BookDetailView" , bundle: nil)
                                vc.bookDetails = bookModel
                                vc.delegate = self
                                vc.modalPresentationStyle = .overCurrentContext
                                self.present(vc, animated: true, completion: nil)
                                
                            })
                        }
                    }
                }
            }
        }
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        
        self.requests = [classificationRequest]
    }
    
    
    /// only support back camera
    var exifOrientationFromDeviceOrientation: Int32 {
        let exifOrientation: DeviceOrientation
        enum DeviceOrientation: Int32 {
            case top0ColLeft = 1
            case top0ColRight = 2
            case bottom0ColRight = 3
            case bottom0ColLeft = 4
            case left0ColTop = 5
            case right0ColTop = 6
            case right0ColBottom = 7
            case left0ColBottom = 8
        }
        switch UIDevice.current.orientation {
        case .portraitUpsideDown:
            exifOrientation = .left0ColBottom
        case .landscapeLeft:
            exifOrientation = .top0ColLeft
        case .landscapeRight:
            exifOrientation = .bottom0ColRight
        default:
            exifOrientation = .right0ColTop
        }
        return exifOrientation.rawValue
    }
    
    
    /// resize CVPixelBuffer
    ///
    /// - Parameter pixelBuffer: CVPixelBuffer by camera output
    /// - Returns: CVPixelBuffer with size (227, 227)
    func resize(pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        let imageSide = 227
        var ciImage = CIImage(cvPixelBuffer: pixelBuffer, options: nil)
        let transform = CGAffineTransform(scaleX: CGFloat(imageSide) / CGFloat(CVPixelBufferGetWidth(pixelBuffer)), y: CGFloat(imageSide) / CGFloat(CVPixelBufferGetHeight(pixelBuffer)))
        ciImage = ciImage.transformed(by: transform).cropped(to: CGRect(x: 0, y: 0, width: imageSide, height: imageSide))
        let ciContext = CIContext()
        var resizeBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, imageSide, imageSide, CVPixelBufferGetPixelFormatType(pixelBuffer), nil, &resizeBuffer)
        ciContext.render(ciImage, to: resizeBuffer!)
        return resizeBuffer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let videoCapture = videoCapture else {return}
        videoCapture.startCapture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let videoCapture = videoCapture else {return}
        videoCapture.resizePreview()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let videoCapture = videoCapture else {return}
        videoCapture.stopCapture()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension BookFinderViewController: BookDetailViewDelegate{
    func dismissingView() {
        self.videoCapture.startCapture()
    }
    
    
}
