//
//  ProductViewController.swift
//  ShopifyAdmin
//
//  Created by Ahmed Mohamed on 26/10/2025.
//

import UIKit
import Kingfisher

class ProductViewController: UIViewController, UITextViewDelegate {
    
    var productViewModel : ProductViewModel!
    var displayCollectionsViewModel : CollectionsViewModel!
    
    @IBOutlet weak var productTitleTF: UITextField!
 

    @IBOutlet weak var productDetailsTF: UITextView!
    @IBOutlet weak var productVendorMenu: UIButton!
    @IBOutlet weak var productmenu: UIButton!
    @IBOutlet weak var productCustomCellectionMenu: UIButton!
    @IBOutlet weak var productImgSrc: UITextView!
  
    @IBOutlet weak var imgLabel: UILabel!
    @IBOutlet weak var collectionLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var addImageBtn: UIButton!
    
    
    @IBOutlet weak var addImageUrlTextField: UITextView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
  
    @IBOutlet weak var imageNavigationStack: UIStackView!
    
    @IBOutlet var deleteImageBtn: UIView!
    
    @IBOutlet weak var noImage: UIImageView!
 
    var collectionId :Int!
    var flagEditAdd :Int!
    var currentIndex = 0
 
    var lastTextFiledFrame: CGFloat = CGFloat.zero
    
    var productTypeRes: String = "ACCESSORIES"
    var productVendorRes: String = "ADIDAS"
    var productCustomCellectionRes: Int = 0
    
    var productId: Int?
    var product: Product!
    var optionArr = [Options(name: Constants.size, position: 1, values: []),Options(name: Constants.color, position: 2, values: [])]
    
    
    var customCollections : [NewCustomCollection] = []{
        didSet{
            productCustomCellectionMenu.menu = getCustomCellectionMenu()
        }
    }
    
    var smartCollections : [SmartCollection] = []{
        didSet{
            productVendorMenu.menu = getVendorsMenu()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let images = product?.images {
            pageControl.numberOfPages = images.count
        } else {
            pageControl.numberOfPages = 0
        }


        
        if let product = product {
            if let images = product.images {
                if images.count < 2 {
                    imageNavigationStack.isHidden = true
                }
            } else {
                imageNavigationStack.isHidden = true
            }
        } else {
            
            imageNavigationStack.isHidden = true
        }


        
        
        if flagEditAdd == 0{
            noImage.isHidden = false
        }
        
        
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 100)

       productImgSrc.delegate = self
        productTitleTF.delegate = self
        productDetailsTF.delegate = self

        productViewModel = ProductViewModel()
        displayCollectionsViewModel = CollectionsViewModel()
        
        
  
        displayCollectionsViewModel.bindResultToDisplayBrands = { [weak self] in
            guard let self = self else { return }
            self.smartCollections = self.displayCollectionsViewModel.allBrands.smart_collections

        }
        displayCollectionsViewModel.getAllBrands()
        

        displayCollectionsViewModel.bindCustomCollection = { [weak self] in
            guard let self = self else { return }
            self.customCollections = self.displayCollectionsViewModel.allCustomCollection.custom_collections

        }
        displayCollectionsViewModel.getAllCustomCollection()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

        //Edit
        if flagEditAdd == 1{
            collectionLabel.isHidden = true
            productCustomCellectionMenu.isHidden = true
            // Do NOT hide addImageBtn and deleteImageBtn in edit mode
            // addImageBtn.isHidden = true
            // deleteImageBtn.isHidden=true
            productId = product.id ?? 0
            productTitleTF.text = product.title
            productDetailsTF.text = product.bodyHtml
           productImgSrc.text = product.image?.src
            productTypeRes = product.productType!
            productVendorRes = product.vendor!
            
            product.options = optionArr
            
            // Reload collection view to show all images
            collectionView.reloadData()
            // Show/hide navigation stack and delete button based on images count
            if let images = product.images {
                imageNavigationStack.isHidden = images.count < 2
                deleteImageBtn.isHidden = images.isEmpty
                noImage.isHidden = !images.isEmpty
                pageControl.numberOfPages = images.count
            } else {
                imageNavigationStack.isHidden = true
                deleteImageBtn.isHidden = true
                noImage.isHidden = false
                pageControl.numberOfPages = 0
            }
        }else{
            product = Product( id: nil, title: "", bodyHtml: "", vendor: "", productType: "", createdAt: nil, handle: nil, updatedAt: nil, publishedAt: nil, status: nil, publishedScope: nil, tags: nil, adminGraphqlApiId: nil, variants: [], options: optionArr, images: [], image: nil)
        }
        
        productTypeMenu()
        initializeVendorMenu()
        initializeCustomCellectionMenu()
        
    }
    
    
    
    @IBAction func nextImage(_ sender: UIButton) {
        
        if product.images != nil && !(product.images!.isEmpty){
            if currentIndex < product.images!.count-1{
                currentIndex += 1
            }else{
                currentIndex = 0
            }
                    
            collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: true)
            
            pageControl.currentPage = currentIndex
            
            if product.images!.count > 1{
                pageControl.isHidden = false
            }
        }
    }
    
    @IBAction func previousImage(_ sender: UIButton) {
        if product.images != nil && !(product.images!.isEmpty){
            if currentIndex > 0{
                currentIndex -= 1
            }else{
                currentIndex = product.images!.count-1
            }
                    
            collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: true)
            
            pageControl.currentPage = currentIndex
            
            if product.images!.count < 2{
                pageControl.isHidden = true
            }
            
        }
    }
    
    @IBAction func deleteImage(_ sender: Any) {
        if product.images != nil && currentIndex < product.images!.count{
            deleteImageAlert()
        }
    }
    
    @IBAction func addImage(_ sender: Any) {
        if saveProductImage(){
            addImageUrlTextField.text = ""
            collectionView.reloadData()
            // Update UI state after adding image
            if let images = product.images {
                imageNavigationStack.isHidden = images.count < 2
                deleteImageBtn.isHidden = images.isEmpty
                noImage.isHidden = !images.isEmpty
                pageControl.numberOfPages = images.count
            }
        }
    }
    
    @IBAction func moveToVariantsVC(_ sender: Any) {
        let title = productTitleTF.text ?? ""
        let details = productDetailsTF.text ?? ""
        print(productDetailsTF.text ?? "no data f")
        let vendor = productVendorRes
        let productType = productTypeRes
        let collectionId = productCustomCellectionRes
        
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
          
            self.showAlert(title: "⚠️ WARNING", message: "Fields can't be empty!")
        }else{
            
            product.title = title
            product.bodyHtml = details
            product.productType = productType
            product.vendor = vendor
  
            checkAndMoveToVariantPage()
        }
    }
  
   
    
    func productTypeMenu(){
        
        let menuActions : [UIAction] = [
            UIAction(title: "ACCESSORIES",handler: { [weak self] action in
                self?.productTypeRes = "ACCESSORIES"
            }),
            UIAction(title: "T-SHIRTS", handler: { [weak self] action in
                self?.productTypeRes = "T-SHIRTS"
            }),
            UIAction(title: "SHOES",handler: { [weak self] action in
                self?.productTypeRes = "SHOES"
            })
        ]
        
        menuActions.first(where: {$0.title == productTypeRes})?.state = .on
        
        productmenu.menu = UIMenu(title: "Product Type", options: .singleSelection, children: menuActions)
        
        productmenu.showsMenuAsPrimaryAction = true
        productmenu.changesSelectionAsPrimaryAction = true
    }
    
    private func getVendorsMenu() -> UIMenu {
        
        var menuActions = [UIAction]()

        if(smartCollections.isEmpty){
            menuActions.append(
                UIAction(
                    title: "ADIDAS",
                    handler: { [weak self] action in
                        self?.productVendorRes = "ADIDAS"
                    }
                )
            )
        }
        
        smartCollections.indices.forEach({ index in
            let item = UIAction(title: smartCollections[index].title,handler: { [weak self] action in
                guard let self = self else { return }
                self.productVendorRes = self.smartCollections[index].title
            })

            menuActions.append(item)
        })
        
        menuActions.first(where: {$0.title == productVendorRes})?.state = .on

        return UIMenu(
            title: "Product Vendor",
            options: .singleSelection,
            children: menuActions
        )
    }
    
    func initializeVendorMenu(){
        productVendorMenu.menu = getVendorsMenu()
        productVendorMenu.showsMenuAsPrimaryAction = true
        productVendorMenu.changesSelectionAsPrimaryAction = true
    }
    
    private func getCustomCellectionMenu() -> UIMenu {
        
        var menuActions = [UIAction]()

        if(customCollections.isEmpty){
            menuActions.append(
                UIAction(
                    title: "Home page",
                    handler: { [weak self] action in
                        self?.productCustomCellectionRes = 668188896222
                    }
                )
           )
        }
        
        customCollections.indices.forEach({ index in
            if(index == 0){

            }
            let item = UIAction(
                title: customCollections[index].title,
                handler: { [weak self] action in
                    guard let self = self else { return }
                    self.productCustomCellectionRes = self.customCollections[index].id
                }
            )

            menuActions.append(item)
        })

        menuActions.first?.state = .on
        
        return UIMenu(
            title: "Product Custom Collection",
            options: .singleSelection,
            children: menuActions
        )
    }
    
    func initializeCustomCellectionMenu(){
        
        productCustomCellectionMenu.menu = getCustomCellectionMenu()
        
        productCustomCellectionMenu.showsMenuAsPrimaryAction = true
        productCustomCellectionMenu.changesSelectionAsPrimaryAction = true
    }
    
    func showAlert(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.ok, style: .default))
        self.present(alert, animated: true)
        
    }
  
}

extension ProductViewController : UITextFieldDelegate{
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches,
                           with: event)
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func setSecondPageUI(){
        addImageUrlTextField.giveShadowAndRadius(shadowRadius: 0, cornerRadius: 20)
        addImageUrlTextField.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func deleteImageAlert(){
       
        let alert = UIAlertController(title: "Delete", message: "Are you sure about deletion?", preferredStyle: .alert)
      
        alert.addAction(UIAlertAction(title: "OK", style: .default , handler: { [self] action in
            
            
            product.images?.remove(at: currentIndex)
            collectionView.reloadData()
            // Update UI state after deleting image
            if let images = product.images {
                imageNavigationStack.isHidden = images.count < 2
                deleteImageBtn.isHidden = images.isEmpty
                noImage.isHidden = !images.isEmpty
                pageControl.numberOfPages = images.count
                if currentIndex > 0 {
                    currentIndex -= 1
                }
            } else {
                imageNavigationStack.isHidden = true
                deleteImageBtn.isHidden = true
                noImage.isHidden = false
                pageControl.numberOfPages = 0
                currentIndex = 0
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel))
        
     
        self.present(alert, animated: true) {
        
        }
    }
    
    func saveProductImage() -> Bool{
        if addImageUrlTextField.text != ""{
            var duplicatedImage = false
            if !product.images!.isEmpty {
                for image in product.images! {
                    if image.src == addImageUrlTextField.text {
                        duplicatedImage = true
                        break
                    }
                }
            }
            if duplicatedImage {
                CustomAlerts.presentAlert(vc: self, title: Constants.error, message: Constants.duplicatedImage)
                return false
            }else{
                product.images?.append(Image(src: addImageUrlTextField.text))
                return true
            }
        }else{
            CustomAlerts.presentAlert(vc: self, title: Constants.error, message: Constants.enterImageURL)
            return false
        }
    }
    
    func checkAndMoveToVariantPage(){
        if addImageUrlTextField.text == "" {
            if product.images!.isEmpty {
                CustomAlerts.presentAlert(vc: self, title: Constants.error, message: Constants.atLeastOneImage)
            }else {
                moveToVariantPage()
            }
        }else{
            var duplicatedImage = false
            for image in product.images! {
                if image.src == addImageUrlTextField.text {
                    duplicatedImage = true
                    break
                }
            }
            if duplicatedImage {
                moveToVariantPage()
            }else{
                showImageHandlingAlert()
            }
        }
    }
    
    func showImageHandlingAlert(){
        let alert = UIAlertController(title: Constants.warning, message: Constants.imageHandlingQuery, preferredStyle: .alert)
        let actionSaveAndContinue = UIAlertAction(title: Constants.save, style: .default) { _ in
            self.product.images?.append(Image(src: self.addImageUrlTextField.text))
            self.moveToVariantPage()
        }
        let actionDiscardAndContinue = UIAlertAction(title: Constants.discard, style: .destructive) { _ in
            self.moveToVariantPage()
        }
        let cancelAction = UIAlertAction(title: Constants.cancel, style: .cancel)
        alert.addAction(actionSaveAndContinue)
        alert.addAction(actionDiscardAndContinue)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    func moveToVariantPage(){

        self.addImageUrlTextField.text = ""
        
        let productVariantsVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductVariantsVC") as! ProductVariantsViewController

        productVariantsVC.product = product
        productVariantsVC.collectionId = collectionId
        productVariantsVC.flagEditAdd = flagEditAdd
        
        self.navigationController?.pushViewController(productVariantsVC, animated: true)
    }
    

}


extension ProductViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        product.images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:
                        IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productImageCell",
                                                      for: indexPath) as! ProductImageCell
        let url = URL(string: (product.images?[indexPath.row].src)!)
        cell.imgProductPhoto.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "placeholder"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
        return CGSize(width: collectionView.frame.width, height:  collectionView.frame.height)
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
