//
//  HomeViewController.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 23/10/2025.
//

import UIKit
import SDWebImage

class HomeViewController: UIViewController {
       //MARK: - Properties
    var homeViewModel : HomeViewModel?
    var coupons = [Coupon]()
    var couponTimer: Timer?
    var currentCouponIndex = 0
    @IBOutlet weak var andicator: UIActivityIndicatorView!
    
    
   //MARK: - Outlets
    var vendorsList = [SmartCollection]()
    var filterdList = [SmartCollection]()
    @IBOutlet weak var categoriesSearchBar: UISearchBar!
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    @IBOutlet weak var couponsCollectionView: UICollectionView!
    @IBOutlet weak var couponsPageControl: UIPageControl!
    
    var searchHidden:Bool = true
       //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        andicator.startAnimating()
        homeViewModel = HomeViewModel(delegete: self)
        homeViewModel?.getDataFromServer()
        homeViewModel?.getCoupons()
        startCouponAutoScroll()
        navigationItem.hidesBackButton = true
        categoriesSearchBar.delegate = self

        categoriesCollectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.delegate = self
        couponsCollectionView.register(UINib(nibName: "ProductImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductImageCollectionViewCell")
        couponsCollectionView.delegate = self
        couponsCollectionView.dataSource = self
        let searchButton = UIBarButtonItem(
                barButtonSystemItem: .search,
                target: self,
                action: #selector(didTapSearch)
            )
        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .done, target: self, action: #selector(openFavoriteScreen))
        categoriesSearchBar.isHidden = searchHidden
        searchButton.tintColor = UIColor(named: "mainColor")
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItems = [searchButton]
        navigationItem.rightBarButtonItem = favoriteButton
        
        if let layout = couponsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
        }
        couponsCollectionView.isPagingEnabled = true
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        couponTimer?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startCouponAutoScroll()
        categoriesCollectionView.reloadData()
        couponsCollectionView.reloadData()
    }



       //MARK: - Behaviour
    
    func startCouponAutoScroll() {
        couponTimer?.invalidate() // stop any old timers
        couponTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.coupons.isEmpty { return }
            
            self.currentCouponIndex = (self.currentCouponIndex + 1) % self.coupons.count
            let indexPath = IndexPath(item: self.currentCouponIndex, section: 0)
            self.couponsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.couponsPageControl.currentPage = self.currentCouponIndex
        }
    }

    @objc private func didTapSearch() {
        searchHidden.toggle()
       
        categoriesSearchBar.isHidden = searchHidden
    }
    @objc func openFavoriteScreen(){
       let favoriteVC = FavoriteViewController(nibName: "FavoriteViewController", bundle: nil)
        self.navigationController?.pushViewController(favoriteVC, animated: true)
    }


    
}
extension HomeViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollectionView {
                    return filterdList.count
                } else {
                    return coupons.count
                }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoriesCollectionView {
            
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as? ProductCollectionViewCell  else {
                return UICollectionViewCell()
            }
            cell.image.sd_setImage(
                with: URL(string:  filterdList[indexPath.row].image?.src ?? "Shoppix"),
                placeholderImage: UIImage(named: "Shoppix")
            )
            cell.Name.text = filterdList[indexPath.row].title
            cell.Name.textAlignment = .center
            cell.Name.font = UIFont(name: "MarkerFelt-Thin", size: 22.0)
            cell.deleteButtonOutlet.isHidden = true
            cell.priceLabel.isHidden = true
            
            return cell } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductImageCollectionViewCell", for: indexPath) as? ProductImageCollectionViewCell
                let coupon = coupons[indexPath.item]
                cell?.producDetailtImage.image = coupon.couponImage
                return cell!
            }
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == couponsCollectionView {
            return CGSize(width: couponsCollectionView.frame.width,
                          height: couponsCollectionView.frame.height)
        } else {
            return CGSize(width: categoriesCollectionView.frame.width / 2 - 10,
                          height: categoriesCollectionView.frame.height / 2 - 60)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == couponsCollectionView {
            let selectedCoupon = coupons[indexPath.item]
            UIPasteboard.general.string = selectedCoupon.couponName

            let alert = UIAlertController(title: "Copied!", message: "Coupon \(selectedCoupon.couponName) copied.", preferredStyle: .alert)
            present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                alert.dismiss(animated: true)
            }
        } else if collectionView == categoriesCollectionView {
            guard checkInternetConnection() else { return }
            Session.vendorName = filterdList[indexPath.row].title
            let vc = ProductsViewController(nibName: "ProductsViewController", bundle: nil)
            vc.selectedVendor = Session.vendorName
            print("vendor name :\(Session.vendorName)")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
extension HomeViewController: SendProuctDelegete {
    func sendData(smartCollectionModel: SmartCollectionModel?) {
        vendorsList = smartCollectionModel?.smart_collections ?? [SmartCollection(id: 1, title: "no data", handle: "no", image: SmartImage(src: ""))]
        filterdList = vendorsList
        DispatchQueue.main.async {
            self.andicator.stopAnimating()
            self.categoriesCollectionView.reloadData()
        }
    }
    
    
    func didFetchCoupons(_ coupons: [Coupon]) {
        self.coupons = coupons
        DispatchQueue.main.async {
            self.couponsPageControl.numberOfPages = coupons.count
            self.couponsPageControl.currentPage = 0

            self.couponsPageControl.pageIndicatorTintColor = .lightGray
            self.couponsPageControl.currentPageIndicatorTintColor = UIColor(named: "mainColor") ?? .systemBlue

            self.couponsCollectionView.reloadData()
        }
    }

    
    
}
extension HomeViewController :UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filterdList = vendorsList
        }else {
            filterdList = vendorsList.filter({ $0.title.range(of: searchText,options: .caseInsensitive) != nil
                
            })
        }
        self.categoriesCollectionView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
extension HomeViewController {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == couponsCollectionView else { return }
        let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
        couponsPageControl.currentPage = page
        currentCouponIndex = page
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard scrollView == couponsCollectionView else { return }
        let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
        couponsPageControl.currentPage = page
    }

}
