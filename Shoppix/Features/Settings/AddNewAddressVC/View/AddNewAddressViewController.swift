//
//  AddNewAddressViewController.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 29/10/2025.
//

import UIKit
import SearchTextField

class AddNewAddressViewController: UIViewController {
       //MARK: - Outlets
    
    @IBOutlet weak var countryTextField: SearchTextField!
    @IBOutlet weak var cityTextField: SearchTextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addAddressButton: UIButton!
    
    
    // MARK: - Properties
    private let viewModel = AddAddressViewModel()
    private var countries: [Country] = []
    
    
       //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addAddressButton.layer.cornerRadius = addAddressButton.frame.height / 2
        tabBarController?.tabBar.isHidden = true
        bindViewModel()
        setupCountrySearch()
        loadCountries()
        setupCountrySearch()
    }

   //MARK: - Behaviour
    
    private func loadCountries() {
        guard let path = Bundle.main.path(forResource: "countries", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            print("Failed to load countries.json")
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode(CountryData.self, from: data)
            countries = decoded.countries
        } catch {
            print(" JSON decode error:", error)
        }
    }
    
    private func setupCountrySearch() {
        let countryNames = countries.map { $0.name }
        countryTextField.filterStrings(countryNames)
        
        countryTextField.itemSelectionHandler = { [weak self] items, index in
            guard let self = self else { return }
            let selectedCountry = items[index].title
            self.viewModel.country = selectedCountry
            self.countryTextField.text = selectedCountry
            self.setupCitySearch(for: selectedCountry)
            self.cityTextField.becomeFirstResponder()
        }
    }
    private func setupCitySearch(for countryName: String) {
           guard let selectedCountry = countries.first(where: { $0.name == countryName }) else {
               cityTextField.filterStrings(["No cities available"])
               return
           }
           
           cityTextField.filterStrings(selectedCountry.cities)
           cityTextField.itemSelectionHandler = { [weak self] items, index in
               let selectedCity = items[index].title
               self?.viewModel.city = selectedCity
               self?.cityTextField.text = selectedCity
           }
       }
    
    private func bindViewModel() {
        viewModel.onSuccess = { [weak self] in
            DispatchQueue.main.async {
                self?.showAlert("Address saved successfully!")
                NotificationCenter.default.post(name: .didAddNewAddress, object: nil)
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.showAlert(message)
            }
        }
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "SHOPPIX", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction func addAddressPressed(_ sender: UIButton) {
        viewModel.country = countryTextField.text ?? ""
        viewModel.city = cityTextField.text ?? ""
        viewModel.address = addressTextField.text ?? ""
        viewModel.phone = phoneTextField.text ?? ""
        
        viewModel.saveAddress()
    }
}
