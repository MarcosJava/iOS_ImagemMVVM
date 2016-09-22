/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class ViewController: UIViewController {
  
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var resultsTable: UITableView!
    
    private let viewModel = PhotoSearchViewModel()


    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        
        //Colocar o texto vermelho
        viewModel.validSearchText
            .map { $0 ? UIColor.blackColor() : UIColor.redColor() }
            .bindTo(searchTextField.bnd_textColor)
        
        //Adicionar o process (loading) apenas no loading da imagem
        viewModel.searchInProgress
            .map { !$0 }
            .bindTo(activityIndicator.bnd_hidden)
        
        //Adiciona um Fade quando o loading nao termina
        viewModel.searchInProgress
            .map { $0 ? CGFloat(0.5) : CGFloat(1.0) }
            .bindTo(resultsTable.bnd_alpha)
        
        
        //Realiza insercoes na tabela.
        viewModel.searchResults.lift().bindTo(resultsTable) { indexPath, dataSource, tableView in
            
            let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as! PhotoTableViewCell
            
            let photo = dataSource[indexPath.section][indexPath.row]
            
            cell.title.text = photo.title
            
            cell.photo.image = nil
            
            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            
            
            
            dispatch_async(backgroundQueue) {
                
                if let imageData = NSData(contentsOfURL: photo.url) {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.photo.image = UIImage(data: imageData)
                    }
                }
            }
            
            return cell
        }
        
        //Adiciona um erro
        viewModel.errorMessages.observe {
            [unowned self] error in
            
            let alertController = UIAlertController(title: "Something went wrong :-(",
                message: error, preferredStyle: .Alert)
            self.presentViewController(alertController, animated: true, completion: nil)
            let actionOk = UIAlertAction(title: "OK", style: .Default,
                handler: { action in alertController.dismissViewControllerAnimated(true, completion: nil) })
            
            alertController.addAction(actionOk)
        }
        

    }
    
    
    
    
    
    
    
    func bindViewModel() {
        //viewModel.searchString.bindTo(searchTextField.bnd_text)
        viewModel.searchString.bidirectionalBindTo(searchTextField.bnd_text)

    }
    
    func etapa4() -> Void{
        
        searchTextField.bnd_text
            .map { $0?.characters.count > 0 }
            .bindTo(self.activityIndicator.bnd_animating)

    }
    
    func etapa3() -> Void{
        searchTextField.bnd_text
            .map { $0?.uppercaseString }
            .observe {
                text in
                print(text)
                
        }
    }
    
    func etapa2() -> Void{
        let uppercase = searchTextField.bnd_text
            .map { $0?.uppercaseString }
        
        uppercase.observe {
            text in
            print(text)
        }
    }
    
    func etapa1(){
        searchTextField.bnd_text.observe {
            text in
            print(text)
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowSettings" {
            let navVC = segue.destinationViewController as! UINavigationController
            let settingsVC = navVC.topViewController as! SettingsViewController
            settingsVC.viewModel = viewModel.searchMetadataViewModel
        }
    }

}

