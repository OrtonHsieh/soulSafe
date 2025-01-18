//
//  MapViewModel.swift
//  SoulSafe
//
//  Created by 謝承翰 on 2023/8/8.
//

import Foundation
import FirebaseFirestore
import MapKit

class MapViewModel {
    // swiftlint:disable all
    lazy var db = Firestore.firestore()
    // swiftlint:enable all
    func fetchGroupLocations(selectedGroupIDInMapView: String, completion: @escaping ([String: [Location]]) -> Void) {
        var groupLocations: [String: [Location]] = [:]
        let groupPath = db.collection("groups")
        let pathToGroupLocationCollection = groupPath.document(selectedGroupIDInMapView).collection("locations")
        pathToGroupLocationCollection.getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                guard let snapshot = snapshot else { return }
                var memberLocationFromSingleGroup: [Location] = []
                for document in snapshot.documents {
                    let locationData = document.data()
                    let oneUserFromSingleGroupLocation = Location(
                        id: locationData["id"] as? String ?? "",
                        groupID: locationData["groupID"] as? String ?? "",
                        userID: locationData["userID"] as? String ?? "",
                        userName: locationData["userName"] as? String ?? "",
                        userLocation: locationData["userLocation"] as? [String] ?? [],
                        // 這邊會拿到 URL
                        userAvatar: locationData["userAvatar"] as? String ?? "",
                        lastUpdate: locationData["lastUpdate"] as? Timestamp ?? Timestamp(date: Date())
                    )
                    memberLocationFromSingleGroup.append(oneUserFromSingleGroupLocation)
                    // 將每個 groupID 裡面的成員位置存入 Dict，可以用 groupID 來取用該群組內成員的位置
                    groupLocations["\(selectedGroupIDInMapView)"] = memberLocationFromSingleGroup
                }
                completion(groupLocations)
            }
        }
    }
    
    func addAnnotationForGroupLocations(
        maxIndex: Int,
        groupLocations: [String: [Location]],
        selectedGroupIDInMapView: String,
        completion: @escaping ([FriendsAnnotation]) -> Void
    ) {
        var annotations: [FriendsAnnotation] = []
        for index in 0..<maxIndex {
            guard let singleGroupLocation = groupLocations["\(selectedGroupIDInMapView)"] else { return }
            //            singleGroupLocation = singleGroupLocation
            let userLocationInString = singleGroupLocation[index].userLocation
            
            guard let latitude = Double(userLocationInString[0]) else { return }
            guard let longitude = Double(userLocationInString[1]) else { return }
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let coordinate = location.coordinate
            
            let annotation = FriendsAnnotation(
                userID: singleGroupLocation[index].userID,
                groupID: singleGroupLocation[index].groupID,
                userName: singleGroupLocation[index].userName,
                userAvatar: singleGroupLocation[index].userAvatar,
                coordinate: coordinate,
                lastUpdate: singleGroupLocation[index].lastUpdate
            )
            annotations.append(annotation)
        }
        completion(annotations)
    }
    
    func uploadUserLocation(groupIDs: [String], location: CLLocation, completion: @escaping (Bool) -> Void) {
        // 將使用者名稱、ID、位置、頭貼上傳
        guard let userAvatar = UserDefaults.standard.object(forKey: "userAvatar") else { return }
        for groupID in groupIDs {
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let userLocation: [String] = [latitude, longitude]
            let groupPath = db.collection("groups")
            let locationsOfGroupPath = groupPath.document(groupID).collection("locations")
            let pathToGroupMemberLocation = locationsOfGroupPath.document(UserSetup.userID)
            let location = Location(
                id: pathToGroupMemberLocation.documentID,
                groupID: groupID,
                userID: UserSetup.userID,
                userName: UserSetup.userName,
                userLocation: userLocation,
                userAvatar: "\(userAvatar)",
                lastUpdate: Timestamp(date: Date())).toDict
            pathToGroupMemberLocation.setData(location, merge: true) { error in
                if let error = error {
                    completion(false)
                    print(error)
                } else {
                    completion(true)
                    print("successfully overwriten location")
                }
            }
        }
    }
}
