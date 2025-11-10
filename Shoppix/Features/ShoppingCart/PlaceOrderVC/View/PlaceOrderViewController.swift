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
    
    // MARK: - Properties
    private var paymentRequest: PKPaymentRequest?
    var selectedPaymentMethod: String?
    private let viewModel = PlaceOrderViewModel()
    private var appliedCoupon: Coupon?
    private var isCouponApplied = false
    private var cartSubtotal: Double = 0.0
    private var shippingFees: Double = 50.0
    private var discountAmount: Double = 0.0
    private let cartService = ShopifyCartService.shared
    private let disposeBag = DisposeBag()
    private var cartItems: [DraftOrderLineItem] = []
    
       //MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
setupUI()
        loadCartData()
setupCouponTextField()
    }
    
    
       //MARK: - Behaviour
    
        private func setupUI() {
            placeOrderButton.layer.cornerRadius = placeOrderButton.frame.height / 2
            UserDefaults.standard.set(false, forKey: "couponUsed")
            checkCouponUsage()
            placeOrderButton.setTitle("Place Order", for: .normal)
            designButton(button: placeOrderButton)
            designTextField(text: promocodeTextField)
        }
    
    
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
                    
                    self.cartItems = draftOrder.line_items
                    self.calculateCartSubtotal()
                    self.updateTotals()
                },
                onError: { [weak self] error in
                    self?.showError(message: "Failed to load cart: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func calculateCartSubtotal() {
           cartSubtotal = cartItems.reduce(0.0) { total, item in
               let price = Double(item.price ?? "0") ?? 0.0
               let quantity = Double(item.quantity)
               return total + (price * quantity)
           }
       }
        
    private func updateTotals() {
            let currency = CurrencyService.shared.currentCurrency
            
            // Convert amounts to current currency
            let convertedSubtotal = CurrencyService.shared.convert(amount: cartSubtotal, from: "EGP", to: currency)
            let convertedShipping = CurrencyService.shared.convert(amount: shippingFees, from: "EGP", to: currency)
            let convertedDiscount = CurrencyService.shared.convert(amount: discountAmount, from: "EGP", to: currency)
            
            subtotalLabel.text = "Subtotal: \(CurrencyService.shared.formatPrice(convertedSubtotal, currency: currency))"
            shippingFeesLabel.text = "Shipping: \(CurrencyService.shared.formatPrice(convertedShipping, currency: currency))"
            discountLabel.text = "Discount: -\(CurrencyService.shared.formatPrice(convertedDiscount, currency: currency))"
            
            calculateGrandTotal()
        }
        
    private func calculateGrandTotal() {
            let currency = CurrencyService.shared.currentCurrency
            let grandTotal = cartSubtotal + shippingFees - discountAmount
            let convertedGrandTotal = CurrencyService.shared.convert(amount: grandTotal, from: "EGP", to: currency)
            
            grandTotalLabel.text = "Total: \(CurrencyService.shared.formatPrice(convertedGrandTotal, currency: currency))"

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
    private func applyCoupon(_ coupon: Coupon, discountValue: Double, valueType: String) {
            guard !isCouponApplied else {
                showAlert(title: "Already Applied", message: "Coupon has already been applied.")
                return
            }
            
            if UserDefaults.standard.bool(forKey: "couponUsed") {
                showAlert(title: "Coupon Used", message: "You can only use one coupon per account.")
                return
            }
            
            // Calculate discount amount based on value type
            if valueType == "percentage" {
                discountAmount = (cartSubtotal * discountValue / 100.0)
            } else {
                discountAmount = min(discountValue, cartSubtotal)
            }
            
            appliedCoupon = coupon
            isCouponApplied = true
            updateTotals()
            promocodeTextField.isEnabled = false
            validateButton.isEnabled = false
            promocodeTextField.textColor = .gray
            UserDefaults.standard.set(true, forKey: "couponUsed")
            
            showAlert(title: "Success", message: "Coupon \(coupon.couponName) applied successfully! You saved \(CurrencyService.shared.formatPrice(discountAmount, currency: "EGP"))")
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
                    
                    if let foundCoupon = coupons.first(where: { $0.code.lowercased() == code.lowercased() }) {
                        print("🎯 Matched coupon: \(foundCoupon.code)")
                        
                        let discountValue = Double(foundCoupon.discountValue.replacingOccurrences(of: "-", with: "")) ?? 0.0
                        
                        let appliedCoupon = Coupon(
                            couponName: foundCoupon.code,
                            couponDiscount: Float(discountValue),
                            couponImage: UIImage(named: "discount")!,
                            shopifyCode: foundCoupon.code,
                            valueType: foundCoupon.valueType
                        )
                        
                        self.applyCoupon(appliedCoupon, discountValue: discountValue, valueType: foundCoupon.valueType)
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
    
    private func startApplePayPayment(total: Double) {
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

            let request = PKPaymentRequest()
            request.merchantIdentifier = "merchant.adham-ragap.Shoppix"
            request.supportedNetworks = [.visa, .masterCard, .amex, .mada]
            request.merchantCapabilities = .capability3DS
            request.countryCode = "EG"
            request.currencyCode = "EGP"
            
            let applePayAmount = total
            
            guard applePayAmount > 0 && applePayAmount <= 100000 else {
                showError(message: "Invalid payment amount for Apple Pay")
                return
            }
            
            let formattedAmount = NSDecimalNumber(value: applePayAmount).rounding(accordingToBehavior:
                NSDecimalNumberHandler(roundingMode: .plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false))
            
            let totalItem = PKPaymentSummaryItem(
                label: "SHOPPIX Order",
                amount: formattedAmount
            )
            request.paymentSummaryItems = [totalItem]
            if let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) {
                paymentVC.delegate = self
                present(paymentVC, animated: true)
            } else {
                showError(message: "Failed to initialize Apple Pay. Please check your configuration.")
            }
        }
        
    private func confirmCashOnDeliveryOrder(total: Double) {
           let currency = CurrencyService.shared.currentCurrency
           let displayTotal = CurrencyService.shared.formatPrice(
               CurrencyService.shared.convert(amount: total, from: "EGP", to: currency),
               currency: currency
           )
           
           let alert = UIAlertController(
               title: "Confirm Cash on Delivery",
               message: "Are you sure you want to place this order for \(displayTotal) and pay on delivery?",
               preferredStyle: .alert
           )
           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
           alert.addAction(UIAlertAction(title: "Yes, Place Order", style: .default) { [weak self] _ in
               guard let self = self else { return }
               
               self.processOrderPayment(total: total, paymentMethod: "cash_on_delivery")
           })

           present(alert, animated: true)
       }
    
    private func processOrderPayment(total: Double, paymentMethod: String) {
            viewModel.selectedPaymentMethod = paymentMethod
            viewModel.totalAmountString = String(format: "%.2f", total)
            
            viewModel.loadCartAndPlaceOrder { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.showOrderSuccess(total: total, paymentMethod: paymentMethod)
                    case .failure(let error):
                        self?.showError(message: error.localizedDescription)
                    }
                }
            }
        }
    
    private func showOrderSuccess(total: Double, paymentMethod: String) {
        let currency = CurrencyService.shared.currentCurrency
        let displayTotal = CurrencyService.shared.formatPrice(
            CurrencyService.shared.convert(amount: total, from: "EGP", to: currency),
            currency: currency
        )
        
        let paymentMethodText = paymentMethod == "apple_pay" ? "Apple Pay" : "Cash on Delivery"
        
        let successAlert = UIAlertController(
            title: "Order Placed Successfully ",
            message: "Your order for \(displayTotal) has been confirmed via \(paymentMethodText). A confirmation email has been sent.",
            preferredStyle: .alert
        )
        successAlert.addAction(UIAlertAction(title: "View Empty Cart", style: .default) { [weak self] _ in
            self?.navigateToEmptyCart()
        })
        present(successAlert, animated: true)
    }
    
    private func navigateToEmptyCart() {
           UserDefaults.standard.set(false, forKey: "couponUsed")
           
           if let tabBarController = self.tabBarController {
               tabBarController.selectedIndex = 2
               if let navigationController = tabBarController.viewControllers?[2] as? UINavigationController {
                   navigationController.popToRootViewController(animated: true)
               }
           }
           self.navigationController?.popToRootViewController(animated: true)
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

                let finalTotal = cartSubtotal + shippingFees - discountAmount
                
                if paymentMethod == "apple_pay" {
                    startApplePayPayment(total: finalTotal)
                } else if paymentMethod == "cash_on_delivery" {
                    confirmCashOnDeliveryOrder(total: finalTotal)
                } else {
                    showError(message: "Unsupported payment method selected.")
                }
       }

    private func confirmCashOnDeliveryOrder() {
        let alert = UIAlertController(
            title: "Confirm Cash on Delivery",
            message: "Are you sure you want to place this order and pay on delivery?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes, Place Order", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            guard let totalText = self.grandTotalLabel.text?.replacingOccurrences(of: " EGP", with: "") else {
                self.showError(message: "Invalid total amount")
                return
            }

            self.viewModel.selectedPaymentMethod = "cash_on_delivery"
            self.viewModel.totalAmountString = totalText

            self.viewModel.loadCartAndPlaceOrder { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        let successAlert = UIAlertController(
                            title: "Order Placed Successfully ",
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
               let finalTotal = cartSubtotal + shippingFees - discountAmount

               viewModel.selectedPaymentMethod = "apple_pay"
               viewModel.totalAmountString = String(format: "%.2f", finalTotal)

               viewModel.loadCartAndPlaceOrder { [weak self] result in
                   DispatchQueue.main.async {
                       switch result {
                       case .success:
                           completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                           
                           controller.dismiss(animated: true) {
                               self?.navigateToEmptyCart()
                           }
                           
                       case .failure(let error):
                           completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
                           self?.showError(message: error.localizedDescription)
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
