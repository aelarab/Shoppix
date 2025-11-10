//
//  PlaceOrderViewController.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 26/10/2025.
//

import UIKit
import PassKit

class PlaceOrderViewController: UIViewController {
       //MARK: - Outlets
    
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var shippingFeesLabel: UILabel!
    @IBOutlet weak var promocodeTextField: UITextField!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var grandTotalLabel: UILabel!
    @IBOutlet weak var placeOrderButton: UIButton!
    
    @IBOutlet weak var validateButton: UIButton!
    
       //MARK: - properties
    private var paymentRequest: PKPaymentRequest?
    var selectedPaymentMethod: String?
    private let viewModel = PlaceOrderViewModel()
    private var appliedCoupon: Coupon?
    private var isCouponApplied = false
    
       //MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        placeOrderButton.layer.cornerRadius = placeOrderButton.frame.height / 2
        updateTotals()
        checkCouponUsage()
    }
    
       //MARK: - Behaviour
    
    private func updateTotals() {
        let subtotal: Double = 100.0
        let shipping: Double = 10.0
        
        subtotalLabel.text = "\(subtotal) EGP"
        shippingFeesLabel.text = "\(shipping) EGP"
        
        calculateGrandTotal(subtotal: subtotal, shipping: shipping, discount: 0)
    }
    private func calculateGrandTotal(subtotal: Double, shipping: Double, discount: Double) {
            let grandTotal = subtotal + shipping - discount
            grandTotalLabel.text = "\(grandTotal) EGP"
            discountLabel.text = "\(discount) EGP"
        }
        
        private func checkCouponUsage() {
            if UserDefaults.standard.bool(forKey: "couponUsed") {
                promocodeTextField.isEnabled = false
                validateButton.isEnabled = false
                promocodeTextField.placeholder = "Coupon already used"
                promocodeTextField.textColor = .gray
            }
        }
        
        private func applyCoupon(_ coupon: Coupon) {
            guard !isCouponApplied else {
                showAlert(title: "Already Applied", message: "Coupon has already been applied.")
                return
            }
            
            if UserDefaults.standard.bool(forKey: "couponUsed") {
                showAlert(title: "Coupon Used", message: "You can only use one coupon per account.")
                return
            }
            
            let subtotal: Double = 100.0
            let shipping: Double = 10.0
            let discount = subtotal * Double(coupon.couponDiscount) / 100.0
            
            appliedCoupon = coupon
            isCouponApplied = true
            
            calculateGrandTotal(subtotal: subtotal, shipping: shipping, discount: discount)
            
            promocodeTextField.isEnabled = false
            validateButton.isEnabled = false
            promocodeTextField.textColor = .gray
            
            UserDefaults.standard.set(true, forKey: "couponUsed")
            
            showAlert(title: "Success", message: "Coupon \(coupon.couponName) applied successfully!")
        }
        
        private func validateCoupon(_ code: String) {
            if UserDefaults.standard.bool(forKey: "couponUsed") {
                showAlert(title: "Already Used", message: "You can only use one coupon per account.")
                return
            }
            
            let availableCoupons = [
                Coupon(couponName: "25% OFF", couponDiscount: 25, couponImage: UIImage(named: "25coupon")!),
                Coupon(couponName: "50% OFF", couponDiscount: 50, couponImage: UIImage(named: "50coupon")!)
            ]
            
            if let coupon = availableCoupons.first(where: { $0.couponName.lowercased() == code.lowercased() }) {
                applyCoupon(coupon)
            } else {
                showAlert(title: "Invalid Coupon", message: "The coupon code is invalid or expired.")
            }
        }
    
    private func startApplePayPayment() {
            guard PKPaymentAuthorizationViewController.canMakePayments() else {
                let alert = UIAlertController(
                    title: "Apple Pay Not Available",
                    message: "Please set up Apple Pay in your device settings.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }

            guard let totalText = grandTotalLabel.text?.replacingOccurrences(of: " USD", with: ""),
                  let total = Double(totalText) else { return }

            let request = PKPaymentRequest()
            request.merchantIdentifier = "merchant.adham-ragap.Shoppix"
            request.supportedNetworks = [.visa, .masterCard, .amex]
            request.merchantCapabilities = .capability3DS
            request.countryCode = "US"
            request.currencyCode = "USD"

            let totalItem = PKPaymentSummaryItem(label: "SHOPPIX Order", amount: NSDecimalNumber(value: total))
            request.paymentSummaryItems = [totalItem]

            if let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) {
                paymentVC.delegate = self
                present(paymentVC, animated: true)
            }
        }
    
       //MARK: - Actions
    
    @IBAction func validateButtonTapped(_ sender: UIButton) {
        guard let couponCode = promocodeTextField.text, !couponCode.isEmpty else {
                    showAlert(title: "Empty Field", message: "Please enter a coupon code.")
                    return
                }
                
                validateCoupon(couponCode)
        
    }
    @IBAction func placeOrderTapped(_ sender: UIButton) {
        guard let paymentMethod = selectedPaymentMethod else {
               showError(message: "Please select a payment method before placing your order.")
               return
           }

           if paymentMethod == "apple_pay" {
               startApplePayPayment()
           } else if paymentMethod == "cash_on_delivery" {
               confirmCashOnDeliveryOrder()
           } else {
               showError(message: "Unsupported payment method selected.")
           }
       }

       // MARK: - Cash on Delivery Logic
       private func confirmCashOnDeliveryOrder() {
           let alert = UIAlertController(
               title: "Confirm Cash on Delivery",
               message: "Are you sure you want to place this order and pay on delivery?",
               preferredStyle: .alert
           )
           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
           alert.addAction(UIAlertAction(title: "Yes, Place Order", style: .default) { [weak self] _ in
               guard let self = self else { return }
               guard let totalText = self.grandTotalLabel.text?.replacingOccurrences(of: " USD", with: "") else { return }

               self.viewModel.selectedPaymentMethod = "cash_on_delivery"
               self.viewModel.totalAmountString = totalText

               self.viewModel.loadCartAndPlaceOrder { result in
                   DispatchQueue.main.async {
                       switch result {
                       case .success:
                           let successAlert = UIAlertController(
                               title: "Order Placed Successfully ",
                               message: "Your order has been confirmed and will be paid upon delivery.",
                               preferredStyle: .alert
                           )
                           successAlert.addAction(UIAlertAction(title: "Go to Cart", style: .default) { _ in
                               if let tabBar = self.tabBarController {
                                   tabBar.selectedIndex = 2
                                   self.navigationController?.popToRootViewController(animated: true)
                               }
                           })
                           self.present(successAlert, animated: true)

                       case .failure(let error):
                           self.showError(message: error.localizedDescription)
                       }
                   }
               }
           })

           present(alert, animated: true)
    }
}

extension PlaceOrderViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true)
    }

    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        controller.dismiss(animated: true)

        guard let totalText = grandTotalLabel.text?.replacingOccurrences(of: " USD", with: "") else {
            completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
            return
        }

        viewModel.selectedPaymentMethod = "apple_pay"
        viewModel.totalAmountString = totalText

        viewModel.loadCartAndPlaceOrder { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(PKPaymentAuthorizationResult(status: .success, errors: nil))

                    let alert = UIAlertController(
                        title: "Order Placed Successfully",
                        message: "Your order has been confirmed! A receipt has been sent to your email.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Go to Cart", style: .default) { _ in
                        let cartVC = ShoppingCartViewController(
                            nibName: "ShoppingCartViewController",
                            bundle: nil
                        )
                        self.navigationController?.pushViewController(cartVC, animated: true)
                    })
                    self.present(alert, animated: true)

                case .failure(let error):
                    completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                    self.showError(message: error.localizedDescription)
                }
            }
        }
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Order Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
