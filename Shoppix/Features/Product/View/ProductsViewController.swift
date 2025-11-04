//
//  ProductsViewController.swift
//  SHOPPIX
//
//  Created by adham ragap on 23/10/2025.
//

import UIKit
import FirebaseAuth
import CoreData

class ProductsViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
   
    @IBOutlet weak var productCollectionView: UICollectionView!
    private var selectedFilter = ""
    var searchHidden = true
    var productViewModel : ProductViewModel!
    var productList = [Product]()
    var filterList = [Product]()
    var selectedVendor  = ""
    private let noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "No products found"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
        
    }()
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
       
      
        searchBar.delegate = self
        productViewModel = ProductViewModel(delegete: self)
        productViewModel.getPorductsFromServer(vendor: selectedVendor)
        
        view.addSubview(noDataLabel)
       
        
        noDataLabel.frame = view.bounds
        searchBar.isHidden = searchHidden
        title = "Products"
        setUPCollectionView()
      
        selectedFilter = "All"
        setupMenu()
        let searchButton = UIBarButtonItem(
                barButtonSystemItem: .search,
                target: self,
                action: #selector(didTapSearch)
            )

        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItems = [searchButton]
      
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        productCollectionView.reloadData()
    }
    @objc func openFavoriteScreen(){
       let favoriteVC = FavoriteViewController(nibName: "FavoriteViewController", bundle: nil)
        self.navigationController?.pushViewController(favoriteVC, animated: true)
    }
   
    private func setUPCollectionView (){
        productCollectionView.delegate = self
        productCollectionView.dataSource = self
        productCollectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
    }
    private func setupMenu() {
        let allAction = UIAction(title: "All", state: selectedFilter == "All" ? .on : .off) { [weak self] action in
           
                 //   self?.selectedFilter = "All"
                    self?.applyFilter(type: "All")
                    self?.setupMenu()
                }
        let priceLowToHigh = UIAction(title: "Price: Low to High", state: selectedFilter == "Price: Low to High" ? .on : .off) { [weak self] _ in
               self?.applyFilter(type: "Price: Low to High")
               self?.setupMenu()
           }
        let priceHighToLow = UIAction(title: "Price: High to Low", state: selectedFilter == "Price: High to Low" ? .on : .off) { [weak self] _ in
               self?.applyFilter(type: "Price: High to Low")
               self?.setupMenu()
           }
        let bestSeller = UIAction(title: "Best Seller", state: selectedFilter == "Best Seller" ? .on : .off) { [weak self] _ in
                self?.applyFilter(type: "Best Seller")
                self?.setupMenu()
            }
        let menu = UIMenu(title: "Filter by", children: [allAction, priceLowToHigh, priceHighToLow, bestSeller])
      let filterButton =  UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            menu: menu
        )
    
        navigationItem.rightBarButtonItems = [filterButton,favoriteButton]
    }
    private func applyFilter(type : String){
        selectedFilter = type
        switch type {
        case "All":
            filterList = productList
        case "Price: Low to High":
            filterList = productList.sorted {
                        Double($0.variants.first?.price ?? "0") ?? 0 < Double($1.variants.first?.price ?? "0") ?? 0
                    }
        case "Price: High to Low":
            filterList = productList.sorted {
                       Double($0.variants.first?.price ?? "0") ?? 0 > Double($1.variants.first?.price ?? "0") ?? 0
            }
        case "Best Seller":
            filterList = productList.sorted {
                       let stockA = $0.variants.first?.inventory_quantity ?? 0
                       let stockB = $1.variants.first?.inventory_quantity ?? 0
                       return stockA < stockB
                   }
        default:
            filterList = productList
        }
        productCollectionView.reloadData()
    }

    @objc private func didTapSearch() {
        searchHidden.toggle()
       
        searchBar.isHidden = searchHidden
    }
   
}
extension ProductsViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as? ProductCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.Name.text = filterList[indexPath.row].title
        cell.image.sd_setImage(
            with: URL(string:  filterList[indexPath.row].images.first?.src ?? "Shoppix"
        )
            )
      
        cell.Name.textAlignment = .center
        cell.favoriteButtonOutlet.isHidden = true
        cell.deleteButtonOutlet.isHidden = true

          
        return cell
    }
//    func addToFavorite(product: Product){
//        print("❤️ Adding to favorite: \(product.title) - ID: \(product.id)")
//        let favoriteProduct = FavoriteProduct(context: context)
//        favoriteProduct.id = Int64(product.id)
//        favoriteProduct.title = product.title
//        favoriteProduct.variant = product.variants.first?.price
//        favoriteProduct.image = product.images.first?.src
//        saveToCoreData()
//        print("💾 Saved to Core Data with ID: \(favoriteProduct.id)")
//    }
//    func deleteFromFavorite(product:Product){
//
//        print("🗑️ Deleting from favorite: \(product.title) - ID: \(product.id)")
//
//        let request: NSFetchRequest<FavoriteProduct> = FavoriteProduct.fetchRequest()
//        request.predicate = NSPredicate(format: "id == %d",NSNumber(value: product.id))
//        if let object = try? context.fetch(request) {
//            for object in object {
//                context.delete(object)
//                saveToCoreData()
//            }
//        }
//    }
//    func isProductFavorite(product:Product) -> Bool {
//        let fetch = NSFetchRequest<FavoriteProduct>(entityName: "FavoriteProduct")
//        fetch.predicate = NSPredicate(format: "id == %d", NSNumber(value: product.id))
//
//        let count = (try? context.count(for: fetch)) ?? 0
//        print("🔍 Checking favorite for ID \(product.id) → count = \(count)")
//            return count > 0
//
//    }
//    func saveToCoreData(){
//        do {
//            try context.save()
//
//        }catch (let error){
//            print("error saving data:\(error)")
//        }
//
//    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: productCollectionView.frame.width / 2 - 10, height: productCollectionView.frame.height / 2 - 60)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard checkInternetConnection() else {return}
        Session.productId = filterList[indexPath.row].id
        print("product id : \(filterList[indexPath.row].id)")
        let productDetails = ProductDetailsViewController(nibName: "ProductDetailsViewController", bundle: nil)
//        productDetails.productId = Session.productId
        self.navigationController?.pushViewController(productDetails, animated: true)
    }
    
    
}
extension ProductsViewController: SendDataOnVendorDelegete {
    func sendProudctsOnVendor(product: ProductModel) {
        print("📩 sendProudctsOnVendor called with count:", product.products.count)
        self.productList = product.products
        self.filterList = productList
        
        
        
       
        DispatchQueue.main.async {
            if self.filterList.isEmpty {
               
                           self.noDataLabel.isHidden = false
                self.productCollectionView.isHidden = true
                    self.view.bringSubviewToFront(self.noDataLabel)
               
                
            } else {
                self.productCollectionView.reloadData()
                
                           self.noDataLabel.isHidden = true
                       }
              }
    }
    
    
}
extension ProductsViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filterList = productList
        }else {
            filterList = productList.filter({ $0.title.range(of: searchText,options: .caseInsensitive) != nil
                
            })
        }
        self.productCollectionView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
