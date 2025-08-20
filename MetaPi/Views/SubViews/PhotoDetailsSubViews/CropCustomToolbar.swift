//
//  CropCustomToolbar.swift
//  MetaPi
//
//  Created by Veronika Nizhankivska on 2025-07-09.
//

import UIKit
import Mantis

public final class CropCustomToolbar: UIView, CropToolbarProtocol {
    public var config = CropToolbarConfig()
    public var iconProvider: CropToolbarIconProvider?
    public weak var delegate: CropToolbarDelegate?
    
    private var ratioButtons: [UIButton] = []
    private var selectedRatioButton: UIButton?
    private var freeFormButton: UIButton?
    
    public func createToolbarUI(config: CropToolbarConfig) {
        self.config = config
        
        backgroundColor = UIColor(named: "backgroundDarkGrey")

        let flipH = makeIconWithLabel(
            assetName: "flip_h_icon",
            title: "Horizontal",
            action: {
                self.delegate?.didSelectHorizontallyFlip(self)
            }
        )
        let flipV = makeIconWithLabel(
            assetName: "flip_v_icon",
            title: "Vertical",
            action: {
                self.delegate?.didSelectVerticallyFlip(self)
            }
        )
        let rotate = makeIconWithLabel(
            assetName: "rotate_icon",
            title: "Rotate",
            action: {
                self.delegate?.didSelectClockwiseRotate(self)
            }
        )
        let reset = makeIconWithLabel(
            assetName: "reset_icon",
            title: "Reset",
            action: {
                self.delegate?.didSelectReset(self)
            }
        )
        
        let ratio169 = makeRatioButton(title: "16:9", ratio: 16.0 / 9.0)
        let ratio43 = makeRatioButton(title: "4:3", ratio: 4.0 / 3.0)
        let ratio32 = makeRatioButton(title: "3:2", ratio: 3.0 / 2.0)
        let ratio21 = makeRatioButton(title: "2:1", ratio: 2.0 / 1.0)
        let ratio11 = makeRatioButton(title: "1:1", ratio: 1.0)
        let ratio34 = makeRatioButton(title: "3:4", ratio: 3.0 / 4.0)
        let ratio23 = makeRatioButton(title: "2:3", ratio: 2.0 / 3.0)
        let ratio916 = makeRatioButton(title: "9:16", ratio: 9.0 / 16.0)
        let ratioCustom = makeRatioButton(title: "Freeform", ratio: nil)
        
        let toolsRow = UIStackView(arrangedSubviews: [rotate, flipH, flipV, reset])
        toolsRow.axis = .horizontal
        toolsRow.backgroundColor = UIColor(named: "backgroundDarkerGrey")
        toolsRow.spacing = 32
        toolsRow.alignment = .center
        toolsRow.distribution = .equalCentering
        toolsRow.layoutMargins = UIEdgeInsets(top: 12, left: 32, bottom: 12, right: 32)
        toolsRow.isLayoutMarginsRelativeArrangement = true
        toolsRow.layer.cornerRadius = 16
        toolsRow.clipsToBounds = true
        
        let ratioRow = UIStackView(arrangedSubviews: [
            ratioCustom, ratio169, ratio11, ratio34,
            ratio23, ratio32, ratio21, ratio43, ratio916
        ])
        ratioRow.axis = .horizontal
        ratioRow.spacing = 16
        ratioRow.alignment = .center
        ratioRow.layoutMargins = UIEdgeInsets(top: 6, left: 24, bottom: 6, right: 24)
        ratioRow.isLayoutMarginsRelativeArrangement = true
        ratioRow.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(ratioRow)
        
        NSLayoutConstraint.activate([
            ratioRow.topAnchor.constraint(equalTo: scrollView.topAnchor),
            ratioRow.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            ratioRow.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            ratioRow.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            ratioRow.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        scrollView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let mainStack = UIStackView(arrangedSubviews: [toolsRow, scrollView])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.alignment = .fill
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -72)
        ])
        
        if let freeFormButton = freeFormButton {
            highlightSelected(freeFormButton)
        }
    }
    
    private func makeIconWithLabel(assetName: String, title: String, action: @escaping () -> Void) -> UIView {
        let iconView = UIImageView(image: UIImage(named: assetName))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = UIFont(name: "Inter", size: 13) ?? UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.isUserInteractionEnabled = true
        
        let tapButton = UIButton(type: .system)
        tapButton.backgroundColor = .clear
        tapButton.addAction(UIAction { _ in action() }, for: .touchUpInside)
        
        stack.addSubview(tapButton)
        tapButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tapButton.topAnchor.constraint(equalTo: stack.topAnchor),
            tapButton.bottomAnchor.constraint(equalTo: stack.bottomAnchor),
            tapButton.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            tapButton.trailingAnchor.constraint(equalTo: stack.trailingAnchor)
        ])
        
        return stack
    }
    
    private func makeRatioButton(title: String, ratio: Double?) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = .white
        config.titleAlignment = .center
        config.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8)
        
        var container = AttributeContainer()
        container.font = UIFont(name: "Inter", size: 16) ?? UIFont.systemFont(ofSize: 16)
        config.attributedTitle = AttributedString(title, attributes: container)
        
        let button = UIButton(configuration: config)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        button.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.highlightSelected(button)
            if let ratio = ratio {
                self.delegate?.didSelectRatio(self, ratio: ratio)
            } else {
                self.delegate?.didSelectSetRatio(self)
            }
        }, for: .touchUpInside)
        
        ratioButtons.append(button)
        
        if ratio == nil {
            freeFormButton = button
        }
        
        return button
    }
    
    
    private func highlightSelected(_ selected: UIButton) {
        if selected == selectedRatioButton {
            selected.backgroundColor = .clear
            selectedRatioButton = nil
        } else {
            for btn in ratioButtons {
                btn.backgroundColor = .clear
            }
            selected.backgroundColor = UIColor(named: "buttonPrimaryBg")
            selectedRatioButton = selected
        }
    }
    
    public func handleFixedRatioSetted(ratio: Double) {}
    
    public func handleFixedRatioUnSetted() {
        for btn in ratioButtons {
            btn.backgroundColor = .clear
        }
        if selectedRatioButton == freeFormButton {
            freeFormButton?.backgroundColor = UIColor(named: "buttonPrimaryBg")
        }
    }
    
    public func getRatioListPresentSourceView() -> UIView? { nil }
    public func adjustLayoutWhenOrientationChange() {}
    public func handleCropViewDidBecomeResettable() {}
    public func handleCropViewDidBecomeUnResettable() {}
    public func handleImageAutoAdjustable() {}
    public func handleImageNotAutoAdjustable() {}
}
