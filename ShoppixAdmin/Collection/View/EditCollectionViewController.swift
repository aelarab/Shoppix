import UIKit

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
    weak var delegate: EditCollectionViewControllerDelegate?
    // MARK: - Data
    enum EditType {
        case smartCollection(id: Int, title: String, imgUrl: String?, sortOrder: String?)
        case customCollection(id: Int, name: String)
    }
    var editType: EditType?
    var onSave: (() -> Void)?
    var collectionsViewModel = CollectionsViewModel()

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
            imgUrlField.text = imgUrl
            sortOrderField.text = sortOrder
            titleField.isHidden = false
            imgUrlField.isHidden = false
            sortOrderField.isHidden = false
        case let .customCollection(_, name):
            titleField.text = name
            titleField.placeholder = "Collection Name"
            imgUrlField.isHidden = true
            sortOrderField.isHidden = true
        case .none:
            break
        }
    }

    @objc private func saveTapped() {
        switch editType {
        case let .smartCollection(id, _, _, _):
            let newTitle = titleField.text ?? ""
            let newImgUrl = imgUrlField.text
            let newSortOrder = sortOrderField.text
            collectionsViewModel.updateSmartCollection(smartCollectionId: id, title: newTitle, imgUrl: newImgUrl, sortOrder: newSortOrder) { [weak self] in
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
