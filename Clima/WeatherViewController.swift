//
//  ViewController.swift
//  WeatherApp
//
//  Created by Dimitrios Papageorgiou on 26/06/2018.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "29948bd915ed0c850af929bd6cbd48e2"//will be added to keys.plist
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    
    let weatherDataModel = WeatherDataModel()
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    //TODO:Set up the location manager here.
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation() //Asynchronous-works on background
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parameters: [String : String]){
        
        //closure-background process
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess{
                print("Success in getting weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
            }
            else{
                print("Error: \(String(describing: response.result.error))")
                self.cityLabel.text = "Unable to connect"
                
            }
        }
    }
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON){
        
        
        
        if let tempResult = json["main"]["temp"].double{
        //data for the UI
        weatherDataModel.temperature = Int(tempResult - 273.15)
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        
        updateUIwithWeatherData()
        }
        else{
            cityLabel.text = "Weather Unavailable"
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIwithWeatherData(){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature)
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    //updating location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        //ensure value is valid
        if location.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation()
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid": APP_ID]
        
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    //failed to receive location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavaiable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredNewCityName (city : String){
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
        
    }


    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    
}


