//
//  AddMedicationVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 13/09/23.
//

import UIKit
import UserNotifications

protocol DataEnterDelegate{
    func didUserEnterInformation()
  
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
    var logId: Int?
}
struct DataInfo: Codable {
    let timestamp: String?
    let carePlanDate: String?
    let careplanId: Int?
    let activeDiseases: String?
    let list: [MedicationInfo]?
    let diagnosisId: String?
}

struct MedicationInfo: Codable {
    let medicationId: Int?
    let name: String?
    let code: String?
    let frequencyCode: String?
    let customFrequency: String?
    let quantity: Int?
    let frequency: String
    let notes: String?
    let nonProprietaryId: String?
    let effectiveDate: String?
    let lastEffectiveDate: String?
    let invalidFlag: String?
}

//medication search

struct MedicationSearch: Codable{
    var status: String?
    var data: MedicationDetails?
}

struct MedicationDetails : Codable{
    var others : [OtherMedication]?


}
struct OtherMedication : Codable{
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
struct medicationEditResponse: Codable{
    var id: Int?
    var preventativeMeasureGoalCode: String?
    var status: String?
    var data: EditedData?
    var timestamp: String?
    var carePlanDate: String?
    var logId: Int?
}
struct EditedData: Codable{
    var timestamp: String?
    var carPlanDate: String?
    var activeDiseases: String?
    var list: [EditedListMedication]?
    var diagnosisId: String?
}
struct EditedListMedication:Codable{
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

class AddMedicationVC: UIViewController,UITextViewDelegate {
    
    
    
    
    @IBOutlet var medicationNameTextField: UITextField!
    @IBOutlet var frequencyTextField: UITextField!
    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var effectiveDateTextField: UITextField!
    @IBOutlet var effectiveEndDateTimeTextField: UITextField!
    @IBOutlet var notesTextfield: UITextField!
    @IBOutlet var searchTableview: UITableView!
    
    var medicationData: MedicationData!
    
    
    var delegate: DataEnterDelegate? = nil

   
    let datePicker = UIDatePicker()
    let datePickerEndDate = UIDatePicker()
    
    let pickerView = UIPickerView()
    
    var frequenciesFromApi:[MedicationFrequency] = []
    
    var meidcineNameFromApi: [String] = []

    var filteredSuggestion: [String] = []

    let rowHeight: CGFloat = 40.0
  
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //getting authorization from the user
        LocalNotificationManager.requestPermission()
        
        
        if let quantity = medicationData?.quantity{
            let stringQuantity = String(quantity)
            quantityTextField.text = stringQuantity
        }
        medicationNameTextField.text = medicationData?.name
        frequencyTextField.text = medicationData?.frequency
        
        notesTextfield.text = medicationData?.notes
        effectiveDateTextField.text = medicationData?.effectiveDate
        effectiveEndDateTimeTextField.text = medicationData?.lastEffectiveDate
       
        medicationNameTextField.tag = 1
        frequencyTextField.tag = 2
        quantityTextField.tag = 3
        notesTextfield.tag = 4
        effectiveDateTextField.tag = 5
        
        medicationNameTextField.delegate = self
        quantityTextField.delegate = self
        frequencyTextField.delegate = self
        effectiveDateTextField.delegate = self
        effectiveEndDateTimeTextField.delegate = self
        notesTextfield.delegate = self
        
        pickerView.delegate = self
        pickerView.dataSource = self
        frequencyTextField.inputView = pickerView
        
        medicationNameTextField.keyboardType = .asciiCapable
        quantityTextField.keyboardType = .asciiCapable
        
        searchTableview.delegate = self
        searchTableview.dataSource = self
        searchTableview.isHidden = true
        
        DatePicker()
        DatePicker2()
        
//        let currentDate = Date()
//        let dateformat = DateFormatter()
//        dateformat.dateFormat = "MM-dd-yyyy hh:mm a"
//
//
//        effectiveDateTextField.text = dateformat.string(from: currentDate)

        // Do any additional setup after loading the view.
        let frequencyApi = APIHelper.share.baseURLWeb + "hum-codes/CPLN-MEDI-FREQ"
        let frequencyParam = ["id": 33689]
        let headers = ["X-Auth-Token":Token.token!]
        APIManager.shared.APIHelper(url: frequencyApi, params: frequencyParam, method: .get, headers: headers, requestBody: nil) { result in
            switch result {
                
            case .success(let data):
                do{
                    let freqDecoded = try JSONDecoder().decode(MedicationFrequencyResponse.self, from: data)
                    
                    if freqDecoded.status == "success"{
                        
                        let datalist = freqDecoded.data
                        //print(datalist)
                        var datalistkeys = datalist?.keys
                        //print(datalistkeys!)
                        var datalistValues = datalist?.values
                        //print("The frequency datas:\(datalistValues!)")
                        if case let values? = datalistValues{
                            self.frequenciesFromApi.append(contentsOf: values)
                            
                        }
                        print("The dataValues:\(datalistValues)")
    
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
    
    
    /// this function is used to update the table view when we enter the medicaiton name in the text field
    /// - Parameter suggestion: as per the text in the textfield , it shows medication name
    func updateTableView(with suggestion :[String]){
        filteredSuggestion = suggestion
        searchTableview.reloadData()
        searchTableview.isHidden = suggestion.isEmpty
    }
    
    func DatePicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTappedForEffectiveDate))
        let canceleButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTappedForEffectiveDate))
        toolBar.setItems([doneButton,canceleButton], animated: true)
        effectiveDateTextField.inputView = datePicker
        effectiveDateTextField.inputAccessoryView = toolBar
        datePicker.preferredDatePickerStyle = .wheels
    }
    @objc func doneButtonTappedForEffectiveDate(_ button: UIBarButtonItem){
        self.datePicker.maximumDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy hh:mm a"
        effectiveDateTextField.text = formatter.string(from: datePicker.date)
        effectiveDateTextField.resignFirstResponder()
        
        }
    @objc func cancelButtonTappedForEffectiveDate(_ button: UIBarButtonItem){
        effectiveDateTextField.resignFirstResponder()
    }
    func DatePicker2(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTappedForLastEffectiveDate))
        let canceleButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTappedLastEffectiveDate))
        toolBar.setItems([doneButton,canceleButton], animated: true)
        effectiveEndDateTimeTextField.inputView = datePickerEndDate
        effectiveEndDateTimeTextField.inputAccessoryView = toolBar
        datePickerEndDate.preferredDatePickerStyle = .wheels
    }
    @objc func doneButtonTappedForLastEffectiveDate(_ button: UIBarButtonItem){
        self.datePickerEndDate.maximumDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy hh:mm a"
        effectiveEndDateTimeTextField.text = formatter.string(from: datePickerEndDate.date)
        effectiveEndDateTimeTextField.resignFirstResponder()
       
        }
    @objc func cancelButtonTappedLastEffectiveDate(_ button: UIBarButtonItem){
        effectiveEndDateTimeTextField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        medicationNameTextField.resignFirstResponder()
        quantityTextField.resignFirstResponder()
        frequencyTextField.resignFirstResponder()
        effectiveDateTextField.resignFirstResponder()
        notesTextfield.resignFirstResponder()
        return true
    }
    
    //MARK: - API
    func saveAPI(){
        let saveApi = APIHelper.share.baseURLWeb + "medications"
        let headers = ["X-Auth-Token": Token.token!,"Content-Type": "application/json"]
        
        let filteredFrequency = frequenciesFromApi.filter { name in
            if frequencyTextField.text == name.description{
                return true
            }
            return false
        }
        //print("The filtered Frequency: \(filteredFrequency)")
        var frequencyString = ""
        if let firstElement = filteredFrequency.first{
            frequencyString = firstElement.code ?? ""
        }
        print("The frequencyString: \(frequencyString)")
        
        var medicationIdString = ""
        if let medicId = medicationData?.medicationId{
            print("the medica id:\(medicId)")
            let medicationIdStr = String(medicId)
            medicationIdString = medicationIdStr
        }
        print("The medicationIdString:\(medicationIdString)")
        var saveJson:[String:Any] = [
            "patientId": Token.patientId!,
            "careplanId": Token.careplanId!,
            "medicationId": "",//"\(medicationIdString)"
            "code": "248543",
            "name": medicationNameTextField.text!,
            "notes": notesTextfield.text!,
            "effectiveDate": effectiveDateTextField.text,
            "lastEffectiveDate": effectiveEndDateTimeTextField.text,
            "frequency": frequencyString ,
            "customFrequency": "",
            "quantity": quantityTextField.text!,
            "activeFlag": "Y",
            "productCode": "ccm",
            "visitId": "",
            "isFavoriteFlag": "N",
            "logId": Token.logId,
            "careplanLogMessageUserInput": "A new medication '\(medicationNameTextField.text!)' has been added.",
            "careplanLogMessage": "A new medication '\(medicationNameTextField.text!)' has been added In a quantity of '\(quantityTextField.text!)'."
        ]
        print("The save Json: \(saveJson)")
        
        
        do{
            
            let saveDataJson = try JSONSerialization.data(withJSONObject: saveJson,options: [])
            let dataString = String(data: saveDataJson, encoding: .utf8)
            print("The save data aa:\(dataString)")
            APIManager.shared.APIHelper(url: saveApi, params: [:], method: .post, headers: headers, requestBody: saveDataJson) { result in
        
                    switch result {
        
                    case .success(let data):
                       
                      
                        do{
                            let serializeData = try JSONSerialization.jsonObject(with: data) //as? [String:Any]
                            print("The serializedata : \(serializeData)")
        
                            let saveDecoded = try JSONDecoder().decode(ResponseData.self, from: data)
//                            if let dataInfo = saveDecoded.data,let medicationList = dataInfo.list{
//                                for medicationnnn in medicationList{
//                                    let medicationIddd = medicationnnn.medicationId
//                                    print("The medicationIddd:\(medicationIddd)")
//                                }
//                            }

                            Token.logId = saveDecoded.logId
                            print("The logId:\(saveDecoded.logId)")
                            if saveDecoded.status == "success"{
                                DispatchQueue.main.async {
                                    LocalNotificationManager.scheduleMedicationRemainder(medicationName: self.medicationNameTextField.text!, frequency: self.frequencyTextField.text!, quantity: self.quantityTextField.text!, date: self.effectiveDateTextField.text!, medicationId:medicationIdString)
                                }
                                
                                
                                let datas = saveDecoded.data
                                let dataList = datas?.list
                                print("The save datas: \(datas))")
                                if case let saveList? = dataList{
                                    for saves in saveList{
                                        print("the dataaa lists: \(saves.effectiveDate)")
                                    }
                                }
                                
                                self.delegate?.didUserEnterInformation()
                                
                                DispatchQueue.main.async {
                                    self.navigationController?.popViewController(animated: true)
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
        
    func medicationvalidation(){
        let validationUrl = APIHelper.share.baseURLWeb + "medications/validation"
        let headers = ["X-Auth-Token": Token.token!,"Content-Type": "application/json"]
    
        let jsonDict: [String: Any] = [
            "patientId": Token.patientId!,
            "careplanId": Token.careplanId!,
            "medicationId": medicationData?.medicationId,
            "name": medicationNameTextField.text ?? "",
            "effectiveDate": effectiveDateTextField.text ?? "",
            "lastEffectiveDate": effectiveEndDateTimeTextField.text ?? ""
        ]
        print("The validation request :\(jsonDict)")
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: jsonDict,options: [])

            APIManager.shared.APIHelper(url: validationUrl, params: [:], method: .post, headers: headers, requestBody: jsonData) { result in
                switch result {
                    case .success(let data):
                        // Handle success: data is the successfully received data
                    let dataString = String(data: data, encoding: .utf8)
                    print("the validation data string: \(dataString)")
                    if dataString == "true"{
                        DispatchQueue.main.async {
                            self.saveAPI()
//                            let quantity1 = Int(self.quantityTextField.text!)
                           
                        }
                        //print("true successful")
   
                    }else{
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
    func SearchApi(){
        if medicationNameTextField.text!.count == 4 {
                    let medicationApi = APIHelper.share.baseURLWeb + "medications/names"
                    let medicationParam = ["medName" : medicationNameTextField.text!,"isCarePlan" : "Y"] as [String : Any]
                    let headers = ["X-Auth-Token":Token.token!]
            APIManager.shared.APIHelper(url: medicationApi, params: medicationParam, method: .post, headers: headers, requestBody: nil) { result in
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
                                            self.filteredSuggestion.append(mediPropName + mediNonPropName )
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


    func saveButtonAlert(message:String){
        let alert = UIAlertController(title: "Alert!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true)
    }
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        let medicineField = medicationNameTextField.text!
        let frequencyField = frequencyTextField.text!
        let quantityField = quantityTextField.text!
        let notesField = notesTextfield.text!
      
        if medicineField.isEmpty{
            saveButtonAlert(message: "Medicine Field is empty")
        }else if frequencyField.isEmpty{
            saveButtonAlert(message: "Frequency Field is empty")
        }else if quantityField.isEmpty{
            saveButtonAlert(message: "Quantity Field is empty")
        }else if notesField.isEmpty{
            saveButtonAlert(message: "Notes Field is empty")
        }
        
        self.medicationvalidation()
        
        
        print("Medicine Name :\(medicationNameTextField.text ?? "")")
        print("Frequency :\(frequencyTextField.text!)")
        print("Quantity :\(quantityTextField.text!)")
        print("Notes :\(notesTextfield.text!)")
        print("Effective Date:\(effectiveDateTextField.text!)")
        print("Effective end date:\(effectiveEndDateTimeTextField.text!)")
        
        

    }


}
extension AddMedicationVC:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText = medicationNameTextField.text as NSString?
        if range.location + range.length <= textFieldText?.length ?? 0 {
            let newText = textFieldText?.replacingCharacters(in: range, with: string) ?? ""
            let filteredSuggessions = filteredSuggestion.filter { $0.lowercased().contains(newText.localizedUppercase) }
            
            updateTableView(with: filteredSuggessions)
            
            self.SearchApi()
            
            if textField.tag == 1{
                        let character = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890'")
                        let set = CharacterSet(charactersIn: string)
                        
                        return character.isSuperset(of: set)
                    }
            else if textField.tag == 3{
                        let allowdedCharacter1 = CharacterSet(charactersIn: "1234567890.")
                        let set1 = CharacterSet(charactersIn: string)
                  
                        let maxNumbers = 3
                        let currentText = (textField.text ?? "") as NSString
                        let newText = currentText.replacingCharacters(in: range, with: string)
                      
                        return true && allowdedCharacter1.isSuperset(of: set1) && newText.count <= maxNumbers
                    }
        }
 

        return true
    }
}
extension AddMedicationVC: UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return frequenciesFromApi.count
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //print("frequency:\(frequenciesFromApi[row])")
        let frequency = frequenciesFromApi[row]
        return frequency.description
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return rowHeight
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let nameFrequency = frequenciesFromApi[row]
        frequencyTextField.text = nameFrequency.description
        frequencyTextField.resignFirstResponder()
    }
    
}

extension AddMedicationVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredSuggestion.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredSuggestion[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSuggestion = filteredSuggestion[indexPath.row]
        medicationNameTextField.text = selectedSuggestion
        filteredSuggestion.removeAll()
        searchTableview.reloadData()
        searchTableview.isHidden = true
    }

}


                
        


