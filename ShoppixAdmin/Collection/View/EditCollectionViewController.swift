import UIKit
import Kingfisher
protocol EditCollectionViewControllerDelegate: AnyObject {
    func didEditCollection()
}

class EditCollectionViewController: UIViewController {
    // MARK: - UI Elements
    private let stackView = UIStackView()
    private let titleField = UITextField()
    private let imgUrlField = UITextField()
    private let sortOrderField = UITextField()
    private let saveButton = UIButton(type: .system)
    private let imageView = UIImageView()
    private let addImageBtn = UIButton(type: .system)
    private let deleteImageBtn = UIButton(type: .system)
    weak var delegate: EditCollectionViewControllerDelegate?
    // MARK: - Data
    enum EditType {
        case smartCollection(id: Int, title: String, imgUrl: String?, sortOrder: String?)
        case customCollection(id: Int, name: String)
    }
    var editType: EditType?
    var onSave: (() -> Void)?
    var collectionsViewModel = CollectionsViewModel()
    private var brandImages: [String] = []
    private var currentImageIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        configureFields()
    }

    private func setupUI() {
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Title field
        titleField.placeholder = "Collection Title"
        titleField.borderStyle = .roundedRect
        titleField.font = UIFont.systemFont(ofSize: 18)
        stackView.addArrangedSubview(titleField)

        // Image URL field
        imgUrlField.placeholder = "Image URL"
        imgUrlField.borderStyle = .roundedRect
        imgUrlField.font = UIFont.systemFont(ofSize: 18)
        stackView.addArrangedSubview(imgUrlField)

        // Sort Order field
        sortOrderField.placeholder = "Sort Order (e.g. best-selling)"
        sortOrderField.borderStyle = .roundedRect
        sortOrderField.font = UIFont.systemFont(ofSize: 18)
        stackView.addArrangedSubview(sortOrderField)

        // Image view
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .secondarySystemBackground
        imageView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        stackView.addArrangedSubview(imageView)

        // Add Image button
        addImageBtn.setTitle("Add Image", for: .normal)
        addImageBtn.backgroundColor = .systemGreen
        addImageBtn.setTitleColor(.white, for: .normal)
        addImageBtn.layer.cornerRadius = 10
        addImageBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        addImageBtn.addTarget(self, action: #selector(addImageTapped), for: .touchUpInside)
        stackView.addArrangedSubview(addImageBtn)

        // Delete Image button
        deleteImageBtn.setTitle("Delete Image", for: .normal)
        deleteImageBtn.backgroundColor = .systemRed
        deleteImageBtn.setTitleColor(.white, for: .normal)
        deleteImageBtn.layer.cornerRadius = 10
        deleteImageBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        deleteImageBtn.addTarget(self, action: #selector(deleteImageTapped), for: .touchUpInside)
        stackView.addArrangedSubview(deleteImageBtn)

        // Save button
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        stackView.addArrangedSubview(saveButton)
    }

    private func configureFields() {
        switch editType {
        case let .smartCollection(_, title, imgUrl, sortOrder):
            titleField.text = title
            imgUrlField.text = ""
            sortOrderField.text = sortOrder
            titleField.isHidden = false
            imgUrlField.isHidden = false
            sortOrderField.isHidden = false
            // Initialize brandImages with the existing image if present
            brandImages = imgUrl != nil && !imgUrl!.isEmpty ? [imgUrl!] : []
            updateImageView()
        case let .customCollection(_, name):
            titleField.text = name
            titleField.placeholder = "Collection Name"
            imgUrlField.isHidden = true
            sortOrderField.isHidden = true
            imageView.isHidden = true
            addImageBtn.isHidden = true
            deleteImageBtn.isHidden = true
        case .none:
            break
        }
    }

    private func updateImageView() {
        if brandImages.isEmpty {
            imageView.image = UIImage(named: "placeholder")
        } else if currentImageIndex < brandImages.count {
            let urlString = brandImages[currentImageIndex]
            if let url = URL(string: urlString) {
                // Use Kingfisher if available, else use native
                #if canImport(Kingfisher)
                imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
                #else
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.imageView.image = img
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.imageView.image = UIImage(named: "placeholder")
                        }
                    }
                }
                #endif
            } else {
                imageView.image = UIImage(named: "placeholder")
            }
        }
    }

    @objc private func addImageTapped() {
        guard let url = imgUrlField.text, !url.isEmpty else { return }
        if brandImages.contains(url) { return }
        brandImages.append(url)
        currentImageIndex = brandImages.count - 1
        updateImageView()
        imgUrlField.text = ""
    }

    @objc private func deleteImageTapped() {
        guard !brandImages.isEmpty, currentImageIndex < brandImages.count else { return }
        brandImages.remove(at: currentImageIndex)
        if currentImageIndex > 0 { currentImageIndex -= 1 }
        updateImageView()
    }

    @objc private func saveTapped() {
        switch editType {
        case let .smartCollection(id, _, _, _):
            let newTitle = titleField.text ?? ""
            let newSortOrder = sortOrderField.text
            // Send the currently displayed image to the API
                collectionsViewModel.updateSmartCollection(
                smartCollectionId: id,
                title: newTitle,
                imgUrl: brandImages.isEmpty ? nil : brandImages[currentImageIndex],
                sortOrder: newSortOrder
            ) { [weak self] in
                self?.delegate?.didEditCollection()
                self?.dismiss(animated: true)
            }
        case let .customCollection(id, _):
            let newName = titleField.text ?? ""
            collectionsViewModel.updateCustomCollection(customCollectionId: id, title: newName) { [weak self] in
                self?.delegate?.didEditCollection()
                self?.dismiss(animated: true)
            }
        case .none:
            break
        }
    }
}
