//
//  LottieHUD.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 30.10.2023.
//

import UIKit
import Lottie
import SnapKit

@objcMembers public class LottieHUD: NSObject {

    // MARK: - Static Properties
    public static let shared: LottieHUD = {
        return LottieHUD()
    }()

    // MARK: - Private Properties
    private var animationName     : String = "loading"
    private var graceTimeInterval : TimeInterval = 0.3
    private var animationDuration : TimeInterval = 0.1
    private var timer: Timer?

    // MARK: - UI Elements
    private lazy var containerView: UIView = {
        let view = UIView(frame: .zero)
        view.accessibilityIdentifier    = "LoadingHUD"
        view.backgroundColor            = UIColor.secondarySystemBackground.withAlphaComponent(0.7)
        view.layer.masksToBounds        = true
        return view
    }()

    private lazy var animationView: LottieAnimationView = {
        let view = LottieAnimationView()
        let animation   = LottieAnimation.named(self.animationName, bundle: Bundle.main, subdirectory: nil, animationCache: DefaultAnimationCache.sharedCache)
        view.loopMode   = .loop
        view.animation  = animation
        view.isHidden   = true
        view.backgroundBehavior = .pauseAndRestore
        view.alpha      = 0
        return view
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font          = .systemFont(ofSize: 13)
        label.textColor     = .white
        return label
    }()


    // MARK: - Lifecycle
    override init() {
        super.init()
    }

    // MARK: - Private Functions
    private func createHUD() {
        guard let window = UIApplication.shared.keyWindow else { return }

        window.isUserInteractionEnabled = false
        self.containerView.addSubview(self.animationView)
        self.containerView.addSubview(self.messageLabel)
        window.addSubview(self.containerView)

        animationView.snp.makeConstraints { (make) in
            make.size.equalTo(70)
            make.center.equalToSuperview()
        }

        containerView.snp.makeConstraints { (make) in
            if messageLabel.text != nil {
                containerView.layer.cornerRadius = 0
                make.size.equalToSuperview()
            } else {
                containerView.layer.cornerRadius = 8
                //                make.size.equalTo(90)
                make.size.equalToSuperview()
            }

            make.center.equalToSuperview()
        }

        messageLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalTo(animationView.snp.bottom).offset(5)
        }

        self.animationView.play()
    }

    private func cleanHUD() {
        guard let window = UIApplication.shared.keyWindow else { return }

        messageLabel.text               = nil
        window.isUserInteractionEnabled = true

        self.containerView.removeFromSuperview()
        self.containerView.snp.removeConstraints()

        self.animationView.removeFromSuperview()
        self.animationView.snp.removeConstraints()

        self.messageLabel.removeFromSuperview()
        self.messageLabel.snp.removeConstraints()

        self.animationView.stop()
    }

    private func removeTimer() {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }

    @objc private func start() {
        DispatchQueue.main.async {
            self.createHUD()
            UIView.animate(withDuration: self.animationDuration, delay: 0, options: .curveEaseIn, animations: {
                //                self.containerView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
                self.animationView.alpha = 1
            }, completion: { (finished) in
                self.animationView.isHidden = false
            })
        }
    }


    // MARK: - Public Functions

    public func show() {
        DispatchQueue.main.async {
            self.removeTimer()
            self.timer = Timer.scheduledTimer(timeInterval: self.graceTimeInterval, target: self, selector: #selector(self.start), userInfo: nil, repeats: false)
        }
    }

    public func showWithoutDelay() {
        removeTimer()
        start()
    }

    public func showWithDuration(duration: Double) {
        showWithoutDelay()
        DispatchQueue.main.async {
            self.perform(#selector(self.dismiss), with: nil, afterDelay: duration)
        }
    }

    public func showWithoutDelay(message: String) {
        messageLabel.text = message
        removeTimer()
        start()
    }

    public func dismiss() {
        DispatchQueue.main.async {
            self.removeTimer()
            UIView.animate(withDuration: self.animationDuration, delay: 0, options: .curveEaseOut, animations: {
                //                self.containerView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                self.animationView.alpha = 0
            }, completion: { (completed) in
                self.animationView.isHidden = true
                self.cleanHUD()
            })
        }
    }

}
