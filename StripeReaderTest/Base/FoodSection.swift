//
//  SectionTitle.swift
//  StripeReaderTest
//
//  Created by Максим on 19.08.2024.
//

import UIKit

class FoodSection: UIView {
    
    var container: UIStackView = {
        $0.axis = .horizontal
        $0.spacing = 20
        $0.alignment = .center
        return $0
    }(UIStackView())
    
    var nameLabel: UILabel = {
        $0.text = ""
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        return $0
    }(UILabel())
    
    var valueLabel: UILabel = {
        $0.text = ""
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textAlignment = .right
        return $0
    }(UILabel())
    
    init(title: String? = nil, value: String? = nil, color: UIColor? = nil) {
        super.init(frame: .zero)
        
        self.nameLabel.text = title
        self.valueLabel.text = value
        
        self.nameLabel.textColor = color
        self.valueLabel.textColor = color
        
        addSubview(container)
        container.snp.makeConstraints({ $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)) })
        
        container.addArrangedSubviews([nameLabel, valueLabel])
        
        valueLabel.setTitlePriority(label: nameLabel, axis: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
