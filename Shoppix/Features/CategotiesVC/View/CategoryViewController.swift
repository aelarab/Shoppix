//
//  CategoryViewController.swift
//  Shoppix
//
//  Created by Abdelrahman Elaraby on 20/10/2025.
//

import UIKit

class CategoryViewController: UIViewController {
    
    @IBOutlet weak var noL: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    private lazy var favoriteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .done,
            target: self,
            action: #selector(openFavoriteScreen)
        )
        button.tintColor = UIColor(named: "mainColor")
        return button
    }()

    
    
    private let viewModel = CategoryViewModel()
    private var filterButtons: [UIButton] = []
    private var isFilterExpanded = false
    private let mainFilterButton = UIButton(type: .system)
    
    
   //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFilterButton()
        bindViewModel()
        viewModel.fetchProducts(for: .all)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            FavoritesBadgeManager.shared.updateFavoritesBadge(for: self.favoriteButton)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
       //MARK: - Behaviour
    
    
    private func setupUI() {
        segmentControl.removeAllSegments()
        CategoryType.allCases.enumerated().forEach { index, category in
            segmentControl.insertSegment(withTitle: categoryTitle(for: category), at: index, animated: false)
        }
        segmentControl.selectedSegmentIndex = 0
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "ProductCollectionViewCell")
        navigationItem.rightBarButtonItem = favoriteButton
setupNotification()
        noL.isHidden = true
    }
    
    private func categoryTitle(for category: CategoryType) -> String {
        switch category {
        case .all: return "All"
        case .men: return "Men"
        case .women: return "Women"
        case .kids: return "Kids"
        case .sale: return "Sale"
        }
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(currencyDidChange),
            name: .currencyDidChange,
            object: nil
        )
    }

    @objc private func currencyDidChange() {
        collectionView.reloadData()
    }
    
    @objc private func openFavoriteScreen() {
        let favoriteVC = FavoriteViewController(nibName: "FavoriteViewController", bundle: nil)
        navigationController?.pushViewController(favoriteVC, animated: true)
    }
    
    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
            
            let hasProducts = !self.viewModel.filteredProducts.isEmpty
            self.noL.isHidden = hasProducts
            self.collectionView.isHidden = !hasProducts
        }
        
        viewModel.onError = { [weak self] message in
            print("\(message)")
        }
    }
    
    private func formatProductPrice(_ product: Product) -> String {
        guard let variantPrice = product.variants.first?.price,
              let price = Double(variantPrice) else {
            return "Not Available"
        }
        let currency = CurrencyService.shared.currentCurrency
        let convertedPrice = CurrencyService.shared.convert(amount: price, from: "EGP", to: currency)
        return CurrencyService.shared.formatPrice(convertedPrice, currency: currency)
    }

    
    
       //MARK: - Actions
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let selectedCategory = CategoryType.allCases[sender.selectedSegmentIndex]
        viewModel.fetchProducts(for: selectedCategory)
    }
}

// MARK: - Collection View
extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = viewModel.filteredProducts.count
        
        noL.isHidden = count > 0
        collectionView.isHidden = count == 0
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as? ProductCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let product = viewModel.filteredProducts[indexPath.item]
        cell.Name.text = product.title
        cell.image.sd_setImage(with: URL(string: product.images.first?.src ?? ""), placeholderImage: UIImage(named: "placeholder"))
        cell.deleteButtonOutlet.isHidden = true
        cell.priceLabel.text = formatProductPrice(product)
        cell.Name.textAlignment = .center
        cell.priceLabel.textAlignment = .center
        
        return cell
    }


    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width / 2) - 12
        return CGSize(width: width, height: 220)
    }
}

// MARK: - Expandable Filter Button
extension CategoryViewController {
    
    private func setupFilterButton() {
        mainFilterButton.frame = CGRect(x: view.frame.width - 80, y: view.frame.height - 150, width: 60, height: 60)
        mainFilterButton.backgroundColor = .black
        mainFilterButton.tintColor = .white
        mainFilterButton.layer.cornerRadius = 30
        mainFilterButton.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .normal)
        mainFilterButton.addTarget(self, action: #selector(toggleFilterButtons), for: .touchUpInside)
        view.addSubview(mainFilterButton)
        
        let subFilters: [SubFilterType] = [.shoes, .accessories, .tshirts]
        for (index, subFilter) in subFilters.enumerated() {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: view.frame.width - 80, y: view.frame.height - 150, width: 60, height: 60)
            button.backgroundColor = .systemGray5
            button.layer.cornerRadius = 30
            button.setTitleColor(.darkGray, for: .normal)
            button.setTitle(subFilter.rawValue, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
            button.alpha = 0
            button.tag = index
            button.addTarget(self, action: #selector(subFilterTapped(_:)), for: .touchUpInside)
            view.addSubview(button)
            filterButtons.append(button)
        }
    }
    
    @objc private func toggleFilterButtons() {
        isFilterExpanded.toggle()
        UIView.animate(withDuration: 0.3) {
            for (index, button) in self.filterButtons.enumerated() {
                button.alpha = self.isFilterExpanded ? 1 : 0
                button.frame.origin.y = self.isFilterExpanded ?
                    self.mainFilterButton.frame.origin.y - CGFloat((index + 1) * 70) :
                    self.mainFilterButton.frame.origin.y
            }
        }
    }
    
    @objc private func subFilterTapped(_ sender: UIButton) {
        let filter = [SubFilterType.shoes, .accessories, .tshirts][sender.tag]
        viewModel.applySubFilter(filter)
        toggleFilterButtons()
    }
}
