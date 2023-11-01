//
//  MedicationListVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 07/09/23.
//

import Foundation
import UIKit


//List Medication Response
struct MedicationListResponse: Codable{
    var id : String?
    var status : String?
    var data : [MedicationData]
    var activeMedications : String?
    var logId : Int?
}

struct MedicationData : Codable {
    var medicationId: Int?
    var name: String?
    var code: String?
    var frequencyCode: String?
    var customFrequency: String?
    var quantity: Int?
    var frequency: String?
    var notes: String?
    var nonProprietaryId: String?
    var effectiveDate: String?
    var lastEffectiveDate: String?
    var invalidFlag: String?
}

//Delete Medication Response
struct MedicationDeleteResponse: Codable{
    var id: Int?
    var status: String?
    var data: DeletionData?
    var activeMedications: Int?
    var logId: Int?
}
struct DeletionData:Codable{
    var timestamp: String?
    var carePlanDate: String?
    var careplanId: Int?
    var activeDiseases: String?
    var list:[DeletionList]?
    var diagnosisId: String?
}
struct DeletionList: Codable{
    var medicationId: Int?
    var name: String?
    var code: String?
    var frequencyCode: String?
    var customFrequency: String?
    var quantity: Int?
    var frequency: String?
    var notes: String?
    var nonProprietaryId: String?
    var effectiveDate: String?
    var lastEffectiveDate: String?
    var invalidFlag: String?
    
}


class MedicationListVC: UIViewController,DataEnterDelegate{
    
    var medication :[MedicationData] = []
    
    // var notificationIdentifier: String?
    
    func didUserEnterInformation() {
        ListMedication()
    }
    
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var addBarButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        ListMedication()
        
        tableView.reloadData()
    }
    
    //    func editMedication(_ editedMedication: MedicationData) {
    //        // Find the index of the edited medication in the array
    //        if let index = medication.firstIndex(where: { $0.medicationId == editedMedication.medicationId }) {
    //            // Update the medication in the array
    //            medication[index] = editedMedication
    //
    //            // Reload the table view
    //            tableView.reloadData()
    //        }
    //    }
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "AddMedicationVC") as! AddMedicationVC
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func ListMedication(){
        let listMedicationApi = APIHelper.share.baseURLWeb + "medications/active/53266/34533"
        let headers = ["X-Auth-Token": Token.token!,"Content-Type": "application/json"]
        APIManager.shared.APIHelper(url: listMedicationApi, params: [:], method: .get, headers: headers, requestBody: nil) { result in
            switch result {
                
            case .success(let data):
                
                do{
                    //                    let meddicationJson = try JSONSerialization.jsonObject(with: data)
                    //                    print("The meddicationjson:\(meddicationJson)")
                    var medicationDecoded = try JSONDecoder().decode(MedicationListResponse.self, from: data)
                    let medicationDataArray = medicationDecoded.data
                    for medicationDatasingle in medicationDataArray{
                        let mdcId = medicationDatasingle.medicationId
                        print("The mdcId:\(mdcId)")
                    }
                    
                    print("The decoded medication edited: \(medicationDecoded)")
                    self.medication = medicationDecoded.data
                    
                    DispatchQueue.main.async {
                        // If you missed it will never display in the list screen.
                        self.tableView.reloadData()
                        
                    }
                    
                }
                catch{
                    print("Error decoding listMedication API response: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("MedicationListAPI request failed: \(error)")
            }
        }
    }
    
    func DeleteApi(at indexpath: IndexPath,medication:MedicationData){
        print("API call started")
        let deleteAPI = APIHelper.share.baseURLWeb + "medications/invalid"
        let headers = ["X-Auth-Token": Token.token!,"Content-Type": "application/json"]
        
        let deleteDict: [String:Any] = ["patientId": Token.patientId!,
                                        "careplanId": Token.careplanId!,
                                        "medicationId": medication.medicationId ?? "",
                                        "lastEffectiveDate": "",
                                        "activeFlag": "Y",
                                        "logId": "null",
                                        "careplanLogMessageUserInput": "An existing medication \(medication.name) has been deleted",
                                        "careplanLogMessage": "An existing medication \(medication.name) has been deleted"]
        do{
            let deleteJson = try JSONSerialization.data(withJSONObject: deleteDict)
            
            APIManager.shared.APIHelper(url: deleteAPI, params: [:], method: .post, headers: headers, requestBody: deleteJson) { result in
                switch result{
                    
                case .success(let data):
                    
                    do{
                        let deleteDecoded = try JSONDecoder().decode(MedicationDeleteResponse.self, from: data)
                        print("The deleteDecoded :\(deleteDecoded)")
                        print("The delete Log Id : \(deleteDecoded.logId)")
                        
                        
                        // to see the medication Id
                        //                        if let deletionData = deleteDecoded.data,let deletionList = deletionData.list{
                        //                            for items in deletionList{
                        //                                if items.invalidFlag == "Yes"{
                        //                                    if let medicationid = items.medicationId{
                        //                                        print("the deleted medicationIdddd :\(medicationid)")
                        //
                        //                                    }
                        //                                }
                        //
                        //                            }
                        //                        }
                        print("the status:\(deleteDecoded.status!)")
                        if deleteDecoded.status == "success"{
                            let currentMedicationId = medication.medicationId
                            print("The medication idddd:\(currentMedicationId!)")
                            self.medication.remove(at: indexpath.row)
                            DispatchQueue.main.async {
                                self.tableView.deleteRows(at: [indexpath], with: .fade)
                            }
                            LocalNotificationManager.removeLocalNotification(identifier: String(currentMedicationId!))
                        }
                    }
                    catch{
                        //let dataString = String(data: data, encoding: .utf8)
                        print("Error in the data:\(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("Error in the delete API:\(error)")
                }
            }
        }
        catch{
            print("Error in serializing the deleteDict:\(error)")
        }
        
    }
    
    func handlerEditAction(at indexPath: IndexPath){
        let itemToEdit = medication[indexPath.row]
        print("The item To edit :\(itemToEdit)")
        
        let editViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AddMedicationVC") as! AddMedicationVC
        editViewController.delegate = self
        editViewController.medicationData = itemToEdit
        navigationController?.pushViewController(editViewController, animated: true)
        
    }
    
}
extension MedicationListVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medication.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! Cell
        let medicationItem = medication[indexPath.row]
        print("The medicationItem:\(medicationItem)")
        if let quantity = medicationItem.quantity{
            let quantityStr = String(quantity)
            cell.quantityLable.text = quantityStr
        }
        else{
            print("Medication quantitiy is nil")
        }
        
        cell.medicationLable.text = medicationItem.name
        //print("The medication name:\(medicationItem.name)")
        cell.frequencyLable.text = medicationItem.frequency
        //let quantity = String(medicationItem.quantity!)
        //cell.quantityLable.text = quantity
        cell.dateDayLable.text = medicationItem.effectiveDate
        cell.lastDayDateLable.text = medicationItem.lastEffectiveDate ?? "-"
        cell.baseView.layer.cornerRadius = 5
        
        cell.baseView.layer.shadowColor = UIColor.black.cgColor
        cell.baseView.layer.shadowOpacity = 0.4
        cell.baseView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        cell.baseView.layer.shadowRadius = 3.0
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "MedicationShowVC") as! MedicationShowVC
        vc.medication1 = medication[indexPath.row]
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, completionHandler in
            self.handlerEditAction(at: indexPath)
            completionHandler(true)
        }
        
        editAction.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [editAction])
    }
    func showToast(controller: UIViewController, message : String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15

        alert.view.frame.origin.y = controller.view.frame.size.height - alert.view.frame.size.height
        controller.present(alert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let itemToDelete = medication[indexPath.row]
            
            print("Item to Delete:\(itemToDelete)")
            print("deleted medication id: \(itemToDelete.medicationId)")
            DeleteApi(at: indexPath, medication: itemToDelete)
            showToast(controller: self, message: "Medication Deleted Successfully", seconds: 3.0)
        }
    }
    
}












