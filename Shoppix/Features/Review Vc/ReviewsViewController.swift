//
//  ReviewsViewController.swift
//  SHOPPIX
//
//  Created by adham ragap on 31/10/2025.
//

import UIKit
struct User {
    var name:String
    var review:String
}
class ReviewsViewController: UIViewController {
    var reviewsArray = [User]()
    @IBOutlet weak var reviewsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        reviewsTableView.dataSource = self
        reviewsTableView.register(UINib(nibName: "ReviewCellTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewCellTableViewCell")
        reviewsArray = [
           User(name: "Ahmed Ali", review: "It's awesome. Totally worth it!"),
           User(name: "Sara Mohamed", review: "Amazing quality, will buy again."),
           User(name: "Omar Youssef", review: "Loved it! Fast delivery and great packaging."),
           User(name: "Mona Hassan", review: "The color was exactly as shown, very happy."),
           User(name: "Yara Adel", review: "Perfect fit and comfortable to use."),
           User(name: "Mostafa Nabil", review: "Good product for the price, I recommend it."),
           User(name: "Nour Samir", review: "Arrived on time, works perfectly."),
           User(name: "Hassan Mahmoud", review: "I liked it, but could be slightly cheaper."),
           User(name: "Eman Khaled", review: "Excellent! I’ll definitely order again."),
           User(name: "Karim Tarek", review: "Nice quality, exceeded my expectations."),
           User(name: "Huda Fathy", review: "Not bad, but delivery took a bit long."),
           User(name: "Ali Gamal", review: "Fantastic! Highly recommend this store."),
           User(name: "Laila Saeed", review: "Product looks premium and feels durable."),
           User(name: "Mohamed Hossam", review: "Exactly what I was looking for."),
           User(name: "Salma Reda", review: "Very good experience, thank you!"),
           User(name: "Tamer Ibrahim", review: "Great packaging and fast response."),
           User(name: "Farah Nasser", review: "Satisfied overall, product matches description."),
           User(name: "Youssef Adel", review: "Awesome! I love this item."),
           User(name: "Reem Ashraf", review: "The quality is top-notch, worth every pound."),
           User(name: "Ola Rashed", review: "Very nice material and color."),
           User(name: "Amr Ayman", review: "Decent product, but packaging was damaged."),
           User(name: "Marwan Khalil", review: "Arrived quickly, works great."),
           User(name: "Dina Mostafa", review: "Super comfortable and stylish."),
           User(name: "Khaled Ramadan", review: "Happy with my purchase! Thanks."),
           User(name: "Aya Taha", review: "Love it! Will buy another one soon."),
           User(name: "Mahmoud Sayed", review: "Exactly as shown in pictures."),
           User(name: "Hanaa Youssef", review: "Product is good but took long to arrive."),
           User(name: "Rana Mohamed", review: "Five stars! Great experience."),
           User(name: "Ahmed Reda", review: "Everything was perfect from start to finish.")
           ]
   
}
}
extension ReviewsViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCellTableViewCell", for: indexPath)  as? ReviewCellTableViewCell else {
            return UITableViewCell()
        }
        cell.reviewName.text = reviewsArray[indexPath.row].name
        cell.reviewLabel.text = reviewsArray[indexPath.row].review
        return cell
    }
}
