//
//  CounterVC.swift
//  ReactorKit-Counter
//
//  Created by EUNJU on 2022/08/03.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

class CounterVC: UIViewController {
    
    // MARK: Properties
    var disposeBag = DisposeBag()
    
    private let countLabel = UILabel().then {
        $0.text = "0"
        $0.textAlignment = .center
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 20)
    }
    private let plusBtn = UIButton().then {
        $0.setTitle("+", for: .normal)
        $0.setTitleColor(.systemBlue, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 26)
    }
    
    private let minusBtn = UIButton().then {
        $0.setTitle("-", for: .normal)
        $0.setTitleColor(.systemBlue, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 26)
    }
    
    private let loadingView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
}

// MARK: - UI
extension CounterVC {
    private func configureUI() {
        
        [countLabel, plusBtn, minusBtn, loadingView].forEach { view.addSubview($0) }
        
        countLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        plusBtn.snp.makeConstraints {
            $0.centerY.equalTo(countLabel)
            $0.leading.equalTo(countLabel.snp.trailing).offset(10)
        }
        
        minusBtn.snp.makeConstraints {
            $0.centerY.equalTo(countLabel)
            $0.trailing.equalTo(countLabel.snp.leading).offset(-10)
        }
        
        loadingView.snp.makeConstraints {
            $0.top.equalTo(countLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
    }
}

// MARK: - bind
// 스보를 사용한다면 StoryboardView를 채택
// 둘의 차이는 StoryboardView를 채택했을 경우에는 뷰가 로드가 된 후 바인딩을 해준다는 것!
extension CounterVC: View {
    
    // 리액터가 주입되면 bind() 바로 실행
    func bind(reactor: CounterViewReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    private func bindAction(_ reactor: CounterViewReactor) {
        
        // 플러스 버튼
        plusBtn.rx.tap
            .map { Reactor.Action.plus }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 마이너스 버튼
        minusBtn.rx.tap
            .map { Reactor.Action.minus }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    // Reactor의 state와 연결
    // reactor의 state를 bind해서 state가 변할때마다 바뀔 UI를 지정해주고 UI에서 변하게될 부분들을 여기서 지정해줌
    private func bindState(_ reactor: CounterViewReactor) {
        reactor.state.map { $0.value }
            .distinctUntilChanged()
            .map { "\($0)" }
            .bind(to: countLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingView.rx.isAnimating)
            .disposed(by: disposeBag)
    }
}
