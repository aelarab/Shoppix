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
    
       //MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        placeOrderButton.layer.cornerRadius = placeOrderButton.frame.height / 2
    }
    
       //MARK: - Behaviour
    private func startApplePayPayment() {
            // Ensure device supports Apple Pay
            guard PKPaymentAuthorizationViewController.canMakePayments() else {
                let alert = UIAlertController(title: "Apple Pay Not Available",
                                              message: "Please set up Apple Pay in your device settings.",
                                              preferredStyle: .alert)
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


// MARK: - PKPaymentAuthorizationViewControllerDelegate
extension PlaceOrderViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true)
    }

    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        // Here you’d send payment.token to your backend to process the charge
        print("Apple Pay Token: \(payment.token)")

        // Simulate success
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
}
