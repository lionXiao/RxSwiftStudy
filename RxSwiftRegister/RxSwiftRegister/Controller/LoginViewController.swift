//
//  ViewController.swift
//  RxSwiftRegister
//
//  Created by monkey on 2017/3/26.
//  Copyright © 2017年 Coder. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var usernameValidation: UILabel!
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordValidation: UILabel!
    
    @IBOutlet weak var repoatedPassword: UITextField!
    @IBOutlet weak var repeatedPasswordValidation: UILabel!
    
    @IBOutlet weak var registerIndicator: UIActivityIndicatorView!
    @IBOutlet weak var register: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = LoginViewModel(input:(
            username: username.rx.text.orEmpty.asObservable(),
            password: password.rx.text.orEmpty.asObservable(),
            repeatedPassword: repoatedPassword.rx.text.orEmpty.asObservable(),
            registerTap: register.rx.tap.asObservable()
        ))
        
        register.rx.tap.asObservable()
            .bindTo(viewModel.registerTap)
            .disposed(by: disposeBag)
        
        viewModel.validatedUsername
            .bindTo(usernameValidation.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.validatedPassword
            .bindTo(passwordValidation.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.validatedPasswordRepeated
            .bindTo(repeatedPasswordValidation.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.registerEnabled.subscribe(
            onNext:{
                [unowned self] valid in
                self.register.isEnabled = valid
                self.register.alpha = valid ? 1.0 : 0.5
            }
        ).disposed(by: disposeBag)
        
        viewModel.registering
            .bindTo(registerIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.registered.subscribe(
            onNext:{
                registered in
                print("User register is \(registered)")
            }
        ).disposed(by: disposeBag)
        
        //点击背景收起键盘
        let tapBackground = UITapGestureRecognizer()
        tapBackground.rx.event
            .subscribe(onNext: { [unowned self] _ in
                self.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        view.addGestureRecognizer(tapBackground)
        
        username.rx.controlEvent(.editingDidEnd)
            .subscribe{
                [unowned self] _ in
                self.password.becomeFirstResponder()
            }
            .disposed(by: disposeBag)
        
        password.rx.controlEvent(.editingDidEnd)
            .subscribe{
                [unowned self] _ in
                self.repoatedPassword.becomeFirstResponder()
            }
            .disposed(by: disposeBag)
        
        repoatedPassword.rx.controlEvent(.editingDidEndOnExit)
            .bindTo(viewModel.registerTap)
            .disposed(by: disposeBag)
    }
    
    
}

