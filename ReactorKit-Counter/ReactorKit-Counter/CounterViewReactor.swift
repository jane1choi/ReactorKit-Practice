//
//  CounterViewReactor.swift
//  ReactorKit-Counter
//
//  Created by EUNJU on 2022/08/03.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit

// ViewModel의 역할을 하는 Reactor
// VC에서 Action을 보내면 Reactor의 내부에서 mutate와 reduce의 과정을 거쳐서 State를 방출해서 VC로 다시 보냄
// VC가 리액터의 state를 구독하는 형태
class CounterViewReactor: Reactor {
    let initialState = State()
    
    enum Action {
        case plus
        case minus
    }
    
    enum Mutation {
        case plusValue
        case minusValue
        case setLoading(Bool)
    }
    
    struct State {
        var value = 0
        var isLoading = false
    }
    
    // mutate()는 Action 스트림을 Mutation 단위로 방출해주는 역할을 하는 Reactor의 내부 함수
    // 옵저버블: 관찰가능한 데이터의 흐름. Mutation타입의 element가 담긴 옵저버블이 리턴타입인 것
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .plus:
            return Observable.concat([ // concat은 두개 이상의 옵저버블 직렬로 연결하는 operator
                Observable.just(.setLoading(true)),
                Observable.just(.plusValue).delay(.seconds(1), scheduler: MainScheduler.instance),
                Observable.just(.setLoading(false))
            ])
        case .minus:
            return Observable.concat([
                Observable.just(.setLoading(true)),
                Observable.just(.minusValue).delay(.seconds(1), scheduler: MainScheduler.instance),
                Observable.just(.setLoading(false))
            ])
        }
    }
    
    // reduce()는 방출된 Mutation 옵저버블 스트림을 받아서 상태값(State)을 뷰로 방출하는 Reactor의 내부 함수
    // 이전 상태 값과 처리 단위를 받아 결과를 반환함
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .plusValue:
            newState.value += 1
        case .minusValue:
            newState.value -= 1
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        }
        return newState
    }
}
