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

       //MARK: - properties
    private var paymentRequest: PKPaymentRequest?
    var selectedPaymentMethod: String?
    private let viewModel = PlaceOrderViewModel()
    
       //MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        placeOrderButton.layer.cornerRadius = placeOrderButton.frame.height / 2
    }
    
       //MARK: - Behaviour
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

            // Get total from label
            guard let totalText = grandTotalLabel.text?.replacingOccurrences(of: " USD", with: ""),
                  let total = Double(totalText) else { return }

            // Create payment request
            let request = PKPaymentRequest()
            request.merchantIdentifier = "merchant.adham-ragap.Shoppix"
            request.supportedNetworks = [.visa, .masterCard, .amex]
            request.merchantCapabilities = .capability3DS
            request.countryCode = "US"
            request.currencyCode = "USD"

            // Line items
            let totalItem = PKPaymentSummaryItem(label: "SHOPPIX Order", amount: NSDecimalNumber(value: total))
            request.paymentSummaryItems = [totalItem]

            // Present Apple Pay sheet
            if let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) {
                paymentVC.delegate = self
                present(paymentVC, animated: true)
            }
        }
    
       //MARK: - Actions
    
    @IBAction func placeOrderTapped(_ sender: UIButton) {
        startApplePayPayment()
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

        // Use grandTotalLabel as total amount
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
                        title: "Order Placed Successfully 🎉",
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
