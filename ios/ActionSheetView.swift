//
//  MenuView.swift
//  react-native-menu
//
//  Created by Jesse Katsumata on 11/3/20.
//

import UIKit


@objc(ActionSheetView)
class ActionSheetView: UIView {
    @objc var onPressAction: RCTDirectEventBlock?
    private var _title: String?;
    @objc var title: NSString? {
        didSet { self._title = title as? String }
    }
    
    private var _actions: [UIAlertAction] = [];
    @objc var actions: [NSDictionary]? {
        didSet {
            guard let actions = self.actions else {
                return
            }
            _actions.removeAll()
            actions.forEach({ alertAction in
                if let action = RCTAlertAction(details: alertAction).createAction({
                event in self.sendButtonAction(event)
            }) {
                  _actions.append(action)
                }
            })
        }
    }

    @objc var shouldOpenOnLongPress: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let tap = UITapGestureRecognizer(target: self, action: #selector (self.handleTap (_:)))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        self.addGestureRecognizer(tap)
        self.addGestureRecognizer(longPress)
    }
    
    func launchActionSheet() {

        let alert = UIAlertController(title: _title, message: nil, preferredStyle: .actionSheet)
        
        self._actions.forEach({action in
            alert.addAction(action.copy() as! UIAlertAction)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert.modalPresentationStyle = .popover
            alert.popoverPresentationController?.sourceView = self
            alert.popoverPresentationController?.sourceRect = self.bounds
        }
        
        if let root = RCTPresentedViewController() {
            root.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    @objc func handleTap(_ sender:UITapGestureRecognizer) {
        if shouldOpenOnLongPress {
            return
        }
        if sender.state == .ended {
            DispatchQueue.main.async {
                self.launchActionSheet()
            }
        }
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if !shouldOpenOnLongPress {
            return
        }
        if sender.state == .ended {
            DispatchQueue.main.async {
                self.launchActionSheet()
            }
        }
    }
    
    @objc func sendButtonAction(_ action: String) {
        if let onPress = onPressAction {
            onPress(["event":action])
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reactSetFrame(_ frame: CGRect) {
      super.reactSetFrame(frame);
    };
    
}
