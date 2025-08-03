import Foundation
import GameplayKit
import CoreData

// MARK: - Secure Game Notifier

class SecureGameNotifier {
    // MARK: - Properties
    
    private let gameCenterManager: GameCenterManager
    private let notificationCenter: NotificationCenter
    private let coreDataStack: CoreDataStack
    private let gameNotifierDelegate: GameNotifierDelegate?
    
    init(gameCenterManager: GameCenterManager, notificationCenter: NotificationCenter, coreDataStack: CoreDataStack, delegate: GameNotifierDelegate?) {
        self.gameCenterManager = gameCenterManager
        self.notificationCenter = notificationCenter
        self.coreDataStack = coreDataStack
        self.gameNotifierDelegate = delegate
    }
    
    // MARK: - Notifier Functions
    
    func notifyGameInviteReceived(fromPlayer playerID: String, gameMatch gameMatchID: String) {
        // Check if the player is online and authenticated with Game Center
        if gameCenterManager.isAuthenticated {
            // Fetch the game match from Core Data
            if let gameMatch = fetchGameMatch(from: gameMatchID) {
                // Check if the game match has already been notified
                if !gameMatch.hasBeenNotified {
                    // Send a local notification to the user
                    sendLocalNotification(for: gameMatch)
                    // Update the game match as notified
                    updateGameMatchAsNotified(gameMatch)
                    // Inform the delegate
                    gameNotifierDelegate?.gameInviteReceived(from: playerID, gameMatch: gameMatch)
                }
            }
        }
    }
    
    func notifyGameInviteAccepted(fromPlayer playerID: String, gameMatch gameMatchID: String) {
        // Check if the player is online and authenticated with Game Center
        if gameCenterManager.isAuthenticated {
            // Fetch the game match from Core Data
            if let gameMatch = fetchGameMatch(from: gameMatchID) {
                // Check if the game match has already been accepted
                if !gameMatch.hasBeenAccepted {
                    // Update the game match as accepted
                    updateGameMatchAsAccepted(gameMatch)
                    // Inform the delegate
                    gameNotifierDelegate?.gameInviteAccepted(from: playerID, gameMatch: gameMatch)
                }
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func fetchGameMatch(from gameMatchID: String) -> GameMatch? {
        // Fetch the game match from Core Data
        let fetchRequest: NSFetchRequest<GameMatch> = GameMatch.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "gameMatchID = %@", gameMatchID)
        do {
            let results = try coreDataStack.mainContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching game match: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func sendLocalNotification(for gameMatch: GameMatch) {
        // Create a local notification
        let notification = UILocalNotification()
        notification.alertBody = "You have been invited to play \(gameMatch.gameName)!"
        notification.alertAction = "View Invite"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["gameMatchID": gameMatch.gameMatchID!]
        // Schedule the notification
        notificationCenter.schedule(notification, fireDate: Date(timeIntervalSinceNow: 1))
    }
    
    private func updateGameMatchAsNotified(_ gameMatch: GameMatch) {
        gameMatch.hasBeenNotified = true
        coreDataStack.saveContext()
    }
    
    private func updateGameMatchAsAccepted(_ gameMatch: GameMatch) {
        gameMatch.hasBeenAccepted = true
        coreDataStack.saveContext()
    }
}

// MARK: - GameCenterManager

class GameCenterManager {
    var isAuthenticated: Bool {
        // TO DO: Implement Game Center authentication logic
        return false
    }
}

// MARK: - CoreDataStack

class CoreDataStack {
    let mainContext: NSManagedObjectContext
    
    init() {
        // TO DO: Initialize Core Data stack
        mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    }
    
    func saveContext() {
        // TO DO: Implement Core Data context saving logic
    }
}

// MARK: - GameNotifierDelegate

protocol GameNotifierDelegate {
    func gameInviteReceived(from playerID: String, gameMatch: GameMatch)
    func gameInviteAccepted(from playerID: String, gameMatch: GameMatch)
}

// MARK: - GameMatch

@objc(GameMatch)
class GameMatch: NSManagedObject {
    @NSManaged var gameMatchID: String
    @NSManaged var gameName: String
    @NSManaged var hasBeenNotified: Bool
    @NSManaged var hasBeenAccepted: Bool
}