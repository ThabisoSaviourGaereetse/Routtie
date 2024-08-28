import SwiftUI
import Combine
import UserNotifications
import Firebase
import FirebaseAuth

class RoutineViewModel: ObservableObject {
    @Published var selectedDay: String? = nil
    @Published var selectedTime = Date()
    @Published var reminders: [Date] = []
    @Published var isAddRoutineVisible = false
    @Published var currentRoutine: Routine?
    @Published var routines: [Routine] = [] {
        didSet {
            saveRoutinesToFirestore()
            scheduleNotifications()
        }
    }
    @Published var completedRoutines: [Routine] = [] {
        didSet {
            saveRoutinesToFirestore()
        }
    }
    @Published var isLoggedIn: Bool = Auth.auth().currentUser != nil
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: AnyCancellable?
    private let db = Firestore.firestore()
    
    init() {
//        loadRoutines()
        loadRoutinesFromFirestore()
//        loadCompletedRoutines()
        setupAuthListener()
        requestNotificationPermission()
        scheduleNotifications()
        startRoutineCheckTimer()
        // Add a delay before sorting routines to avoid conflicts during initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.refreshRoutineSorting()
        }
    }

    private func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                // Safely unwrap self
                guard let self = self else { return }
                
                // Update login state
                self.isLoggedIn = user != nil
                
                if !self.isLoggedIn {
                    // Clear routines if logged out
                    self.routines.removeAll()
                    self.completedRoutines.removeAll()
                    self.saveRoutines() // Ensure local data is also cleared
                    self.saveCompletedRoutines()
                } else {
                    // Load routines if logged in
                    self.loadRoutinesFromFirestore()
                }
            }
        }
    }

    
    func startRoutineCheckTimer() {
        timer = Timer.publish(every: 60 * 60, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkCompletedRoutines()
                self?.scheduleNotifications()
            }
    }
    
    func resetSelectedTimesIfNewDay() {
        let calendar = Calendar.current
        let today = Date()
        
        for routine in routines {
            if let lastSelectedDate = routine.lastSelectedDate,
               !calendar.isDateInToday(lastSelectedDate) {
                if let index = routines.firstIndex(where: { $0.id == routine.id }) {
                    routines[index].selectedTimes.removeAll()
                    routines[index].lastSelectedDate = today
                }
            }
        }
        saveRoutinesToFirestore()
    }

    
    func checkCompletedRoutines() {
        let calendar = Calendar.current
        
        for routine in completedRoutines {
            if let completionDate = routine.completionDate,
               !calendar.isDateInToday(completionDate) {
                if let index = completedRoutines.firstIndex(where: { $0.id == routine.id }) {
                    var routineToMove = completedRoutines.remove(at: index)
                    routineToMove.completionDate = nil
                    routineToMove.selectedTimes.removeAll()
                    routines.append(routineToMove)
                }
            }
        }
        saveRoutinesToFirestore()
    }
    
    func toggleTimeSelection(for routine: Routine, time: Date) {
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            let isSelected = routines[index].selectedTimes.contains(time)
            
            if isSelected {
                routines[index].selectedTimes.removeAll { $0 == time }
            } else {
                routines[index].selectedTimes.append(time)
                routines[index].lastSelectedDate = Date()
                scheduleNotification(for: routine, at: time)
            }
            
            if routines[index].selectedTimes.count == routines[index].times.count {
                moveRoutineToCompleted(routines[index])
            }
            objectWillChange.send()
        }
    }
    
    func addRoutine(title: String, days: [String], times: [Date]) {
        let newRoutine = Routine(title: title, days: days, times: times)
        routines.append(newRoutine)
    }
    
    func updateRoutine(routine: Routine, title: String, days: [String], times: [Date]) {
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            routines[index].title = title
            routines[index].days = days
            routines[index].times = times
        }
    }
    
    func deleteRoutine(_ routine: Routine) {
        routines.removeAll { $0.id == routine.id }
        completedRoutines.removeAll { $0.id == routine.id }
        saveRoutinesToFirestore()
        scheduleNotifications()
        objectWillChange.send()
    }
    
    // Array of days of the week
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    // Helper function to get upcoming dates starting from today
    func getUpcomingDates(count: Int) -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<count).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
    }
    
    // Helper function to format the date to display only the day
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    // Helper function to get the short month name
    func formatMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM" // Short month name
        return formatter.string(from: date)
    }
    
    func formattedTime(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
        
        // Check current notification settings
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
        }
    }
    
    func scheduleNotification(for routine: Routine, at time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Don't miss it!"
        content.body = "Your routtie, \(routine.title) is coming up."
        content.sound = UNNotificationSound.default
        
        // Notification 5 minutes before
        let fiveMinutesBefore = Calendar.current.date(byAdding: .minute, value: -5, to: time)!
        let triggerFiveMinutesBefore = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fiveMinutesBefore)
        let requestFiveMinutesBefore = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: UNCalendarNotificationTrigger(dateMatching: triggerFiveMinutesBefore, repeats: false))
        
        // Update content for actual notification
        let actualContent = UNMutableNotificationContent()
        actualContent.title = "Time for your routtie,"
        actualContent.body = "\(routine.title)"
        actualContent.sound = UNNotificationSound.default
        
        // Actual notification
        let trigger = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: time)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: actualContent, trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: false))
        
        UNUserNotificationCenter.current().add(requestFiveMinutesBefore) { error in
            if let error = error {
                print("Error adding notification 5 minutes before: \(error)")
            } else {
                print("Notification 5 minutes before scheduled successfully for \(routine.title) at \(fiveMinutesBefore)")
            }
        }
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error)")
            } else {
                print("Notification scheduled successfully for \(routine.title) at \(time)")
            }
        }
    }
    
    func scheduleNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let routinesForToday = self.routinesForToday()
        for routine in routinesForToday {
            for time in routine.times {
                scheduleNotification(for: routine, at: time)
            }
        }
    }
    
    func moveRoutineToCompleted(_ routine: Routine) {
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            var routineToComplete = routines.remove(at: index)
            routineToComplete.completionDate = Date()
            completedRoutines.append(routineToComplete)
        }
        saveRoutinesToFirestore()
        scheduleNotifications()
    }
    
    
    // Helper function to check if a date is today
    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private func saveRoutines() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(routines) {
            UserDefaults.standard.set(encoded, forKey: "routines")
        }
    }
    
    private func saveCompletedRoutines() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(completedRoutines) {
            UserDefaults.standard.set(encoded, forKey: "completedRoutines")
        }
    }
    
    private func loadRoutines() {
        if let savedRoutines = UserDefaults.standard.object(forKey: "routines") as? Data {
            let decoder = JSONDecoder()
            if let loadedRoutines = try? decoder.decode([Routine].self, from: savedRoutines) {
                routines = loadedRoutines
            }
        }
    }
    
    private func loadCompletedRoutines() {
        if let savedCompletedRoutines = UserDefaults.standard.object(forKey: "completedRoutines") as? Data {
            let decoder = JSONDecoder()
            if let loadedCompletedRoutines = try? decoder.decode([Routine].self, from: savedCompletedRoutines) {
                completedRoutines = loadedCompletedRoutines
            }
        }
    }
    
    func routinesForToday() -> [Routine] {
        let today = Date()
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: today)
        return routines.filter { $0.days.contains(daysOfWeek[dayOfWeek - 1]) }
    }
    
    func otherRoutines() -> [Routine] {
        let today = Date()
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: today)
        return routines.filter { !($0.days.contains(daysOfWeek[dayOfWeek - 1])) }
    }
    
    func getCompletedRoutines() -> [Routine] {
        return completedRoutines
    }

    
    // Function to get sorted routines by next notification time
    func sortedRoutinesByNextNotification() -> [Routine] {
        return routines.sorted { ($0.nextNotificationTime ?? Date.distantFuture) < ($1.nextNotificationTime ?? Date.distantFuture) }
    }
    
    func setEditingRoutine(_ routine: Routine?) {
        currentRoutine = routine
    }
    
    func saveRoutine() {
        if let routine = currentRoutine {
            if let index = routines.firstIndex(where: { $0.id == routine.id }) {
                routines[index] = routine
            } else {
                routines.append(routine)
            }
        }
        currentRoutine = nil
    }
    
    // Method to sort routines by the closest upcoming time
    func sortRoutinesByClosestTime() {
        let now = Date()
        routines.sort { (routine1, routine2) -> Bool in
            let closestTime1 = routine1.times.min { abs($0.timeIntervalSince(now)) < abs($1.timeIntervalSince(now)) }
            let closestTime2 = routine2.times.min { abs($0.timeIntervalSince(now)) < abs($1.timeIntervalSince(now)) }
            return closestTime1?.timeIntervalSince(now) ?? 0 < closestTime2?.timeIntervalSince(now) ?? 0
        }
    }

        
    
    // Method to manually trigger sorting (in case routines are updated outside of didSet)
    func refreshRoutineSorting() {
        sortRoutinesByClosestTime()
    }
    
    // MARK: - Firestore Integration
    func saveRoutinesToFirestore() {
        guard let user = Auth.auth().currentUser else { return }

        let userId = user.uid
        let routinesCollection = db.collection("users").document(userId).collection("routines")

        routinesCollection.getDocuments { snapshot, error in
            if let error = error {
                print("Error getting routines: \(error)")
                return
            }

            snapshot?.documents.forEach { document in
                document.reference.delete()
            }

            for routine in self.routines {
                do {
                    let data = try JSONEncoder().encode(routine)
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let routineIdString = routine.id.uuidString  
                        routinesCollection.document(routineIdString).setData(json)
                    }
                } catch {
                    print("Error saving routine: \(error)")
                }
            }
        }
    }

    func loadRoutinesFromFirestore() {
        guard let user = Auth.auth().currentUser else { return }

        let userId = user.uid
        let routinesCollection = db.collection("users").document(userId).collection("routines")

        routinesCollection.getDocuments { snapshot, error in
            if let error = error {
                print("Error loading routines: \(error)")
                return
            }

            self.routines = snapshot?.documents.compactMap { document in
                do {
                    let data = try JSONSerialization.data(withJSONObject: document.data())
                    return try JSONDecoder().decode(Routine.self, from: data)
                } catch {
                    print("Error decoding routine: \(error)")
                    return nil
                }
            } ?? []
            
            // Trigger a UI update if needed
            DispatchQueue.main.async {
                self.refreshRoutineSorting()
                self.scheduleNotifications()
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            // Clear local data
            routines.removeAll()
            completedRoutines.removeAll()
            saveRoutines()
            saveCompletedRoutines()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}

struct Routine: Identifiable, Codable {
    var id = UUID()
    var title: String
    var days: [String]
    var times: [Date]
    var selectedTimes: [Date] = []
    var completionDate: Date?
    var lastSelectedDate: Date?
    

    // Computed property to get the next notification time
    var nextNotificationTime: Date? {
        return times.filter { $0 > Date() }.sorted().first
    }
}
