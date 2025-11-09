//
//  FavoriteViewController.swift
//  SHOPPIX
//
//  Created by adham ragap on 03/11/2025.
//

import UIKit
import CoreData

class FavoriteViewController: UIViewController {
    var favoriteList = [FavoriteProduct]()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var favoriteCollectionView: UICollectionView!
    private let noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "No favorites found"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
        
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        favoriteCollectionView.dataSource = self
        favoriteCollectionView.delegate = self
        favoriteCollectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: "ProductCollectionViewCell")
        fetchFavorites()
        checkFavoriteList ()
        view.addSubview(noDataLabel)
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        setupNotification()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        fetchFavorites()
        checkFavoriteList()
    }
    func checkFavoriteList (){
        if self.favoriteList.isEmpty {
                self.noDataLabel.isHidden = false
                self.view.bringSubviewToFront(self.noDataLabel)
            } else {
                self.noDataLabel.isHidden = true
            }
    }
       //MARK: - Behaviour
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(currencyDidChange),
            name: .currencyDidChange,
            object: nil
        )
    }
    @objc private func currencyDidChange() {

        favoriteCollectionView.reloadData()
    }
    
    private func formatProductPrice(_ favorite: FavoriteProduct) -> String {
        guard let variantPrice = Double(favorite.variant ?? "") else {
            return "Not Available"
        }
        let currency = CurrencyService.shared.currentCurrency
        let convertedPrice = CurrencyService.shared.convert(amount: variantPrice, from: "EGP", to: currency)
        return CurrencyService.shared.formatPrice(convertedPrice, currency: currency)
    }
    
    func fetchFavorites(){
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }
        let request:NSFetchRequest <FavoriteProduct> = FavoriteProduct.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@" ,userId)
        do {
         favoriteList = try context.fetch(request)
        } catch(let err) {
            print("error fetching favorites \(err.localizedDescription)")
        }
        favoriteCollectionView.reloadData()
    }
    

}
extension FavoriteViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as? ProductCollectionViewCell  else {
           return UICollectionViewCell()
        }
        let product = favoriteList[indexPath.row]
        cell.Name.text = favoriteList[indexPath.row].title
        cell.image.sd_setImage(
            with: URL(string:  favoriteList[indexPath.row].image ?? "Shoppix"
        )
        )
        cell.Name.textAlignment = .center
        
        cell.onDeleteTapped = { [weak self] in
            guard let self = self else {return}
            self.confirmDelete(favorite: self.favoriteList[indexPath.row], index: indexPath)
        }
       
        if favoriteList[indexPath.row].variant != nil {
                    cell.priceLabel.text = formatProductPrice(product)
                } else {
                    cell.priceLabel.text =  "Not Avalible"
                }
                cell.priceLabel.textAlignment = .center
        
        
        return cell
    }
    func confirmDelete(favorite:FavoriteProduct,index:IndexPath){
        let alert = UIAlertController(
                    title: "Remove Favorite",
                    message: "Are you sure you want to delete this item ?",
                    preferredStyle: .alert
                )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self = self else {return}
            self.context.delete(favorite)
            do {
                        try self.context.save()
                        self.favoriteList.remove(at: index.row)
                        self.favoriteCollectionView.deleteItems(at: [index])
                        self.checkFavoriteList ()
                    } catch {
                        print("❌ Failed to delete item: \(error.localizedDescription)")
                    }
        }))
        present(alert, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: favoriteCollectionView.frame.width / 2 - 10, height: favoriteCollectionView.frame.height / 3 )
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard checkInternetConnection() else {return}
        Session.productId = Int(favoriteList[indexPath.row].id)
        let productDetailsVC = ProductDetailsViewController(nibName: "ProductDetailsViewController", bundle: nil)
        self.navigationController?.pushViewController(productDetailsVC, animated: true)
    }
    
}
