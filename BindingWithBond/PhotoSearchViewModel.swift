//
//  PhotoSearchViewModel.swift
//  BindingWithBond
//
//  Created by Marcos Felipe Souza on 21/09/16.
//  Copyright © 2016 Razeware. All rights reserved.
//

import Foundation
import Bond

class PhotoSearchViewModel {
    
    let searchString = Observable<String?>("")
    let validSearchText = Observable<Bool>(false)
    let searchResults = ObservableArray<Photo>()
    let searchInProgress = Observable<Bool>(false)
    let errorMessages = EventProducer<String>()
    
    let searchMetadataViewModel = PhotoSearchMetadataViewModel()




    
    init() {
        //Coloca o valor Bond
       // searchString.value = "Bond"
        
        
        //Adiciona um map com condicoes maior que 3 para pintar
        searchString
            .map { $0!.characters.count > 3 }
            .bindTo(validSearchText)
        
        
        //Pega e imprime o valor no bidirectional
        searchString.observeNew {
            text in 
            print(text)
        }
        
        
        //Quando tiver mais de 3 caracteres executa a busca por imagem
        searchString
            .filter { $0!.characters.count > 3 }
            .throttle(0.5, queue: Queue.Main)
            .observe {
                [unowned self] text in
                self.executeSearch(text!)
            }
        
        //Reatribui os valores colocado no setting
        combineLatest(searchMetadataViewModel.dateFilter, searchMetadataViewModel.maxUploadDate,
            searchMetadataViewModel.minUploadDate, searchMetadataViewModel.creativeCommons)
            .throttle(0.5, queue: Queue.Main)
            .observe {
                [unowned self] _ in
                self.executeSearch(self.searchString.value!)
        }
    }
    
    //Initia o PhotoSearch
    private let searchService: PhotoSearch = {
        let apiKey = NSBundle.mainBundle().objectForInfoDictionaryKey("apiKey") as! String
        return PhotoSearch(key: apiKey)
    }()
    
    func executeSearch(text: String) {
        print("Texto buscado : " + text)
        
        var query = PhotoQuery()
        
        query.text = searchString.value ?? ""
        query.creativeCommonsLicence = searchMetadataViewModel.creativeCommons.value
        query.dateFilter = searchMetadataViewModel.dateFilter.value
        query.minDate = searchMetadataViewModel.minUploadDate.value
        query.maxDate = searchMetadataViewModel.maxUploadDate.value
        
        searchInProgress.value = true
        
        searchService.findPhotos(query) {
            
            [unowned self] result in
            
            self.searchInProgress.value = false
            
            switch result
            {
            
            case .Success(let photos):
                self.searchResults.removeAll()
                self.searchResults.insertContentsOf(photos, atIndex: 0)
                
            case .Error:
                self.errorMessages
                    .next("There was an API request issue of some sort. Go ahead, hit me with that 1-star review!")

            }
        }
        
        
    }
}
