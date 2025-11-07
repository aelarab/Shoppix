//
//  ProductVariantsVC.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 26/10/2025.
//


import UIKit

class ProductVariantsViewController: UIViewController {
    
    var product:Product!
    var collectionId :Int!
    var flagEditAdd :Int!
    var currentIndex = 0{
        didSet{
            collectionOfViews.reloadData()
        }
    }
    
    var isNew = true{
        didSet{
            prepareVariantFields()
            deletionofVariant.isHidden = isNew
        }
    }

    var productViewModel : ProductViewModel!

    @IBOutlet weak var fieldSize: UITextField!
    
    @IBOutlet weak var fieldColor: UITextField!
    
    @IBOutlet weak var fieldPrice: UITextField!
    
    @IBOutlet weak var fieldQuantity: UITextField!
    
    @IBOutlet weak var collectionOfViews: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var variantVerticalNavigationStack: UIStackView!
    
    @IBOutlet var deletionofVariant: UIView!
    
    @IBOutlet weak var withoutVariant: UILabel!
    
    @IBAction func nextVariant(_ sender: UIButton) {
        
        if product.variants != nil && !(product.variants!.isEmpty){
            if currentIndex < product.variants!.count-1{
                currentIndex += 1
            }else{
                currentIndex = 0
            }
                    
            collectionOfViews.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: true)
            
            pageControl.currentPage = currentIndex
            
            if product.variants!.count > 1{
                variantVerticalNavigationStack.isHidden = false
                pageControl.isHidden = false
            }
            
            if !isNew {
                prepareVariantFields()
            }
        }
    }
    
    @IBAction func previousVariant(_ sender: UIButton) {
        if product.variants != nil && !(product.variants!.isEmpty){
            if currentIndex > 0{
                currentIndex -= 1
            }else{
                currentIndex = product.variants!.count-1
            }
                    
            collectionOfViews.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: true)
            
            pageControl.currentPage = currentIndex
            
            if product.variants!.count < 2{
                variantVerticalNavigationStack.isHidden = true
                pageControl.isHidden = true
            }
            if !isNew {
                prepareVariantFields()
            }
        }
    }
    
    @IBAction func deleteVariant(_ sender: Any) {
        if product.variants != nil && currentIndex < product.variants!.count{
            deleteVariantAlert()
        }
    }

    @IBAction func switchDidChanged(_ sender: UISwitch) {
        isNew = sender.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionOfViews.delegate = self
        collectionOfViews.dataSource = self
        
        pageControl.numberOfPages = product.variants?.count ?? 0
        deletionofVariant.isHidden = isNew
        
        if product.variants!.count < 2{
            variantVerticalNavigationStack.isHidden = true
            pageControl.isHidden = true
        }
        
        if product.variants!.count == 0{
            withoutVariant.isHidden = false
        }
        
        if flagEditAdd == 0{
            collectionOfViews.isHidden = true
            withoutVariant.isHidden = false
        }
        
        productViewModel = ProductViewModel()
      
    }
        
    func prepareVariantFields(){
        if isNew {
            fieldSize.text = ""
            fieldColor.text = ""
            fieldPrice.text = ""
            fieldQuantity.text = ""
        }else{
            if product.variants!.count > 0{
                fieldSize.text = product.variants![currentIndex].option1
                fieldColor.text = product.variants![currentIndex].option2
                fieldPrice.text = product.variants![currentIndex].price
                fieldQuantity.text = "\(Int(product.variants![currentIndex].inventoryQuantity!))"
            }
        }
    }
    
    func deleteVariantAlert(){
        let alert = UIAlertController(title: "Delete", message: "Are you sure about deletion?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default , handler: { [self] action in
            
            
            product.variants?.remove(at: currentIndex)
            
            if product.variants!.count < 2{
                variantVerticalNavigationStack.isHidden = true
            }
            if product.variants!.count == 0{
                deletionofVariant.isHidden = true
                withoutVariant.isHidden = false
            }
            if currentIndex > 0{
                currentIndex -= 1
            }
            prepareVariantFields()
            
            pageControl.numberOfPages = product.variants!.count
            self.collectionOfViews.reloadData()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel))
        self.present(alert, animated: true) {
        }
    }

    
    @IBAction func saveVariant(_ sender: Any) {
        if saveVariantData(){
            collectionOfViews.isHidden = false
            withoutVariant.isHidden = true
            if(isNew){
                fieldPrice.text = ""
                fieldQuantity.text = ""
                fieldSize.text = ""
                fieldColor.text = ""
            }
            
        }
    }
    
    @IBAction func saveProduct(_ sender: Any) {
        if flagEditAdd == 1{
            editProduct()
   
        }else{
            addProductInfo()
        }
        
    }
    
    
    func saveVariantData() -> Bool{
        if checkVariantFieldsAreFilled() {
            if checkPriceValidity(){
                if checkQuantityValidity(){
                    if checkVariantIsGenuine(){
                        if isNew || product.variants!.isEmpty{
                            let variant = Variants(title: "\(fieldSize.text!) / \(fieldColor.text!)",price:fieldPrice.text!,inventoryManagement: "shopify", option1: fieldSize.text!, option2: fieldColor.text!, inventoryQuantity: Int(fieldQuantity.text!), oldInventoryQuantity: Int(fieldQuantity.text!))
                            
                            product.variants?.append(variant)
                            self.view.showToastMessage(message: "Saved", color: .systemGreen)
                            collectionOfViews.reloadData()
                        }else{
                            product.variants![currentIndex].title = "\(fieldSize.text!) / \(fieldColor.text!)"
                            product.variants![currentIndex].option1 = fieldSize.text
                            product.variants![currentIndex].option2 = fieldColor.text
                            product.variants![currentIndex].price = fieldPrice.text
                            product.variants![currentIndex].inventoryQuantity = Int(fieldQuantity.text!)
                            product.variants![currentIndex].oldInventoryQuantity = Int(fieldQuantity.text!)
                            self.view.showToastMessage(message: "Saved", color: .green)
                            collectionOfViews.reloadData()
                        }
                        if product.variants!.count > 1{
                            variantVerticalNavigationStack.isHidden = false
                            pageControl.isHidden = false
                        }
                        checkAndAddOptions()
                        
                        return true
                    }else{
                        CustomAlerts.presentAlert(vc: self, title: Constants.error, message: Constants.duplicatedVariant)
                        return false
                    }
                }else{
                    CustomAlerts.presentAlert(vc: self, title: Constants.error, message: Constants.enterValidQuantity)
                    return false
                }
            }else{
                CustomAlerts.presentAlert(vc: self, title: Constants.error, message: Constants.validPrice)
                return false
            }
        }else{
            CustomAlerts.presentAlert(vc: self, title: Constants.error, message: Constants.emptyFields)
            return false
        }
    }
    
    func checkVariantFieldsAreFilled() -> Bool {
        let priceText = fieldPrice.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let quantityText = fieldQuantity.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let sizeText = fieldSize.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let colorText = fieldColor.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if priceText.isEmpty || quantityText.isEmpty || sizeText.isEmpty || colorText.isEmpty {
            return false
        }
        return true
    }

    
    func checkPriceValidity() -> Bool {
        if let priceText = fieldPrice.text, let price = Double(priceText), price > 0.0 {
            return true
        } else {
            return false
        }
    }

    
    func checkQuantityValidity() -> Bool {
        if let quantityText = fieldQuantity.text, let quantity = Int(quantityText), quantity >= 1 {
            return true
        } else {
            return false
        }
    }
    
    func checkVariantIsGenuine() -> Bool {
        for variant in product.variants! {
            if(isNew){
                if variant.title == "\(fieldSize.text!) / \(fieldColor.text!)" {
                    return false
                }
            }
        }
        return true
    }
    
    func showVariantHandlingAlert(){
        let alert = UIAlertController(title: Constants.warning, message: Constants.variantHandlingQuery, preferredStyle: .alert)
        let actionSaveAndContinue = UIAlertAction(title: Constants.save, style: .default) { _ in
            if self.saveVariantData(){
                self.view.showToastMessage(message: "actionSaveAndContinue", color: .green)
            }
        }
        let actionDiscardAndContinue = UIAlertAction(title: Constants.discard, style: .destructive) { _ in
//            self.navigateToDetails()
            self.view.showToastMessage(message: "actionDiscardAndContinue", color: .red)
        }
        let cancelAction = UIAlertAction(title: Constants.cancel, style: .cancel)
        alert.addAction(actionSaveAndContinue)
        alert.addAction(actionDiscardAndContinue)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    func checkAndAddOptions(){
        if !(product.options![0].values!.contains(fieldSize.text!)) {
            product.options![0].values?.append(fieldSize.text!)
        }
        if !(product.options![1].values!.contains(fieldColor.text!)) {
            product.options![1].values?.append(fieldColor.text!)
        }
    }

}


extension ProductVariantsViewController{
 
    func addProductInfo(){
        
        product.status = "active"
        
        
        productViewModel.bindResultToProduct = {[weak self] in
            print((self?.productViewModel.newProduct.product?.id) ?? 0)
            let productId = (self?.productViewModel.newProduct.product?.id) ?? 0
            let imgSrc = self?.product.image?.src ?? "https://static.nike.com/a/images/c_limit,w_592,f_auto/t_product_v1/eba7a509-73b5-473f-a964-6bea77d8ebf1/dunk-low-retro-mens-shoes-76KnBL.png"
            self?.addProductImg(productId: productId, imgSrc: imgSrc)

           
            if let collectionId = self?.collectionId {
                self?.addProductToCustomCollection(productId: productId, collectionId: collectionId)
            } else {
                print("Error: collectionId is nil")

            }

            

            
           self?.editProductState(productId: productId)
            
            DispatchQueue.main.async {
              //  self?.navigationController?.popViewController(animated: true)
                self?.navigationController?.popToViewController(ofClass: ProductsViewController.self)
            }
        }
        productViewModel.createProduct(product: product)
    }
    
    // add product image
    func addProductImg(productId: Int, imgSrc: String){
        let params: [String : Any] = [
            "image":[
                "product_id": productId,
                "src": imgSrc
            ] as [String : Any]
        ]
        
        productViewModel.createProductImg(params: params, id: productId)
    }
    
    //add product to custom collection
    func addProductToCustomCollection(productId: Int, collectionId: Int){
        let params: [String : Any] = [
            "collect":[
                "product_id": productId,
                "collection_id": collectionId
            ]
        ]
        productViewModel.addProdoctCustomCollection(params: params)
    }
    
    // edit product state
    func editProduct(){
        
        productViewModel.bindResultToProduct = {[weak self] in
            print((self?.productViewModel.newProduct.product?.id) ?? 0)
            let productId = (self?.productViewModel.newProduct.product?.id) ?? 0
            
            self?.addProductImg(productId: productId, imgSrc: (self?.product.image?.src)!)
            
            let collectionId = self?.collectionId ?? 1
            self?.addProductToCustomCollection(productId: productId, collectionId: collectionId)

      
            DispatchQueue.main.async {

                self?.navigationController?.popToViewController(ofClass: ProductsViewController.self)
            }
        }
        
        productViewModel.editProduct(product: product)
    }
    
   func editProductState(productId: Int){
       let params: [String: Any] = ["product":[
               "status": "active",
               "published": true
           ]        ]
        product.status = "active"
       
    }
    
    
}


extension ProductVariantsViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        product.variants?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:
                        IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productVariantCell",
                                                      for: indexPath) as! ProductVariantCell
        cell.size.text = (product.variants?[currentIndex].option1)
        cell.color.text = (product.variants?[currentIndex].option2)
        let price : String = (product.variants?[currentIndex].price)!
        cell.price.text = "\(price)"
        let quantity : Int = (product.variants?[currentIndex].inventoryQuantity)!
        cell.quantity.text = "\(quantity)"
        
        return cell
}
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
        return CGSize(width: collectionView.frame.width - 16, height:  collectionView.frame.height)
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}
