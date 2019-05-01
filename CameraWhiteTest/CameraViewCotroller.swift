import UIKit
import AVFoundation

class CameraViewCotroller: UIViewController {
  @IBOutlet weak var photoPreview: UIView!
  
  var session: AVCaptureSession?
  var stillImageOutput: AVCaptureStillImageOutput?
  var videoPreviewLayer: AVCaptureVideoPreviewLayer?
  var backCamera : AVCaptureDevice?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    session = AVCaptureSession()
    session!.sessionPreset = AVCaptureSession.Preset.photo
    
    backCamera =  AVCaptureDevice.default(for: AVMediaType.video)

    var error: NSError?
    var input: AVCaptureDeviceInput!
    do {
      input = try AVCaptureDeviceInput(device: backCamera!)
    } catch let error1 as NSError {
      error = error1
      input = nil
      print(error!.localizedDescription)
    }
    if error == nil && session!.canAddInput(input) {
      session!.addInput(input)
      stillImageOutput = AVCaptureStillImageOutput()
      stillImageOutput?.outputSettings = [AVVideoCodecKey:  AVVideoCodecType.jpeg]
      if session!.canAddOutput(stillImageOutput!) {
        session!.addOutput(stillImageOutput!)
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session!)
        videoPreviewLayer!.videoGravity =    AVLayerVideoGravity.resizeAspect
        videoPreviewLayer!.connection?.videoOrientation =   AVCaptureVideoOrientation.portrait
        photoPreview.layer.addSublayer(videoPreviewLayer!)
        session!.startRunning()
      }else{
        print("something went wrong")
      }
      do {
        try backCamera?.lockForConfiguration()
      }catch{
          print("there was an error")
        return
      }
      
      
      
//      backCamera?.setWhiteBalanceModeLocked(with: AVCaptureDevice.WhiteBalanceGains(redGain: 0.0, greenGain: 0.0, blueGain: 0.0))
      
      
      
    }else{
      print("something went wrong")
    }
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    videoPreviewLayer!.frame = photoPreview.bounds
  }
  
  @IBAction func pressedTakePhoto(_ sender: Any) {
    if let device = backCamera {
      do {
        try device.lockForConfiguration()
        device.whiteBalanceMode = .continuousAutoWhiteBalance
        print("current white balance is \(device.deviceWhiteBalanceGains)")
      }catch{
        print("error")
      }
    }
    
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("the user touched")
    let screenSize = photoPreview.bounds.size
    if let touchPoint = touches.first {
      let x = touchPoint.location(in: photoPreview).y / screenSize.height
      let y = 1.0 - touchPoint.location(in: photoPreview).x / screenSize.width
      let focusPoint = CGPoint(x: x, y: y)
      
      if let device = backCamera {
        do {
          try device.lockForConfiguration()
          
          device.focusPointOfInterest = focusPoint
          //device.focusMode = .continuousAutoFocus
          device.focusMode = .autoFocus
          //device.focusMode = .locked
          
          device.exposurePointOfInterest = focusPoint
          device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
          
          
          let gains: AVCaptureDevice.WhiteBalanceGains = AVCaptureDevice.currentWhiteBalanceGains
          backCamera?.setWhiteBalanceModeLocked(with: gains, completionHandler:nil)
          
          device.unlockForConfiguration()
          print("current white balance is \(backCamera?.deviceWhiteBalanceGains)")
        }
        catch {
          // just ignore
        }
      }
    }
  }
  
}
