import AVFoundation
import UIKit
import Photos

class StartViewController: UIViewController {
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var makePhotoButton: UIButton!
    @IBOutlet weak private var galleryButton: UIButton!
    @IBOutlet weak private var saveButton: UIButton!
    
    private let pickerController = UIImagePickerController()
    var image : UIImage?
    var imagesArray = [UIImage]()
 
     enum ImageSource {
        case photoLibrary
        case camera
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeRadius()
        tappedImageView()
        pickerController.allowsEditing = true
        pickerController.delegate = self
    
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.image = image
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Setup
    
    private func makeRadius() {
        makePhotoButton.layer.cornerRadius = ButtonConstants.startVCButtonRadius
        galleryButton.layer.cornerRadius = ButtonConstants.startVCButtonRadius
        saveButton.layer.cornerRadius = ButtonConstants.startVCButtonRadius
    }
    
    // MARK: - Actions
    
    @IBAction private func tappedSave(_ sender: Any) {
        guard let image = imageView.image else {
            showAlertWith(title: "Error", message: "Choose photo to save")
            return
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            UIImageWriteToSavedPhotosAlbum(image, self,
                                           #selector(saveImage(_:didFinishSavingWithError:contextInfo:)), nil )
            
        } else {
            showAlertWith(title: "Error", message: "picture exists")
        }
    }
    
    @IBAction private func tappedMakePhoto(_ sender: Any) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            DispatchQueue.main.async {
                if response {
                    guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                        self.selectImageFrom(.photoLibrary)
                        return
                    }
                } else {
                    self.alertCameraAccessDenied()
                }
            }
        }
    }
    
    @IBAction private func tappedShowGallery(_ sender: Any) {
        goToGalleryVC()
    }
    
    @objc private func saveImage(_ image: UIImage,
                                 didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    
    func tappedImageView() {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(goToDetailVC(_:)))
        imageView.addGestureRecognizer(gesture)
        imageView.isUserInteractionEnabled = true
    }
    
    @objc private func goToDetailVC(_ gesture: UIGestureRecognizer) {
        let storyboard = UIStoryboard(name: "DetailImage", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "DetailImageViewController") as DetailImageViewController
        viewController.modalPresentationStyle = .fullScreen
        if let image = image {
            viewController.image = image
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    // MARK: - Logic
    
    private func alertCameraAccessDenied() {
        let alert = UIAlertController(title: "ERROR", message: "Not allowed", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    private func selectImageFrom(_ source: ImageSource) {
        switch source {
        case .camera:
            pickerController.sourceType = .camera
        case .photoLibrary:
            pickerController.sourceType = .photoLibrary
        }
        present(pickerController, animated: true, completion: nil)
    }
    
    private func showAlertWith(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    
  /*  @IBAction private func unwindSegueToStartVC(_ unwindSegue: UIStoryboardSegue) {
        guard unwindSegue.identifier == "unwindSegue" else {
            return
        }
        guard let sourceVC = unwindSegue.source as? GalleryViewController else { return }
        imageView.image = sourceVC.image
    }*/
    
    private func goToGalleryVC() {
        PHPhotoLibrary.requestAuthorization { (success) in
            DispatchQueue.main.async {
                if success == .authorized {
                    self.performSegue(withIdentifier: "goToGalleryVC", sender: nil)
                    
                } else if success == .denied {
                    let alert = UIAlertController(title: "ERROR", message: "Not allowed", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
    // MARK: - Extentions

extension StartViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
     func imagePickerController(_ picker: UIImagePickerController,
                                didFinishPickingMediaWithInfo info: [ UIImagePickerController.InfoKey: Any ]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            return
        }
        imageView.image = selectedImage
        pickerController.dismiss(animated: true)
    }
}
