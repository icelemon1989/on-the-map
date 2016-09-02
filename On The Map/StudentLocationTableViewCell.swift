//
//  StudentLocationTableViewCell.swift
//  On The Map
//
//  Created by Yang Ji on 8/23/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import UIKit

class StudentLocationTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    
    @IBOutlet weak var studentImage: UIImageView!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var studentURLLabel: UILabel!
    
    func configureWithStudentLocation(studentLocation: StudentLocation) {
        studentImage.image = UIImage(named: "pin")
        studentNameLabel.text = studentLocation.student.FullName
        studentURLLabel.text = studentLocation.student.mediaURL
    }
}
