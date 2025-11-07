//
//  CollectionsViewController.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 03/11/2025.
//

import UIKit
import Kingfisher
class CollectionsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, EditCollectionViewControllerDelegate, AddCollectionViewControllerDelegate {
     
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func AddCollection(_ sender: Any) {
        let addVC = AddCollectionViewController()
        addVC.delegate = self
        addVC.modalPresentationStyle = .formSheet
        self.present(addVC, animated: true)
    }
    var indicator = UIActivityIndicatorView(style: .large)
    
    let viewModel = CollectionsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderView"
        )
      
        viewModel.bindResultToDisplayBrands = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        viewModel.bindCustomCollection = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        viewModel.bindProductsNum = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()

            }
        }

        viewModel.getAllBrands()
        viewModel.getAllCustomCollection()
    }
    func didEditCollection() {
        viewModel.getAllBrands()
        viewModel.getAllCustomCollection()
    }
    func didAddCollection() {
        viewModel.getAllBrands()
        viewModel.getAllCustomCollection()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.allBrands?.smart_collections.count ?? 0
        } else {
            return viewModel.allCustomCollection?.custom_collections.count ?? 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        if indexPath.section == 0 {
            let brand = viewModel.allBrands.smart_collections[indexPath.row]
            viewModel.fetchProductsCountBrands(collectionId: brand.id) { count in
                DispatchQueue.main.async {
                    cell.itemsNum?.text = "\(count) items"
                }
            }
            cell.brandTitle?.text = brand.title
            cell.brandImg?.kf.setImage(with: URL(string: brand.image?.src ?? ""))
            cell.onEditRequested = { [weak self] in
                guard let self = self else { return }
                let editVC = EditCollectionViewController()
                editVC.editType = .smartCollection(id: brand.id, title: brand.title, imgUrl: brand.image?.src, sortOrder: brand.sort_order)
                editVC.delegate = self
                editVC.modalPresentationStyle = .formSheet
                self.present(editVC, animated: true)
            }
            cell.onDeleteRequested = { [weak self] in
                guard let self = self else { return }
                let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this collection?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                    self.viewModel.deleteFromSmartCollection(smartCollectionId: brand.id)
                    if var brands = self.viewModel.allBrands?.smart_collections {
                        if let index = brands.firstIndex(where: { $0.id == brand.id }) {
                            brands.remove(at: index)
                            self.viewModel.allBrands?.smart_collections = brands
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                   
                 
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true)
            }
        } else {
            let customCollection = viewModel.allCustomCollection.custom_collections[indexPath.row]
            viewModel.fetchProductsCount(collectionId: customCollection.id) { count in
                DispatchQueue.main.async {
                    cell.itemsNum?.text = "\(count) items"
                }
            }
            cell.brandTitle?.text = customCollection.title
            cell.brandImg?.image = UIImage(named: "empty")
            cell.onEditRequested = { [weak self] in
                guard let self = self else { return }
                let editVC = EditCollectionViewController()
                editVC.editType = .customCollection(id: customCollection.id, name: customCollection.title)
                editVC.delegate = self
                editVC.modalPresentationStyle = .formSheet
                self.present(editVC, animated: true)
            }
            cell.onDeleteRequested = { [weak self] in
                guard let self = self else { return }
                let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this collection?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                    // call API to delete
                    self.viewModel.deleteFromCustomCollection(customCollectionId: customCollection.id)

                    // safely update local data source (make mutable copy, remove, reassign)
                    if var collections = self.viewModel.allCustomCollection?.custom_collections {
                        if let index = collections.firstIndex(where: { $0.id == customCollection.id }) {
                            collections.remove(at: index)
                            self.viewModel.allCustomCollection?.custom_collections = collections
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            
                            }
                        }
                    }
              
                }))
                    
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true)
            }
        }
        return cell
    }

}
extension CollectionsViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return  CGSize(width: 180, height: 244)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 30, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "HeaderView",
            for: indexPath
        )
        
        // Remove old labels if reused
        header.subviews.forEach { $0.removeFromSuperview() }
        
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: collectionView.frame.width - 32, height: 40))
        label.font = UIFont.boldSystemFont(ofSize: 20)
        
        if indexPath.section == 0 {
            label.text = "Brands"
        } else {
            label.text = "Custom Collections"
        }
        
        header.addSubview(label)
        return header
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
    
}
