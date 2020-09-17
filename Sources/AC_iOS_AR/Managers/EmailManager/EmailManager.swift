//
//  Email.swift
//  YaPlace
//
//  Created by Mac on 27.05.2020.
//  Copyright © 2020 SKZ. All rights reserved.
//

import MessageUI

class EmailManager: NSObject { //manager?
    
    enum state {
        case success
        case error(String)
    }
    
    static let sharedInstance = EmailManager()
    
    private var viewController: UIViewController?
    
    func set(controller: UIViewController?) {
        self.viewController = controller
    }
    
    func sendEmail(completion: ((EmailManager.state) -> Void)? = nil) {
        var result: EmailManager.state = .success
        if MFMailComposeViewController.canSendMail() {
            let currentVersion = Bundle.main.versionNumber
            let currentBuild = Bundle.main.buildNumber
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@vergendo.com"])
            mail.setSubject("Support: Tourist \(currentVersion)(\(currentBuild))")
            mail.setMessageBody("<p>Put your message here</p>", isHTML: true)

            viewController?.present(mail, animated: true)
        } else {
            result = .error("Can't send email")
        }
        completion?(result)
    }
}

extension EmailManager: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
