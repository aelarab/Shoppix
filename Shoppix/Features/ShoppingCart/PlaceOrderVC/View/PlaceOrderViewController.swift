//
//  PlaceOrderViewController.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 26/10/2025.
//

import UIKit
import PassKit
import RxSwift
import FirebaseAuth

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
    private var cartSubtotal: Double = 0.0
    private var shippingFees: Double = 0.0
    private let cartService = ShopifyCartService.shared
    private let disposeBag = DisposeBag()

    
       //MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        placeOrderButton.layer.cornerRadius = placeOrderButton.frame.height / 2
        UserDefaults.standard.set(false, forKey: "couponUsed")

        updateTotals()
        checkCouponUsage()
        loadCartData()
setupCouponTextField()
    }
    
       //MARK: - Behaviour
    
    private func setupCouponTextField() {
        promocodeTextField.delegate = self
        promocodeTextField.placeholder = "Enter coupon code"
        promocodeTextField.textColor = .label
        promocodeTextField.isEnabled = true
        
        promocodeTextField.clearButtonMode = .whileEditing
    }
    
    private func loadCartData() {
            guard let userEmail = Auth.auth().currentUser?.email else {
                showError(message: "Please log in to view your cart.")
                return
            }
            
            cartService.getCart(userEmail: userEmail)
                .observe(on: MainScheduler.instance)
                .subscribe(
                    onNext: { [weak self] draftOrders in
                        guard let self = self, let draftOrder = draftOrders.first else {
                            self?.showError(message: "Your cart is empty")
                            return
                        }
                        
                        if let totalPriceString = draftOrder.total_price,
                           let totalPrice = Double(totalPriceString) {
                            self.cartSubtotal = totalPrice
                            self.shippingFees = 0.0
                            self.updateTotals()
                        }
                    },
                    onError: { [weak self] error in
                        self?.showError(message: "Failed to load cart: \(error.localizedDescription)")
                    }
                )
                .disposed(by: disposeBag)
        }
        
        private func updateTotals() {
            subtotalLabel.text = "\(cartSubtotal) EGP"
            shippingFeesLabel.text = "\(shippingFees) EGP"
            
            calculateGrandTotal(subtotal: cartSubtotal, shipping: shippingFees, discount: 0)
        }
        
        private func calculateGrandTotal(subtotal: Double, shipping: Double, discount: Double) {
            let grandTotal = subtotal + shipping - discount
            grandTotalLabel.text = "\(grandTotal) EGP"
            discountLabel.text = "\(discount) EGP"
            
            print("💰 Price Summary:")
            print("   Subtotal: \(subtotal) EGP")
            print("   Shipping: \(shipping) EGP")
            print("   Discount: \(discount) EGP")
            print("   Grand Total: \(grandTotal) EGP")
        }
    private func checkCouponUsage() {
        if UserDefaults.standard.bool(forKey: "couponUsed") {
            promocodeTextField.isEnabled = false
            validateButton.isEnabled = false
            promocodeTextField.placeholder = "Coupon already used"
            promocodeTextField.textColor = .gray
        } else {
            promocodeTextField.isEnabled = true
            validateButton.isEnabled = true
            promocodeTextField.placeholder = "Enter coupon code"
            promocodeTextField.textColor = .label
        }
    }
    private func applyCoupon(_ coupon: Coupon, discountAmount: Double) {
        guard !isCouponApplied else {
            showAlert(title: "Already Applied", message: "Coupon has already been applied.")
            return
        }
        
        if UserDefaults.standard.bool(forKey: "couponUsed") {
            showAlert(title: "Coupon Used", message: "You can only use one coupon per account.")
            return
        }
        
        // USE ACTUAL CART SUBTOTAL, not hardcoded values
        appliedCoupon = coupon
        isCouponApplied = true
        
        // Update with actual cart data
        calculateGrandTotal(subtotal: cartSubtotal, shipping: shippingFees, discount: discountAmount)
        
        promocodeTextField.isEnabled = false
        validateButton.isEnabled = false
        promocodeTextField.textColor = .gray
        
        UserDefaults.standard.set(true, forKey: "couponUsed")
        
        showAlert(title: "Success", message: "Coupon \(coupon.couponName) applied successfully! You saved \(discountAmount) EGP")
    }
        
    private func validateCoupon(_ code: String) {
        if UserDefaults.standard.bool(forKey: "couponUsed") {
            showAlert(title: "Already Used", message: "You can only use one coupon per account.")
            return
        }
        
        let couponService = ShopifyCouponService.shared
        couponService.getActiveCoupons { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let coupons):
                print(" Found \(coupons.count) active coupons from Shopify")
                
                // Match the entered code (case insensitive)
                if let foundCoupon = coupons.first(where: { $0.code.lowercased() == code.lowercased() }) {
                    print("🎯 Matched coupon: \(foundCoupon.code)")
                    
                    let discountValue = Double(foundCoupon.discountValue.replacingOccurrences(of: "-", with: "")) ?? 0.0
                    
                    var discountAmount = 0.0
                    if foundCoupon.valueType == "percentage" {
                        discountAmount = (self.cartSubtotal * discountValue / 100.0)
                    } else {
                        discountAmount = discountValue
                    }
                    
                    let appliedCoupon = Coupon(
                        couponName: foundCoupon.code,
                        couponDiscount: Float(discountValue),
                        couponImage: UIImage(named: "discount")!,
                        shopifyCode: foundCoupon.code,
                        valueType: foundCoupon.valueType
                    )
                    
                    self.applyCoupon(appliedCoupon, discountAmount: discountAmount)
                } else {
                    print(" No coupon matched the entered code: \(code)")
                    self.showAlert(title: "Invalid Coupon", message: "The coupon code '\(code)' is invalid or expired.")
                }
                
            case .failure(let error):
                print(" Failed to fetch coupons: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Could not validate coupon. Please try again later.")
            }
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

        // FIX: Change "USD" to "EGP"
        guard let totalText = grandTotalLabel.text?.replacingOccurrences(of: " EGP", with: ""),
              let total = Double(totalText) else {
            showError(message: "Invalid total amount")
            return
        }

        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.adham-ragap.Shoppix"
        request.supportedNetworks = [.visa, .masterCard, .amex]
        request.merchantCapabilities = .capability3DS
        request.countryCode = "EG"
        request.currencyCode = "EGP"

        let totalItem = PKPaymentSummaryItem(label: "SHOPPIX Order", amount: NSDecimalNumber(value: total))
        request.paymentSummaryItems = [totalItem]

        if let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) {
            paymentVC.delegate = self
            present(paymentVC, animated: true)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        validateButton.isEnabled = !(textField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
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
            
            // Extract EGP amount
            guard let totalText = self.grandTotalLabel.text?.replacingOccurrences(of: " EGP", with: "") else {
                self.showError(message: "Invalid total amount")
                return
            }

            self.viewModel.selectedPaymentMethod = "cash_on_delivery"
            self.viewModel.totalAmountString = totalText // This is in EGP

            self.viewModel.loadCartAndPlaceOrder { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        let successAlert = UIAlertController(
                            title: "Order Placed Successfully 🎉",
                            message: "Your order for \(totalText) EGP has been confirmed and will be paid upon delivery. A confirmation email has been sent.",
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

extension PlaceOrderViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
