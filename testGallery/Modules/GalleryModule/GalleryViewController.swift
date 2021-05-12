import Photos
import UIKit

class GalleryViewController: UIViewController {

    @IBOutlet weak private var collectionView: UICollectionView!
    private var imageArray = [UIImage]()
    var image = UIImage()
    var isLoading = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
     //   reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        getPhotosFromAlbum()
    }
    
    // MARK: - Logic
    
    private func getPhotosFromAlbum() {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .fast
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if fetchResult.count > 0 {
            DispatchQueue.global(qos: .userInteractive).async {
                for item in 0..<fetchResult.count {
                    imageManager.requestImage(for: fetchResult.object(at: item) as PHAsset,
                                              targetSize: PHImageManagerMaximumSize, contentMode: .default,
                                              options: requestOptions, resultHandler: { image, _ in
                                                if let image = image {
                                                    self.imageArray.append(image)
                                                }
                                              })
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            }
        }
    }

    // MARK: - Navigation
    
    private func goToStartVC() {
        let storyboard = UIStoryboard(name: "Start", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "StartViewController") as StartViewController
        viewController.modalPresentationStyle = .fullScreen
        viewController.image = image
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Extentions

// MARK: - UICollectionViewDelegate

extension GalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
}

// MARK: - UICollectionViewDataSource

extension GalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell",
                                                            for: indexPath) as?  PhotoCollectionViewCell else {
         return UICollectionViewCell()
        }
         cell.imageView.image = imageArray[indexPath.item]
         return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        image = imageArray[indexPath.item]
        goToStartVC()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3 - 1
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }

}
