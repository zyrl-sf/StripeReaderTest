//
//  ReaderFailedView.swift
//  StripeReaderTest
//
//  Created by Максим on 26.08.2024.
//

import UIKit


class ReaderFailedView: UIView {
    
    private var container: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 24
        $0.alignment = .center
        return $0
    }(UIStackView())
    
    var readerId: UILabel = {
        $0.text = ""
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    var icon: UIImageView = {
        $0.image = LocalStorage.readerType.icon
        $0.contentMode = .scaleAspectFill
        $0.snp.makeConstraints({ $0.size.equalTo(CGSize(width: 200, height: 200)) })
        return $0
    }(UIImageView())
    
    private var cover: UIView = {
        $0.backgroundColor = .white.withAlphaComponent(0.3)
        return $0
    }(UIView())
    
    var label: UILabel = {
        $0.text = "Connection failed"
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        addSubview(container)
        container.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.left.right.equalToSuperview().inset(40)
        })
        container.addArrangedSubviews([readerId, icon, label])
        
        icon.addSubview(cover)
        cover.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
}
