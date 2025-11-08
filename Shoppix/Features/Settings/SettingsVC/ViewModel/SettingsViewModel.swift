//
//  SettingsViewModel.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 04/11/2025.
//

import Foundation
import RxSwift

final class SettingsViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    var onCurrencyChanged: ((String) -> Void)?
    
    init() {
        CurrencyService.shared.currentCurrency
            .subscribe(onNext: { [weak self] currency in
                self?.onCurrencyChanged?(currency)
            })
            .disposed(by: disposeBag)
    }

    
    // MARK: - Behaviour
    func updateCurrency(to newCurrency: String) {
        CurrencyService.shared.updateCurrency(newCurrency)
    }
}
