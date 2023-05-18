//
//  String+Extension.swift
//  NearMee
//
//  Created by admin on 18/05/2023.
//

import Foundation

extension String {
    
    var formatPhoneCall: String {
        self.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "-", with: "")
    }
}
