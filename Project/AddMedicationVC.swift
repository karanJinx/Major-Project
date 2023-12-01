//
//  AddMedicationVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 13/09/23.
//

import UIKit
import UserNotifications

protocol DataEnterDelegate {
    func didUserEnterInformation()
}

enum AddMedicationFieldsTags: Int {
    case medicationName = 1
    case frequency = 2
    case quantity = 3
    case notes = 4
    case effectiveEndDate = 5
}

//Medication Frequency
struct MedicationFrequencyResponse: Codable {
    let status: String?
    let data: [String: MedicationFrequency]?
}
struct MedicationFrequency: Codable {
    let code: String?
    let groupCode: String?
    let subGroupCode: String?
    var description: String?
    let longDescription: String?
    let sortOrder: Int?
}

// medication validity
struct ResponseData: Codable {
    let id: Int?
    let preventativeMeasureGoalCode: String?
    let status: String?
    let data: DataInfo?
    let timestamp: String?
    let carePlanDate: String?
    let logId: Int?
}
struct DataInfo: Codable {
    let timestamp: String?
    let carePlanDate: String?
    let careplanId: Int?
    let activeDiseases: String?
    let list: [MedicationInfo]
    let diagnosisId: String?
}
struct MedicationInfo: Codable {
    let medicationId: Int?
    let name: String?
    let code: String?
    let frequencyCode: String?
    let customFrequency: String?
    let quantity: Int?
    let frequency: String?
    let notes: String?
    let nonProprietaryId: String?
    let effectiveDate: String?
    let lastEffectiveDate: String?
    let invalidFlag: String?
}

//medication search
struct MedicationSearch: Codable {
    var status: String?
    var data: MedicationDetails?
}
struct MedicationDetails : Codable {
    var others : [OtherMedication]?
}
struct OtherMedication : Codable {
    var mediProId: String?
    var favMediId: String?
    var mediName: String?
    var mediProprietaryName: String?
    var mediNonProprietaryName: String?
    var mediDosageFormName: String?
    var mediRouteName: String?
    var proprietaryNameWithDosage: String?
    var nonProprietaryNameWithDosage: String?
    var mediSubstanceName: String?
    var mediActiNumeStng: String?
    var mediActiIngredUnit: String?
    var customMedicationName: String?
    var quantity: String?
    var frequency: String?
    var frequencyCode: String?
    var customFrequency: String?
}

//Edit Medication
struct medicationEditResponse: Codable {
    var id: Int?
    var preventativeMeasureGoalCode: String?
    var status: String?
    var data: EditedData?
    var timestamp: String?
    var carePlanDate: String?
    var logId: Int?
}
struct EditedData: Codable {
    var timestamp: String?
    var carPlanDate: String?
    var activeDiseases: String?
    var list: [EditedListMedication]?
    var diagnosisId: String?
}
struct EditedListMedication: Codable {
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

class AddMedicationVC: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet var medicationNameTextField: UITextField!
    @IBOutlet var frequencyTextField: UITextField!
    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var effectiveDateTextField: UITextField!
    @IBOutlet var effectiveEndDateTextField: UITextField!
    @IBOutlet var notesTextField: UITextField!
    @IBOutlet var searchTableview: UITableView!
    
    //MARK: - Properties
    var dataEnterDelegate: DataEnterDelegate? = nil
    var medicationData = MedicationData()
    let pickerView = UIPickerView()
    let datePicker = UIDatePicker()
    var activeTextfield: UITextField?
    var frequenciesList: [MedicationFrequency] = []
    var medicationNameList: [String] = []
    let rowHeight: CGFloat = 40.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
    
    //MARK: - InitialSetUP
    func initialSetUp(){
        setUpNavigationBar()
        setUpTextFields()
        assignMedicationDetailsToFields()
        setUpPickerView()
        setUpDatePicker()
        setUpToolBar()
        setUpSearchTableView()
        cancelButtonForPickerView()
        frequencyServiceCall()
    }
    
    //MARK: - SetUpNavigationBar
    /// To set up the Navigation Bar and setting the navigationBarButton title when saving and editing
    func setUpNavigationBar() {
        //To update the barbutton in add screen from save to update
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: (medicationData != nil) ? "Update" : "Save", style: .plain, target: self, action: #selector(saveButtonPressed))
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .systemGray6
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        // Set the status bar color to match the navigation bar
        navigationController?.navigationBar.barStyle = .black
    }
    //MARK: - SetUPTextFields
    /// setting the textfield delegate,clearButton,input view for datepicker and keyboard type for the textfield
    func setUpTextFields() {
        frequencyTextField.inputView = pickerView
        effectiveDateTextField.inputView = datePicker
        effectiveEndDateTextField.inputView = datePicker
        
        setPropertiesForTextField(textField: medicationNameTextField, tag: AddMedicationFieldsTags.medicationName.rawValue)
        setPropertiesForTextField(textField: frequencyTextField, tag: AddMedicationFieldsTags.frequency.rawValue)
        setPropertiesForTextField(textField: quantityTextField, tag: AddMedicationFieldsTags.quantity.rawValue, keyboardType: .numbersAndPunctuation)
        setPropertiesForTextField(textField: notesTextField, tag: AddMedicationFieldsTags.notes.rawValue)
        setPropertiesForTextField(textField: effectiveDateTextField, tag: AddMedicationFieldsTags.effectiveEndDate.rawValue)
    }
    
    func setPropertiesForTextField(textField: UITextField, tag: Int, keyboardType: UIKeyboardType = .asciiCapable) {
        textField.delegate = self
        textField.tag = tag
        textField.clearButtonMode = .always
        textField.keyboardType = keyboardType
    }
    
    //MARK: - AssignDetailsToFields
    /// This method is used to set the medication details in the text field which we get from the previous list screen
    func assignMedicationDetailsToFields() {
        if medicationData.medicationId != nil {
            if let quantity = medicationData.quantity {
                let stringQuantity = String(quantity)
                quantityTextField.text = stringQuantity
            }
            medicationNameTextField.text = medicationData.name ?? ""
            frequencyTextField.text = medicationData.frequency ?? ""
            
            notesTextField.text = medicationData.notes ?? ""
            effectiveDateTextField.text = medicationData.effectiveDate ?? ""
            effectiveEndDateTextField.text = medicationData.lastEffectiveDate ?? ""
        }
    }
    
    //MARK: - SetUpPickerView
    /// setting delegates to the pickerview
    func setUpPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    //MARK: - SetUPDatePicker
    /// datePicker properties like maximumDate,datepickerMode,prefferedDatePickerStyle,addTarget
    func setUpDatePicker() {
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(datepickerValueChanged), for: .valueChanged)
    }
    /// function is an action that gets triggered when the value of a UIDatePicker changes
    /// - Parameter sender: The sender is the date picker that triggered the action.
    @objc func datepickerValueChanged(sender: UIDatePicker) {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM-dd-yyyy hh:mm a"
        activeTextfield?.text = dateformatter.string(from: sender.date)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextfield = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextfield = nil
    }
    
    //MARK: - SetUPToolBar
    /// Setting the toolbar for the donebutton and cancelbutton
    func setUpToolBar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        
        toolbar.setItems([cancelButton, space, doneButton], animated: false)
        
        // Set the toolbar as the input accessory view for both text fields
        effectiveDateTextField.inputAccessoryView = toolbar
        effectiveEndDateTextField.inputAccessoryView = toolbar
    }
    
    
    // Called when the "Done" button on the toolbar is tapped
    @objc func doneButtonTapped() {
        activeTextfield?.resignFirstResponder()
    }
    
    // Called when the "Cancel" button on the toolbar is tapped
    @objc func cancelButtonTapped() {
        activeTextfield?.text = nil
        activeTextfield?.resignFirstResponder()
    }
    
    //MARK: - SetUPSearchTableView
    /// setting delegate for the searchTableView
    func setUpSearchTableView() {
        searchTableview.delegate = self
        searchTableview.dataSource = self
        searchTableview.isHidden = true
    }
    
    //MARK: - UpdateTableView
    /// this function is used to update the table view when we enter the medicaiton name in the text field
    /// - Parameter suggestion: as per the text in the textfield , it shows medication name
    func updateTableView(with suggestion :[String]) {
        medicationNameList = suggestion
        searchTableview.reloadData()
        searchTableview.isHidden = suggestion.isEmpty
    }
    
    //MARK: - CancelButtonForPickerView
    func cancelButtonForPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let canceleButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTappedFrequency))
        toolBar.setItems([canceleButton], animated: true)
        frequencyTextField.inputAccessoryView = toolBar
    }
    
    @objc func cancelButtonTappedFrequency(_ button: UIBarButtonItem) {
        frequencyTextField.resignFirstResponder()
    }
    //MARK: - TextFieldShouldReturn
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - SaveMedicationServiceCall
    func saveMedicationServiceCall() {
        let serviceUrl = APIHelper.share.baseURLWeb + "medications"
        let headers = ["X-Auth-Token": Details.token!, "Content-Type": "application/json"]
        
        do{
            let saveDataJson = try JSONSerialization.data(withJSONObject: requestParameterForSaveMedication(),options: [])
            let dataString = String(data: saveDataJson, encoding: .utf8)
            print("The save data aa:\(dataString!)")
            APIManager.shared.APIHelper(url: serviceUrl, params: [:], method: .post, headers: headers, requestBody: saveDataJson) { result in
                switch result {
                case .success(let data):
                    do{
                        let serializeData = try JSONSerialization.jsonObject(with: data) as? [String:Any]
                        print("The serializedata : \(serializeData!)")
                        
                        let saveDecoded = try JSONDecoder().decode(ResponseData.self, from: data)
                        print("The decoded:\(saveDecoded)")
                        if let saveMedicationId = saveDecoded.data{
                            for medicaId in saveMedicationId.list{
                                print("the medicationIdfirstfound:\(medicaId.medicationId!)")
                            }
                        }
                        
                        if saveDecoded.status == "success"{
                            DispatchQueue.main.async {
                                self.dataEnterDelegate?.didUserEnterInformation()
                                self.navigationController?.popViewController(animated: true)
                                if let medicationIdForRemainder = saveDecoded.id{
                                    DispatchQueue.main.async {
                                        LocalNotificationManager.scheduleMedicationRemainder(medicationName: self.medicationNameTextField.text!, frequency: self.frequencyTextField.text!, quantity: self.quantityTextField.text!, date: self.effectiveDateTextField.text!, medicationId: String(medicationIdForRemainder) )
                                    }
                                }
                            }
                            DispatchQueue.main.async {
                                if self.medicationData != nil {
                                    // Medication is not new, show "Medication updated successfully" alert
                                    let alert = UIAlertController(title: nil, message: "Medication updated successfully", preferredStyle: .alert)
                                    self.present(alert, animated: true)
                                    // Dismiss the alert after the specified duration
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        alert.dismiss(animated: true, completion: nil)
                                    }
                                } else {
                                    // Medication is  new, show "Medication saved successfully" alert
                                    let alert = UIAlertController(title: nil, message: "Medication saved successfully", preferredStyle: .alert)
                                    self.present(alert, animated: true)
                                    // Dismiss the alert after the specified duration
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        alert.dismiss(animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                    catch{
                        print("Catch error:\(error.localizedDescription)")
                    }
                    
                case .failure(let error):
                    print("save api error: \(error)")
                }
            }
        }
        catch{
            print("json serialization error in the save data: \(error)")
        }
        
    }
    func requestParameterForSaveMedication() -> [String: Any] {

        return [
            "patientId": Details.patientId!,
            "careplanId": Details.careplanId!,
            "medicationId": medicationData.medicationId != nil ? (medicationData.medicationId)! : "",
            "code": "",
            "name": medicationNameTextField.text ?? "" ,
            "notes": notesTextField.text ?? "",
            "effectiveDate": effectiveDateTextField.text ?? "",
            "lastEffectiveDate": effectiveEndDateTextField.text ?? "",
            "frequency": medicationData.frequencyCode ?? "" ,
            "customFrequency": "",
            "quantity": quantityTextField.text ?? 0,
            "activeFlag": "Y",
            "productCode": "ccm",
            "visitId": "",
            "isFavoriteFlag": "N",
            "logId": Details.logId ?? "",
            "careplanLogMessageUserInput": "A new medication '\(medicationNameTextField.text ?? "")' has been added.",
            "careplanLogMessage": "A new medication '\(medicationNameTextField.text ?? "")' has been added In a quantity of '\(quantityTextField.text ?? "")'."
        ]
    }
    //MARK: - FrequencyServiceCall
    func frequencyServiceCall() {
        let frequencyServiceUrl = APIHelper.share.baseURLWeb + "hum-codes/CPLN-MEDI-FREQ"
        let frequencyParameter = ["id": 33689]
        let headers = ["X-Auth-Token":Details.token!]
        APIManager.shared.APIHelper(url: frequencyServiceUrl, params: frequencyParameter, method: .get, headers: headers, requestBody: nil) { result in
            switch result {
                
            case .success(let data):
                do{
                    let frequencyDecoded = try JSONDecoder().decode(MedicationFrequencyResponse.self, from: data)
                    
                    if frequencyDecoded.status == "success"{
                        
                        let datalist = frequencyDecoded.data
                        //print("The dataList: \(datalist)")
                        var datalistkeys = datalist?.keys
                        //print(datalistkeys!)
                        var datalistValues = datalist?.values
                        //print("The frequency datas:\(datalistValues!)")
                        if case let values? = datalistValues{
                            self.frequenciesList.append(contentsOf: values)
                            print("The frequency list:\(self.frequenciesList)")
                        }
                        //print("The dataValues:\(datalistValues!)")
                    }else{
                        print("Error")
                    }
                }
                catch{
                    print("Catch error:\(error.localizedDescription)")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    //MARK: - MedicationValidationServiceCall
    func medicationValidationServiceCall() {
        let validationUrl = APIHelper.share.baseURLWeb + "medications/validation"
        let headers = ["X-Auth-Token": Details.token!,"Content-Type": "application/json"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParameterForMedicationValidation(),options: [])
            let jsonDataResponse = String(data: jsonData, encoding: .utf8)
            //print("The jsondata:\(jsonDataResponse)")
            APIManager.shared.APIHelper(url: validationUrl, params: [:], method: .post, headers: headers, requestBody: jsonData) { result in
                switch result {
                case .success(let data):
                    // Handle success: data is the successfully received data
                    let dataString = String(data: data, encoding: .utf8)
                    print("the validation data string: \(dataString!)")
                    if dataString == "true"{
                        DispatchQueue.main.async {
                            // Call the save API after successful validation
                            self.saveMedicationServiceCall()
                        }
                        //print("true successful")
                    }else {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Alert!", message: dataString, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                            self.present(alert, animated: true)
                        }
                        print("False successful")
                    }
                    //print("Received data:\(dataString)")
                case .failure(let error):
                    // Handle failure: error contains the error information
                    print("Error:: \(error.localizedDescription)")
                }
            }
        }
        catch{
            print("JSON Serialization Error: \(error)")
        }
    }
    func requestParameterForMedicationValidation() -> [String: Any] {
        return [
            "patientId": Details.patientId!,
            "careplanId": Details.careplanId!,
            "medicationId": medicationData.medicationId ?? "",
            "name": medicationNameTextField.text ?? "",
            "effectiveDate": effectiveDateTextField.text ?? "",
            "lastEffectiveDate": effectiveEndDateTextField.text ?? ""
        ]
    }
    //MARK: - SearchMedicationServiceCall
    func searchMedicationServiceCall() {
        
        if medicationNameTextField.text!.count >= 4 {
            let searchUrl = APIHelper.share.baseURLWeb + "medications/names"
            let medicationParameter = ["medName" : medicationNameTextField.text!,"isCarePlan" : "Y"] as [String : Any]
            let headers = ["X-Auth-Token":Details.token!]
            APIManager.shared.APIHelper(url: searchUrl, params: medicationParameter, method: .post, headers: headers, requestBody: nil) { result in
                switch result{
                case .success(let medications):
                    do{
                        let medicationDecoded = try JSONDecoder().decode(MedicationSearch.self, from: medications)
                        if medicationDecoded.status == "success"{
                            let dataMedication = medicationDecoded.data
                            let dataOthers = dataMedication?.others
                            //print("The dataOther:\(dataOthers)")
                            if case let values? = dataOthers{
                                for medName in values{
                                    let mediPropName = medName.mediProprietaryName ?? ""
                                    let mediNonPropName = medName.mediNonProprietaryName ?? ""
                                    self.medicationNameList.append(mediPropName + mediNonPropName)
                                }
                            }
                            DispatchQueue.main.async {
                                self.searchTableview.reloadData()
                                self.searchTableview.isHidden = false
                            }
                        }
                    }
                    catch{
                        print("Errorrr:\(error.localizedDescription)")
                    }
                    print(medications)
                case .failure(let error):
                    print("EError: \(error)")
                }
            }
        }
    }
    
    func saveButtonAlert(message:String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true)
    }
    
    //MARK: - IBAction
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        let medicineField = medicationNameTextField.text!
        let frequencyField = frequencyTextField.text!
        let quantityField = quantityTextField.text!
        let notesField = notesTextField.text!
        let effectiveDateField = effectiveDateTextField.text!
        
        if medicineField.isEmpty {
            saveButtonAlert(message: "Medicine name should not be empty")
        }else if frequencyField.isEmpty{
            saveButtonAlert(message: "Frequency should not be empty")
        }else if quantityField.isEmpty{
            saveButtonAlert(message: "Quantity should not be empty")
        }else if notesField.isEmpty{
            saveButtonAlert(message: "Notes should not be empty")
        }else if effectiveDateField.isEmpty{
            saveButtonAlert(message: "Effective date should not be empty")
        }
        else {
            self.medicationValidationServiceCall()
        }
        print("Medicine Name :\(medicationNameTextField.text ?? "")")
        print("Frequency :\(frequencyTextField.text!)")
        print("Quantity :\(quantityTextField.text!)")
        print("Notes :\(notesTextField.text!)")
        print("Effective Date:\(effectiveDateTextField.text!)")
        print("Effective end date:\(effectiveEndDateTextField.text!)")
    }
    
    
    @IBAction func backButtonPressedDiscardEditMedication(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(
            title: "Confirmation?",
            message: "Are you sure you want go back?",
            preferredStyle: .alert
        )
        let discardAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Handle discarding changes (e.g., pop the view controller)
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(discardAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
}

extension AddMedicationVC: UITextFieldDelegate {
    //MARK: UITextViewDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("Textfield",textField)
        print("Range",range)
        print("String",string)
        if textField.tag == AddMedicationFieldsTags.medicationName.rawValue {
            let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            self.searchMedicationServiceCall()
            if [textField.text] != medicationNameList{
                searchTableview.isHidden = true
            }
            let filteredSuggessions = medicationNameList.filter { $0.lowercased().contains(newText.localizedUppercase) }
            updateTableView(with: filteredSuggessions)
            
            let character = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890'")
            let set = CharacterSet(charactersIn: string)
            return character.isSuperset(of: set)
        }
        else if textField.tag == AddMedicationFieldsTags.quantity.rawValue {
            let character = CharacterSet(charactersIn: "1234567890")
            let set = CharacterSet(charactersIn: string)
            
            let maxlenght = 2
            let currentString:NSString = (textField.text ?? "") as NSString
            let newstring:NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            
            return true && character.isSuperset(of: set) && newstring.length <= maxlenght
        }
        else if textField.tag == AddMedicationFieldsTags.notes.rawValue {
            let character = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890'")
            let set = CharacterSet(charactersIn: string)
            return character.isSuperset(of: set)
        }
        return true
    }
}
extension AddMedicationVC: UIPickerViewDelegate, UIPickerViewDataSource {
    //MARK: UIPickerViewDatasource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return frequenciesList.count
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //print("frequency:\(frequenciesFromApi[row])")
        let frequency = frequenciesList[row]
        return frequency.description
    }
    
    //MARK: UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return rowHeight
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let nameFrequency = frequenciesList[row]
        medicationData.frequencyCode = nameFrequency.code
        frequencyTextField.text = nameFrequency.description
        frequencyTextField.resignFirstResponder()
    }
}

extension AddMedicationVC: UITableViewDelegate, UITableViewDataSource {
    //MARK: tableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        medicationNameList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = medicationNameList[indexPath.row]
        return cell
    }
    //MARK: tableViewDataDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSuggestion = medicationNameList[indexPath.row]
        medicationNameTextField.text = selectedSuggestion
        medicationNameList.removeAll()
        searchTableview.reloadData()
        searchTableview.isHidden = true
    }
}






