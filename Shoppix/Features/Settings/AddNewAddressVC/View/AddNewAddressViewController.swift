//
//  AddNewAddressViewController.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 29/10/2025.
//

import UIKit
import SearchTextField
import RxSwift

class AddNewAddressViewController: UIViewController {
       //MARK: - Outlets
    
    @IBOutlet weak var countryTextField: SearchTextField!
    @IBOutlet weak var cityTextField: SearchTextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addAddressButton: UIButton!
    @IBOutlet weak var isDefaultSwitch: UISwitch!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
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
        setupUI()
        fetchUserData()
    }
    
       //MARK: - Address update
    private func fetchUserData() {
            viewModel.fetchUserData { [weak self] success in
                DispatchQueue.main.async {
                    if success {
                        print("Successfully fetched user data from Firebase")
                    } else {
                        print("Warning: Could not fetch user data from Firebase")
                        // Set default values
                        self?.viewModel.firstName = "Customer"
                        self?.viewModel.lastName = "User"
                    }
                }
            }
        }
   //MARK: - Behaviour
    
       //MARK: -
    
    private func setupUI() {
        isDefaultSwitch.onTintColor = UIColor(named: "mainColor")
        isDefaultSwitch.isOn = false
    }
    
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
                print("Error: \(message)") // Debug print
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
        viewModel.isDefault = isDefaultSwitch.isOn
        
        // Debug print to verify all data
        print("Saving address with:")
        print("Name: \(viewModel.firstName) \(viewModel.lastName)")
        print("Country: \(viewModel.country)")
        print("City: \(viewModel.city)")
        print("Address: \(viewModel.address)")
        print("Phone: \(viewModel.phone)")
        print("Is Default: \(viewModel.isDefault)")
        print("Customer ID: \(viewModel.customerId ?? 0)")
        
     //   viewModel.saveAddress()
    }
    
    @IBAction func defaultSwitchChanged(_ sender: UISwitch) {
        viewModel.isDefault = sender.isOn
    }
    
}
