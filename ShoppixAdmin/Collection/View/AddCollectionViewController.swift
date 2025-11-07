import UIKit

protocol AddCollectionViewControllerDelegate: AnyObject {
    func didAddCollection()
}

class AddCollectionViewController: UIViewController {
    weak var delegate: AddCollectionViewControllerDelegate?
    
    private let titleField = UITextField()
    private let segmentControl = UISegmentedControl(items: ["Custom", "Smart"])
    private let imageUrlField = UITextField()
    private let sortOrderField = UITextField()
    private let saveButton = UIButton(type: .system)
    
    private var isSmart: Bool {
        return segmentControl.selectedSegmentIndex == 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        titleField.placeholder = "Collection Title"
        titleField.borderStyle = .roundedRect
        
        imageUrlField.placeholder = "Image URL"
        imageUrlField.borderStyle = .roundedRect
        imageUrlField.isHidden = true
        
        sortOrderField.placeholder = "Sort Order"
        sortOrderField.borderStyle = .roundedRect
        sortOrderField.isHidden = true
        
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let stack = UIStackView(arrangedSubviews: [titleField, segmentControl, imageUrlField, sortOrderField, saveButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    @objc private func segmentChanged() {
        let smart = isSmart
        imageUrlField.isHidden = !smart
        sortOrderField.isHidden = !smart
    }
    
    @objc private func saveTapped() {
        let title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !title.isEmpty else {
            showAlert("Please enter a collection title.")
            return
        }
        if isSmart {
            let imgUrl = imageUrlField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let sortOrder = sortOrderField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if imgUrl.isEmpty || sortOrder.isEmpty {
                showAlert("Please enter image URL and sort order.")
                return
            }
            // Call API to add smart collection
            addSmartCollection(title: title, imgUrl: imgUrl, sortOrder: sortOrder)
        } else {
            // Call API to add custom collection
            addCustomCollection(title: title)
        }
    }
    
    private func addSmartCollection(title: String, imgUrl: String, sortOrder: String) {
        // Replace with your actual API/viewModel call
        CollectionsViewModel().addSmartCollection(title: title, imgUrl: imgUrl, sortOrder: sortOrder) { [weak self] in
            DispatchQueue.main.async {
                self?.delegate?.didAddCollection()
                self?.dismiss(animated: true)
            }
        }
    }
    
    private func addCustomCollection(title: String) {
        // Replace with your actual API/viewModel call
        CollectionsViewModel().addCustomCollection(title: title) { [weak self] in
            DispatchQueue.main.async {
                self?.delegate?.didAddCollection()
                self?.dismiss(animated: true)
            }
        }
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
