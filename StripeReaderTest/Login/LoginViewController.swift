//
//  LocationController.swift
//  StripeReaderTest
//
//  Created by Максим on 15.08.2024.
//

import UIKit
import SnapKit

class LoginViewController: BaseViewController {
    
    var mainContainer: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 20
        return $0
    }(UIStackView())
    
    var customerSection = SectionTitle(title: "Ios User Test", value: "+1 (112) 22 3344")
    
    var credentialsSection = SectionTitle(title: "", value: "")
    
    lazy var environmentSection = SectionView(buttonTitle: "Change Environment", 
                                              tapHandler: { [weak self] sectionView in
        self?.changeEnvironment(sourceView: sectionView.button)
    })
    
    lazy var tokenSection = SectionView(tapHandler: { [weak self] sectionView in
        self?.refreshToken(environment: LocalStorage.environment)
    })
    
    lazy var restaurantSection = SectionView(tapHandler: { [weak self] sectionView in
        self?.fetchLocations()
    })
    
    lazy var readerSimulatorSection = SectionView(
        title: "Stripe simulator",
        tapHandler: { [weak self] sectionView in
            LocalStorage.isStripeSimulatorEnabled.toggle()
            self?.stripeManager.disconnectReader() {
                self?.refreshViews()
            }
    })
    
    lazy var readerTypeSection = SectionView(
        title: "Reader type",
        tapHandler: { [weak self] sectionView in
            LocalStorage.readerType.toggle()
            self?.stripeManager.disconnectReader() {
                self?.refreshViews()
            }
    })
    
    
    lazy var readerStatusSection = SectionView(
        title: "Reader status",
        tapHandler: { [weak self] sectionView in
            self?.stripeManager.disconnectReader(target: self) {
                self?.refreshViews()
            }
    })
    
    private var stripeManager: StripeManager
    
    init(stripeManager: StripeManager) {
        self.stripeManager = stripeManager
        
        super.init()
        
        title = "Login"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
        
        configViews()
        refreshViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configViews() {
        
        view.addSubview(mainContainer)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            mainContainer.snp.makeConstraints({
                $0.center.equalToSuperview()
                $0.width.equalTo(UIScreen.main.bounds.width/2)
            })
        } else {
            mainContainer.snp.makeConstraints({
                $0.centerY.equalToSuperview()
                $0.left.right.equalToSuperview().inset(20)
            })
        }
        
        mainContainer.addArrangedSubviews([credentialsSection,
                                           customerSection,
                                           environmentSection,
                                           tokenSection,
                                           restaurantSection,
                                           readerSimulatorSection,
                                           readerTypeSection,
                                           readerStatusSection])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshViews()
    }
    
    func refreshViews() {
        
        credentialsSection.nameLabel.text = LocalStorage.environment.login
        credentialsSection.valueLabel.text = LocalStorage.environment.password
        
        environmentSection.label.text = LocalStorage.environment.url
        
        tokenSection.label.text = LocalStorage.token
        let tokenButtonTitle = LocalStorage.token == nil ? "Generate\nToken" : "Refresh\nToken"
        tokenSection.button.setTitle(tokenButtonTitle, for: .normal)
        
        restaurantSection.label.text =
        """
        \(LocalStorage.restaurant?.name ?? "")
        "id2": \(LocalStorage.restaurant?.id2 ?? "")
        "uuid": \(LocalStorage.restaurant?.uuid ?? "")
        """
        let locationButtonTitle = LocalStorage.token == nil ? "Select\nRestaurant" : "Change\nRestaurant"
        restaurantSection.button.setTitle(locationButtonTitle, for: .normal)

        readerSimulatorSection.button.setTitle(LocalStorage.isStripeSimulatorEnabled ? "On" : "Off", for: .normal)
        
        readerTypeSection.button.setTitle(LocalStorage.readerType.rawValue, for: .normal)
        
        readerStatusSection.label.text = stripeManager.isReaderConnected ? "Reader status 🟢" : "Reader status 🔴"
        readerStatusSection.button.setTitle(stripeManager.isReaderConnected ? "Disconnect" : "Disconnected", for: .normal)
        
        self.navigationItem.rightBarButtonItem?.isEnabled = Globals.isLoggedIn
    }
    
    func changeEnvironment(sourceView: UIView) {
        
        let alert = UIAlertController(title: "Choose Environment", message: nil, preferredStyle: .actionSheet)
        
        let staging = UIAlertAction(title: Environment.staging.rawValue, style: .default, handler: { _ in
            LocalStorage.environment = .staging
            self.stripeManager.disconnectReader() {
                self.refreshViews()
            }
        })
        alert.addAction(staging)
        
        let production = UIAlertAction(title: Environment.production.rawValue, style: .default, handler: { _ in
            LocalStorage.environment = .production
            self.stripeManager.disconnectReader() {
                self.refreshViews()
            }
        })
        alert.addAction(production)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in

        })
        alert.addAction(cancel)
        
        alert.popoverPresentationController?.sourceView = sourceView
        alert.popoverPresentationController?.sourceRect = sourceView.bounds
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func refreshToken(environment: Environment) {
        let login = environment.login
        let password = environment.password
        
        Task {
            do {
                let manager = APIManager.refreshToken(login: login, password: password)
                showLoading()
                let response: LoginResponse = try await manager.makeRequest()
                hideLoading()
                LocalStorage.token = response.token
                self.refreshViews()
            } catch {
                hideLoading()
                self.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func fetchLocations() {
        
        Task {
            do {
                showLoading()
                let response: AuthResponse = try await APIManager.auth.makeRequest()
                hideLoading()
                let locations = response.locations
                presentLocationPicker(sourceView: restaurantSection.button, locations: locations)
            } catch {
                hideLoading()
                showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func presentLocationPicker(sourceView: UIView, locations: [Restaurant]) {
        
        let alert = UIAlertController(title: "Choose Restaurant", message: nil, preferredStyle: .actionSheet)
        
        locations.forEach({ location in
            let action = UIAlertAction(title: location.name, style: .default, handler: { _ in
                Task {
                    let location: Restaurant = try await APIManager.fetchLocation(id: location.id).makeRequest()
                    LocalStorage.restaurant = location
                    self.stripeManager.disconnectReader() {
                        DispatchQueue.main.async {
                            self.refreshViews()
                        }
                    }
                }
            })
            alert.addAction(action)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in

        })
        alert.addAction(cancel)
        
        alert.popoverPresentationController?.sourceView = sourceView
        alert.popoverPresentationController?.sourceRect = sourceView.bounds
        
        self.present(alert, animated: true, completion: nil)
        
    }
}
