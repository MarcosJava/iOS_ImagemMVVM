//
//  PhotoSearchMetadataViewModel.swift
//  BindingWithBond
//
//  Created by Marcos Felipe Souza on 21/09/16.
//  Copyright © 2016 Razeware. All rights reserved.
//

import Foundation
import Bond

class PhotoSearchMetadataViewModel {

    let creativeCommons = Observable<Bool>(false)
    let dateFilter = Observable<Bool>(false)
    let minUploadDate = Observable<NSDate>(NSDate())
    let maxUploadDate = Observable<NSDate>(NSDate())
    

    init() {
        
        //Poem o valor da data maior no valor da menor
        maxUploadDate.observe {
            [unowned self]
            maxDate in
            if maxDate.timeIntervalSinceDate(self.minUploadDate.value) < 0 {
                self.minUploadDate.value = maxDate
            }
        }
        
        //Poem o valor da data menor no valor da maior
        minUploadDate.observe {
            [unowned self]
            minDate in
            if minDate.timeIntervalSinceDate(self.maxUploadDate.value) > 0 {
                self.maxUploadDate.value = minDate
            }
        }
    }
    
}
