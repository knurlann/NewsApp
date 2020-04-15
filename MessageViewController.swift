//
//  MessageViewController.swift
//  bazarApp
//
//  Created by Нурлан on 17.10.2018.
//  Copyright © 2018 Нурлан. All rights reserved.
//

import UIKit
import EasyPeasy
import SwiftyJSON
import FirebaseAuth
import Firebase



class MessageViewController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout{
    var userMe = ""

    lazy var seperatorLine :UIView = {
        let line  = UIView()
        line.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    lazy var messageView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var senButton : UIButton = {
        let buton = UIButton(type: .system)
        buton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        buton.setTitle("Send", for: .normal)
        buton.translatesAutoresizingMaskIntoConstraints = false
        buton.isEnabled = true
        return buton
    }()
    lazy var inputTextField : UITextField = {
        let input = UITextField()
        input.backgroundColor = .white
        input.placeholder = "Enter message ..."
        input.translatesAutoresizingMaskIntoConstraints = false
        input.delegate = self
        return input
    }()

//    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, withHeader header: [String : String]?, withDestination destination: String) {
//        var json = JSON(jsonBody!)
//        let jsonText = json["text"].stringValue
//        let jsonSource = json["source"].stringValue
//        let myMessages = Message()
//        myMessages.fromId = jsonSource
//        myMessages.text = jsonText
//        myMessages.timestamp = 1
//        myMessages.toId = myarray[0]
////        Goods.Messages.append(myMessages)
//        Goods.Messages.insert(myMessages, at: 0)
////        DispatchQueue.main.async(execute: {
////            self.scrollToBottom()
////        })
//        collectionView?.reloadData()
//    }


//    func scrollToBottom() {
//            if Goods.Messages.count>3{
//            let section = (collectionView?.numberOfSections)! - 1
//            let lastItemIndex = IndexPath(item: Goods.Messages.count - 1, section: section)
//            self.collectionView?.scrollToItem(at: lastItemIndex, at: .bottom, animated: true)
//            }
//    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Goods.Messages.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80

        //get estimated height somehow????
        if let text = Goods.Messages[indexPath.item].text {
            height = estimateFrameForText(text).height + 20
        }

        return CGSize(width: view.frame.width, height: height)
    }
    private func estimatedFrameForText(text: String)-> CGRect{
        let size = CGSize(width: 200, height: 100)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: 16)]), context: nil)
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ChatMessageCell
        let message = Goods.Messages[indexPath.row]
        cell.textView.text = message.text
        if message.fromId == userMe {
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false

        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false

            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(message.text!).width + 32
        return cell
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Goods.Messages.removeAll()
    }

    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: 16)]), context: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem()
        
        
        backButton.title = "Назад"
//        UINavigationBar.topItem.title = "\(numberClient.firstname)"
        if let user = Auth.auth().currentUser{
            userMe = "\(user)"
            self.title = "\(user)"
        }else{
            self.title = "NoName"
            userMe = "NoName"
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.backgroundColor = UIColor.white

        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: "cellId")
        self.tabBarController?.tabBar.isHidden = true
        senButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)

        setupView()
        setupConstraints()
        collectionView!.transform = CGAffineTransform.init(rotationAngle: (-(CGFloat)(Double.pi)))

        // Do any additional setup after loading the view.

//        DispatchQueue.main.async(execute: {
//            self.scrollToBottom()
//        })
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    @objc func handleSend(){
        //        messages.append(inputTextField.text!)

        if !(inputTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {


            let myMessages = Message()
            myMessages.set(fromId: userMe, text: inputTextField.text!, timestamp: 1, toId: "me")
//            Goods.Messages.append(myMessages)
            Goods.Messages.insert(myMessages, at: 0)
//            DispatchQueue.main.async(execute: {
//                self.scrollToBottom()
//            })
            collectionView?.reloadData()
            inputTextField.text = nil
        }

    }
    func setupView(){
        [messageView].forEach{
            view.addSubview($0)
        }
        [inputTextField, seperatorLine,senButton].forEach{
            messageView.addSubview($0)
        }
    }


    func setupConstraints(){
        messageView.easy.layout(
            Left(0),
            Width().like(view),
            Bottom(0),
            Height(50)
        )
        senButton.easy.layout(
            Right(0).to(messageView),
            Top().to(messageView),
            Bottom().to(messageView),
            Width(80)
        )
        inputTextField.easy.layout(
            Left(5).to(messageView, .left),
            CenterY().to(messageView, .centerY),
            Right().to(senButton),
            Height().like(messageView)
        )

        seperatorLine.easy.layout(
            Left(),
            Top(),
            Width().like(messageView),
            Height(1)
        )
    }
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}
