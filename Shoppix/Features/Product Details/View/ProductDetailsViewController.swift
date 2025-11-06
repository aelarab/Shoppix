//
//  ProductDetailsViewController.swift
//  SHOPPIX
//
//  Created by adham ragap on 27/10/2025.
//

import UIKit
import FirebaseAuth
import CoreData

class ProductDetailsViewController: UIViewController {

    @IBOutlet weak var variantPicker: UIPickerView!
    @IBOutlet weak var reviewButtomOutlet: UIButton!
    @IBOutlet weak var favoriteButtonOutlet: UIButton!
    @IBOutlet weak var productDescription: UITextView!
    @IBOutlet weak var addToBagButtonOutlet: UIButton!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var page: UIPageControl!
    @IBOutlet weak var productCollectionView: UICollectionView!
    var productImages = [ProductImage]()
//    var productId = 0
    var isVaforite:Bool = false
    var viewModel : ProductDetailViewModel?
    var variants = [Variant]()
    var selectedVariant: Variant?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var product:Product?
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        viewModel = ProductDetailViewModel(delegete: self)
        viewModel?.getProductDetailsFromServer(productId: Session.productId)
        productCollectionView.delegate = self
        productCollectionView.dataSource = self
        variantPicker.delegate = self
        variantPicker.dataSource = self
        productCollectionView.register(UINib(nibName: "ProductImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductImageCollectionViewCell")
        
        self.designButton(button: addToBagButtonOutlet)
        addToBagButtonOutlet.setTitle("Add to Bag", for: .normal)
        favoriteButtonOutlet.tintColor = UIColor(named: "mainColor")
        reviewButtomOutlet.tintColor = UIColor(named: "mainColor")
        reviewButtomOutlet.setTitle("Reviews", for: .normal)
        favoriteButtonOutlet.addTarget(self, action: #selector(addFavoritTapped), for: .touchUpInside)
        reviewButtomOutlet.addTarget(self, action: #selector(reviewButtonTapped), for: .touchUpInside)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        
    }

   @objc func addFavoritTapped (){
       guard let product = product else {
            return
       }
       if isVaforite {
           deleteFromFavorite(product: product)
           isVaforite = false
       }else {
           addToFavorite(product: product)
           isVaforite = true
       }
       favoriteButtonOutlet.setImage(isVaforite ? UIImage(systemName: "heart.fill"):UIImage(systemName: "heart") , for: .normal)
    }
    func addToFavorite(product: Product){
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
                showLoginAlert()
                return
            }
        print("❤️ Adding to favorite: \(product.title) - ID: \(Session.productId) with user id \(userId)")
        let favoriteProduct = FavoriteProduct(context: context)
        favoriteProduct.id = Int64(Session.productId)
        favoriteProduct.title = product.title
        favoriteProduct.variant = product.variants.first?.price
        favoriteProduct.image = product.images.first?.src
        favoriteProduct.userId = userId
        saveToCoreData()
        print("💾 Saved to Core Data with ID: \(favoriteProduct.id)")
    }
    private func showLoginAlert() {
        let alert = UIAlertController(title: "Login Required", message: "Please sign in to add items to your favorites.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { _ in
            let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
            self.navigationController?.setViewControllers([loginVC], animated: true)
              }))
              self.present(alert, animated: true)
    }
    func deleteFromFavorite(product:Product){
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }
        print("🗑️ Deleting from favorite: \(product.title) - ID: \(product.id)- user id \(userId)")
            
        let request: NSFetchRequest<FavoriteProduct> = FavoriteProduct.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND userId == %@", NSNumber(value: Session.productId),userId)
        if let object = try? context.fetch(request) {
            for object in object {
                context.delete(object)
                saveToCoreData()
            }
        }
    }
    func isProductFavorite()  {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }
        let fetch = NSFetchRequest<FavoriteProduct>(entityName: "FavoriteProduct")
        
        fetch.predicate = NSPredicate(format: "id == %@ AND userId == %@", NSNumber(value: Session.productId),userId)
      //  let all = try context.fetch(NSFetchRequest<FavoriteProduct>(entityName: "FavoriteProduct"))
//        for item in all {
//            print("🟡 Stored favorite: \(item.title ?? "") - ID: \(item.id) for user \(item.userId ?? "Unknown")")
//        }
        
        do {
            let count = try context.count(for: fetch)
            isVaforite = count > 0
            print("isVaforite : \(isVaforite)" )
                        favoriteButtonOutlet.setImage(
                                    isVaforite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"),
                                    for: .normal
                                )
        } catch (let error){
            print("error : \(error.localizedDescription)")
//            isVaforite = false
//            favoriteButtonOutlet.setImage(
//                        isVaforite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"),
//                        for: .normal
//                    )
    }
    }
    
    
    
   
    func saveToCoreData(){
        do {
            try context.save()
            context.refreshAllObjects()
        }catch (let error){
            print("error saving data:\(error)")
        }
       
    }
    @objc func reviewButtonTapped (){
        let reviewVC = ReviewsViewController(nibName: "ReviewsViewController", bundle: nil)
        
        self.navigationController?.present(reviewVC, animated: true)
    }
    
    func addToCart(product: Product) {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            showLoginAlert()
            return
        }

        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "CartProduct")
        request.predicate = NSPredicate(format: "id == %@ AND userId == %@", NSNumber(value: Session.productId), userId)
        
        do {
            let results = try context.fetch(request)
            
            if let existingItem = results.first {

                let currentQuantity = existingItem.value(forKey: "quantity") as? Int64 ?? 0
                existingItem.setValue(currentQuantity + 1, forKey: "quantity")
                
                try context.save()
                print(" Increased quantity to \(currentQuantity + 1)")
                
                showSimpleAlert(
                    title: "Quantity Updated",
                    message: "Increased quantity of \(product.title) to \(currentQuantity + 1)."
                )
                
            } else {
                let cartItem = NSEntityDescription.insertNewObject(forEntityName: "CartProduct", into: context)
                cartItem.setValue(Int64(Session.productId), forKey: "id")
                cartItem.setValue(product.title, forKey: "title")
                cartItem.setValue(product.variants.first?.price ?? "0.0", forKey: "price")
                cartItem.setValue(product.images.first?.src, forKey: "image")
                cartItem.setValue(userId, forKey: "userId")
                cartItem.setValue(Int64(1), forKey: "quantity")
                
                try context.save()
                print(" Product added to cart successfully. Quantity: 1")
                
                showSimpleAlert(
                    title: "Added to Cart",
                    message: "\(product.title) has been added to your cart."
                )
            }
        } catch {
            print(" Error saving or fetching cart product: \(error.localizedDescription)")
        }
    }


    func showSimpleAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }


    @IBAction func addToBagButtonPressed(_ sender: UIButton) {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
                showLoginAlert()
                return
            }
        guard let product = product else { return }
        addToCart(product: product)

    }
}
extension ProductDetailsViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductImageCollectionViewCell", for: indexPath) as? ProductImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.producDetailtImage.sd_setImage(
            with: URL(string:  productImages[indexPath.row].src ?? "Shoppix"
        )
            )
        page.tintColor = UIColor(named: "inverseLabelColor")
        page.currentPageIndicatorTintColor = UIColor(named: "mainColor")
        return cell
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        page.currentPage = pageIndex
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: productCollectionView.frame.width - 10, height: productCollectionView.frame.height)
    }
    
}
extension ProductDetailsViewController:sendProductDetailsDelegete {
    func sendProductDetails(productDetail: SingleProductModel) {
        productImages = productDetail.product.images
        product = productDetail.product
        variants = productDetail.product.variants
        DispatchQueue.main.async { [weak self]  in
            guard let self = self else {return}
            self.productName.text = productDetail.product.title
           
            self.page.numberOfPages = self.productImages.count
            self.title = productDetail.product.title
            self.productDescription.text = productDetail.product.body_html
            self.productCollectionView.reloadData()
            
            if let firstVariant = self.variants.first {
                       self.productPrice.text = "\(firstVariant.price) EGP"
                       self.variantPicker.selectRow(0, inComponent: 0, animated: false)
                   }
            self.variantPicker.reloadAllComponents()
            
            
            self.isProductFavorite()
        }
    }
    func showError(message: String) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "⚠️ Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                self.present(alert, animated: true)
            }
        }
    
    
}
extension ProductDetailsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return variants.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return variants[row].title
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let variant = variants[row]
        self.selectedVariant = variant
        UIView.transition(with: productPrice, duration: 0.3, options: .transitionCrossDissolve, animations: {
               self.productPrice.text = "\(variant.price) EGP"
           }, completion: nil)
    }
}
