//
//  PlaceDetailViewController.swift
//  NearMee
//
//  Created by admin on 17/05/2023.
//

import Foundation
import UIKit

class PlaceDetailViewController: UIViewController {
    
    let place: PlaceAnnotation
    var stackView: UIStackView!
    var contactStackView: UIStackView!
    
    lazy var nameLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        return label
    }()
    
    lazy var addressLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.alpha = 0.4
        return label
    }()
    
    lazy var directionButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Direction", for: .normal)
        
        return button
    }()
    
    lazy var callButton: UIButton = {
        let config = UIButton.Configuration.bordered()
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Call", for: .normal)
        return button
    }()
    
    init(place: PlaceAnnotation) {
        self.place = place
        super.init(nibName: nil, bundle: nil)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    @objc private func directionButtonTapped() {
        let coordinate = place.location.coordinate
        guard let url = URL(string: "https://maps.apple.com/?daddr=\(coordinate.latitude),\(coordinate.longitude)")
        else { return }
        
        UIApplication.shared.open(url)
    }
    
    @objc private func callButtonTapped(_ sender: UIButton) {
        
        //place.phone = +(512)-345-2345
        //what we need = 5123452345
        guard let url =  URL(string: "tel://\(place.phone.formatPhoneCall)") else { return }
        UIApplication.shared.open(url)
    }
    
    private func setupUI() {
        style()
        layout()
    }
    
    private func style() {
        stackView = UIStackView()
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.text = place.name
        
        addressLabel.text = place.address
        
        contactStackView = UIStackView()
        contactStackView.translatesAutoresizingMaskIntoConstraints = false
        contactStackView.axis = .horizontal
        contactStackView.spacing = UIStackView.spacingUseSystem
        
        directionButton.addTarget(self, action: #selector(directionButtonTapped), for: .touchUpInside)
        callButton.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        
    }
    
    private func layout() {
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(addressLabel)
        
        contactStackView.addArrangedSubview(directionButton)
        contactStackView.addArrangedSubview(callButton)
        
        stackView.addArrangedSubview(contactStackView)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            nameLabel.widthAnchor.constraint(equalToConstant: view.bounds.width - 20)
        ])
    }
}
