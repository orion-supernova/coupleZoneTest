//
//  Chat2ViewController.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 17.11.2023.
//  
//

import SnapKit
import NBUIKit
import UIKit.UIViewController

protocol Chat2DisplayLogic: AnyObject {
    
}

final class Chat2ViewController: UIViewController {
    
    private let interactor: Chat2BusinessLogic
    
    override func loadView() {
        super.loadView()
        setup()
        layout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    init(interactor: Chat2BusinessLogic) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor private func setup() {
        
    }
    
    @MainActor private func layout() {
        
    }
    
    func configure() {
        
    }
}
//MARK: - Chat2DisplayLogic
extension Chat2ViewController: Chat2DisplayLogic {
   
}
