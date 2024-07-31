//
//  ViewController.swift
//  RxSwiftSample
//
//  Created by NERO on 7/30/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ViewController: UIViewController {
    //MARK: view
    private let textField = UITextField()
    private let titleAddButton = UIButton()
    private let titlePickerView = UIPickerView()
    private let contentTableView = UITableView()
    private let tableViewToggleSwitch = UISwitch()
    
    //MARK: data
    let disposeBag = DisposeBag() //dispose들을 담아 두는 곳
//    private var titles: Observable<[String]> = .just([])
//    private var titles = [String]()
    private var titles = BehaviorRelay<[String]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureView()
        transform()
    }
    
    private func transform() {
        setupPickerView()
    }
}

extension ViewController {
    private func setupPickerView() {
        titles.bind(to: titlePickerView.rx.itemTitles) { (row, element) in
            return element
        }.disposed(by: disposeBag)
    }
    
    private func bindButtonToAddTitle() {
        titleAddButton.rx.tap
            .withLatestFrom(textField.rx.text.orEmpty)
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] newTitle in
                guard let self = self else { return }
                var currentTitles = self.titles.value
                currentTitles.append(newTitle)
                self.titles.accept(currentTitles)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindToggleSwitchToTableView() {
        tableViewToggleSwitch.rx.isOn
            .bind(to: contentTableView.rx.isHidden)
            .disposed(by: disposeBag)
    }
}

extension ViewController {
    private func configureLayout() {
        [textField, titleAddButton, titlePickerView, contentTableView, tableViewToggleSwitch].forEach { view.addSubview($0) }
        
        textField.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(50)
            $0.height.equalTo(30)
        }
        titleAddButton.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(10)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.size.equalTo(50)
        }
        titlePickerView.snp.makeConstraints {
            $0.top.equalTo(titleAddButton.snp.bottom).offset(10)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        tableViewToggleSwitch.snp.makeConstraints {
//            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(50)
            $0.centerY.equalTo(titlePickerView)
            $0.trailing.equalTo(titlePickerView)
//            $0.height.equalTo(50)
        }
        contentTableView.snp.makeConstraints {
            $0.top.equalTo(titlePickerView.snp.bottom).offset(10)
            $0.height.equalTo(50)
        }
    }
    
    private func configureView() {
        view.backgroundColor = .white
        titleAddButton.setImage(.add, for: .normal)
        titleAddButton.contentMode = .scaleAspectFill
        
        textField.backgroundColor = .systemGray6
//        titleAddButton.backgroundColor = .cyan
//        titlePickerView.backgroundColor = .systemYellow
        contentTableView.backgroundColor = .green
//        tableViewToggleSwitch.backgroundColor = .blue
    }
}

extension ViewController {
    private func 기록용() {
        titleAddButton.rx.tap //Observable: "버튼이 클릭됐어!"
            .subscribe { _ in //Observer: "이렇게 처리할게!"
//                self.label.text = "버튼을 클릭했어요"
                print("Next")
            } onError: { error in
                print("Error")
            } onCompleted: {
                print("Completed")
            } onDisposed: {
                print("Disposed")
            }
            .disposed(by: disposeBag)
        
        titleAddButton.rx.tap
            .subscribe { [weak self] _ in
//                self?.label.text = "버튼을 클릭했어요"
                print("Next")
            } onDisposed: {
                print("Disposed")
            }
            .disposed(by: disposeBag)
        
        
        //다 클로저라 자꾸 [weak self] 필요한 것 같은데 키워드를 제공해 줄까?
        titleAddButton.rx.tap
            .withUnretained(self)
            .subscribe { _ in
//                self.label.text = "버튼을 클릭했어요"
                print("Next")
            } onDisposed: {
                print("Disposed")
            }
            .disposed(by: disposeBag)
        
        
        //키워드 쓴다 해도 어차피 맨날 한 줄 추가해야 되는데 with 매개변수 만들어 줄까?
        titleAddButton.rx.tap
            .subscribe(with: self) { owner, _ in
//                owner.label.text = "버튼을 클릭했어요"
            } onDisposed: { owner in
                print("Disposed")
            }
            .disposed(by: disposeBag)
        
        
        //subscribe는 백그라운드 스레드에서도 동작됨 -> UI 관련 동작을 실행할 때 보라색 오류가 뜰 수 있음
        //=> main 스레드에 담아서 처리해 주기!
        titleAddButton.rx.tap
            .subscribe(with: self) { owner, _ in
                DispatchQueue.main.async {
//                    owner.label.text = "버튼을 클릭했어요"
                }
            } onDisposed: { owner in
                print("Disposed")
            }
            .disposed(by: disposeBag)
        
        
        //귀찮아 보이는데 애초에 Main 스레드에 담는 것도 만들어 줄까?
        titleAddButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, _ in
//                owner.label.text = "버튼을 클릭했어요"
            } onDisposed: { owner in
                print("Disposed")
            }
            .disposed(by: disposeBag)
        
        
        //.observe(on: MainScheduler.instance)까지 항상 같이 써 줘야 되면 귀찮을 것 같은데??
        //UI 이벤트는 Error, Completion 구문은 필요도 없는데, 애초에 onNext까지만 있는 걸 만들어 줄까?
        //=> UI용으로 bind라는 애를 만들어서 Main 스레드 동작을 보장해 줄게~!
        titleAddButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
//                owner.label.text = "버튼을 클릭했어요"
            })
            .disposed(by: disposeBag)
        
        titleAddButton.rx.tap //observable<Stirng> 타입
//            .map { "버튼을 클릭했어요" }.bind(to: label.rx.text)
//            .disposed(by: disposeBag)
    }
}


//MARK: - Operator
extension ViewController {
    func testJust() {
        //Observable이 just 방식으로 이벤트 방출 (어떤 방식으로 일을 벌릴지)
        Observable.just([1,2,3]) //유한 시퀀스
            .subscribe { value in //구독
                print("next: \(value)")
            } onError: { error in
                print()
            } onCompleted: {
                print()
            } onDisposed: { //이벤트는 아님
                print()
            }.disposed(by: disposeBag) //구독 끊음
    }
    
    func testFrom() {
        //Observable이 from 방식으로 이벤트 방출 (어떤 방식으로 일을 벌릴지)
        Observable.from([1,2,3]) //유한 시퀀스
            .subscribe { value in //구독
                print("next: \(value)")
            } onError: { error in
                print()
            } onCompleted: {
                print()
            } onDisposed: { //이벤트는 아님
                print()
            }.disposed(by: disposeBag) //구독 끊음
    }
    
    func testInterval() {
        //Observable이 from 방식으로 이벤트 방출 (어떤 방식으로 일을 벌릴지)
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        //Int로 1초마다 일을 벌릴게
            .subscribe { value in
                print("next: \(value)") //계~~~~~~~~~~~~~속 여기만 실행됨
            } onError: { Error in
                print("Disposed")
            } onCompleted: {
                print("Completed")
            } onDisposed: {
                print("Disposed")
            }.disposed(by: disposeBag) //구독 끊음
    }
}




//텍스트필드에 입력한 텍스트
//버튼 누르면
//피커뷰 타이틀에 추가
//스위치 토글하면 테이블뷰 isHidden 토글




import SwiftUI

struct ViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = ViewController
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        return UIViewControllerType()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

@available(iOS 13.0.0, *)
struct ViewPreview: PreviewProvider {
    static var previews: some View {
        ViewControllerRepresentable()
    }
}
