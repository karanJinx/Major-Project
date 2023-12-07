//
//  MedicationListVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 07/09/23.
//

import Foundation
import UIKit


//List Medication Response
struct MedicationListResponse: Codable {
    var id : String?
    var status : String?
    var data : [MedicationData]
    var activeMedications : String?
    var logId : Int?
}
struct MedicationData: Codable {
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
struct MedicationDeleteResponse: Codable {
    var id: Int?
    var status: String?
    var data: DeletionData?
    var activeMedications: Int?
    var logId: Int?
}
struct DeletionData: Codable {
    var timestamp: String?
    var carePlanDate: String?
    var careplanId: Int?
    var activeDiseases: String?
    var list:[DeletionList]?
    var diagnosisId: String?
}
struct DeletionList: Codable {
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

class MedicationListVC: UIViewController, DataEnterDelegate {
    
    //MARK: - Properties
    var medicationDetailList = [MedicationData]()
    var medicationDetailWhenDeleting = [MedicationData]()
    func didUserEnterInformation() {
        listMedicationServiceCall()
    }
    //MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var addBarButton: UIBarButtonItem!
    @IBOutlet var hideView: UIView!
    @IBOutlet var messageLable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
    
    //MARK: - InitialSetUp
    func initialSetUp() {
        //getting authorization from the user
        LocalNotificationManager.requestPermission()
        setUpNavigationBar()
        tableViewDelegate()
        listMedicationServiceCall()
    }
    
    //MARK: - SetUpNavigationBar
    func setUpNavigationBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .systemGray6
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        // Set the status bar color to match the navigation bar
        navigationController?.navigationBar.barStyle = .black
    }
    
    //MARK: - TableView
    func tableViewDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    //MARK: - IBAction
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let medicationData = MedicationData()
        print("the data when Adding",medicationData)
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AddMedicationVC") as! AddMedicationVC
//        vc.navigationItem.title = "Add Medication"
//        vc.dataEnterDelegate = self
//        vc.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(vc, animated: true)
        navigateToAddOrEditScreen(withTitle: "Add Medication", itemtoEdit: medicationData)
    }
    
    //MARK: - ListMedicationServiceCall
    func listMedicationServiceCall() {
        let listMedicationUrl = Details.apiHelper.baseURLWeb + "medications/active/53266/34533"
        let headers = ["X-Auth-Token": Details.token!,"Content-Type": "application/json"]
        Details.apiManager.APIHelper(url: listMedicationUrl, params: [:], method: .get, headers: headers, requestBody: nil) { result in
            switch result {
            case .success(let data):
                print("Working")
                self.medicationValidationSuccessHandling(data: data)
                
            case .failure(let error):
                print("MedicationListAPI request failed: \(error)")
            }
        }
    }
    
    func medicationValidationSuccessHandling(data: Data) {
        do{
            //                    let meddicationJson = try JSONSerialization.jsonObject(with: data)
            //                    print("The meddicationjson:\(meddicationJson)")
            let medicationDecoded = try JSONDecoder().decode(MedicationListResponse.self, from: data)
            print("the medicationDecoded:\(medicationDecoded)")
            medicationDetailWhenDeleting = medicationDecoded.data
            print("THe medicationDetail: \(medicationDetailWhenDeleting)")
            //                    let medicationDataArray = medicationDecoded.data
            //                    for medicationDatasingle in medicationDataArray{
            //                        let mdcId = medicationDatasingle.medicationId
            //                        print("The mdcId:\(mdcId)")
            //                    }
            //                    print("The decoded medication edited: \(medicationDecoded)")
            self.medicationDetailList = medicationDecoded.data
            print("the medicaiton:\(self.medicationDetailList)")
            DispatchQueue.main.async {
                // If you missed it will never display in the list screen.
                self.tableView.reloadData()
            }
        }
        catch{
            print("Error decoding listMedication API response: \(error.localizedDescription)")
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Alert", message: "Try after sometimes", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                self.messageLable.text = "Response Error, Try after sometimes"
            }
        }
    }
    
    //MARK: DeleteMedicationServiceCall
    func deleteMedicationServiceCall(using indexpath: IndexPath, medicationToDelete: MedicationData) {
        print("API call started")
        let deleteMedicationUrl = Details.apiHelper.baseURLWeb + "medications/invalid"
        let headers = ["X-Auth-Token": Details.token!,"Content-Type": "application/json"]
        let deleteDict: [String:Any] = ["patientId": Details.patientId!,
                                        "careplanId": Details.careplanId!,
                                        "medicationId": medicationToDelete.medicationId ?? "",
                                        "lastEffectiveDate": "",
                                        "activeFlag": "Y",
                                        "logId": "null",
                                        "careplanLogMessageUserInput": "An existing medication \(medicationToDelete.name ?? "") has been deleted",
                                        "careplanLogMessage": "An existing medication \(medicationToDelete.name ?? "") has been deleted"]
        do{
            let deleteJson = try JSONSerialization.data(withJSONObject: deleteDict)
            Details.apiManager.APIHelper(url: deleteMedicationUrl, params: [:], method: .post, headers: headers, requestBody: deleteJson) { result in
                switch result{
                case .success(let data):
                    do {
                        let deleteDecoded = try JSONDecoder().decode(MedicationDeleteResponse.self, from: data)
                        print("The deleteDecoded :\(deleteDecoded)")
                        //print("The delete Log Id : \(deleteDecoded.logId!)")
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
                            let currentMedicationId = medicationToDelete.medicationId
                            print("The medication idddd:\(currentMedicationId!)")
                            
                            self.medicationDetailList.remove(at: indexpath.row)
                            DispatchQueue.main.async {
                                self.tableView.deleteRows(at: [indexpath], with: .fade)
                            }
                            LocalNotificationManager.removeLocalNotification(identifier: String(currentMedicationId!))
                        }
                    }
                    catch {
                        //let dataString = String(data: data, encoding: .utf8)
                        print("Error in the data:\(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("Error in the delete API:\(error)")
                }
            }
        }
        catch {
            print("Error in serializing the deleteDict:\(error)")
        }
    }
}

//MARK: - Extension
extension MedicationListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if medicationDetailList.count > 0{
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.hideView.isHidden = true
            })
        }else {
            self.hideView.isHidden = false
        }
        return medicationDetailList.count
    }
    
    //MARK: - TableViewDatasourceMethods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! Cell
        let medicationItem = medicationDetailList[indexPath.row]
        print("The medicationItem:\(medicationItem)")
        configureCell(cell: cell, medicationItem: medicationItem)
        return cell
    }
    
    //MARK: - ConfigureCell
    func configureCell(cell: Cell, medicationItem: MedicationData) {
        if let quantity = medicationItem.quantity{
            let quantityStr = String(quantity)
            cell.quantityLable.text = quantityStr
        }
        else {
            print("Medication quantitiy is nil")
        }
        cell.medicationLable.text = medicationItem.name
        cell.frequencyLable.text = medicationItem.frequency
        cell.dateDayLable.text = medicationItem.effectiveDate
        cell.lastDayDateLable.text = medicationItem.lastEffectiveDate ?? "  -  "
        cell.baseView.layer.cornerRadius = 5
        cell.baseView.layer.shadowColor = UIColor.black.cgColor
        cell.baseView.layer.shadowOpacity = 0.4
        cell.baseView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        cell.baseView.layer.shadowRadius = 3.0
    }
    
    //MARK: - TableViewDelegateMethods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 165
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "MedicationShowVC") as! MedicationShowVC
        vc.medicationToShow = medicationDetailList[indexPath.row]
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_,_, completionHandler) in
            self?.handlerEditAction(at: indexPath)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [editAction])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = medicationDetailList[indexPath.row]
            print("Item to Delete:\(itemToDelete)")
            print("deleted medication id: \(itemToDelete.medicationId!)")
            let alert = UIAlertController(title: "Confirmation", message: "Are you sure about deleting the medication?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { _ in
                self.deleteMedicationServiceCall(using: indexPath, medicationToDelete: itemToDelete)
                self.showToastAlert("Medication deleted successfully", duration: 1.5)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true)
        }
    }
    
    //MARK: - EditAction
    func handlerEditAction(at indexPath: IndexPath) {
        let itemToEdit = medicationDetailList[indexPath.row]
        print("The item To edit :\(itemToEdit)")
//        let editViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AddMedicationVC") as! AddMedicationVC
//        editViewController.hidesBottomBarWhenPushed = true
//        editViewController.dataEnterDelegate = self
//        editViewController.medicationDatas = itemToEdit
//        editViewController.navigationItem.title = "Edit Medication"
//        navigationController?.pushViewController(editViewController, animated: true)
        navigateToAddOrEditScreen(withTitle: "Edit medication", itemtoEdit: itemToEdit)
        if let medicationId = itemToEdit.medicationId {
            let medicationIdToRemove = String(medicationId)
            LocalNotificationManager.removeLocalNotification(identifier: medicationIdToRemove)
        }
    }
    //MARK: - NavigationToAddOrEditScreen
    func navigateToAddOrEditScreen(withTitle: String, itemtoEdit: MedicationData){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddMedicationVC") as! AddMedicationVC
        vc.hidesBottomBarWhenPushed = true
        vc.dataEnterDelegate = self
        vc.medicationDatas = itemtoEdit
        vc.navigationItem.title = title
        navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: showToastAfterSaved
    func showToastAlert(_ message: String, duration: TimeInterval) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        // Present the alert
        present(alert, animated: true)
        // Dismiss the alert after the specified duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}












