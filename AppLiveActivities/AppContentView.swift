import SwiftUI
import ActivityKit

struct AppContentView: View {
    
    @State var showToast = false
    @State var showToastMessage = "🍀"
    @State var activities = Activity<DeliveryTrackAttributes>.activities
    @State var timer: Timer? = nil
    let activitiesOnTimer = NSMutableArray()
    
    func updateUI() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.listAllActivities()
        }
    }
    
    func showToast(message: String) {
        self.showToastMessage = message;
        self.showToast.toggle()
    }
    
    var body: some View {
        NavigationView {
            Form {
                
                Section {
                    Text("Create an activity to start a live activity")
                    
                    Button {
                        self.createActivity()
                        self.updateUI()
                    } label: {
                        Text("Create A New Activity").font(.body)
                    }.tint(.green)
                    
                    Button {
                        self.listAllActivities()
                    } label: {
                        Text("List All Activities").font(.body)
                    }.tint(.green)
                    
                    Button {
                        self.endAllActivity()
                        self.updateUI()
                    } label: {
                        Text("End All Activities").font(.body)
                    }.tint(.green)
                    
                }
                
                
                Section {
                    Text("Live Activities")
                    
                    ForEach(self.activities, id: \.id) { activity in
                        let courierName = activity.contentState.courierName
                        let deliveryTime = activity.contentState.deliveryTime
                        let isTimerContains = self.timer != nil && self.activitiesOnTimer.contains(activity)
                        
                        VStack(alignment: .leading) {
                            
                            HStack(alignment: .center, spacing: 8) {
                                Text(courierName)
                                Text(deliveryTime, style: .timer)
                                Spacer()
                                Text("Update")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .onTapGesture {
                                        self.updateActivity(activity: activity)
                                        self.updateUI()
                                        self.showToast(message: "Activity updated")
                                    }
                                
                                Button(isTimerContains ? "Stop" : "Start") {
                                    if timer == nil {
                                        var interval: TimeInterval = 3.0
#if targetEnvironment(simulator)
                                        interval = 1.0
#else
                                        interval = 2.0
#endif
                                        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                                            for item in self.activitiesOnTimer {
                                                self.updateActivity(activity: item as! Activity<DeliveryTrackAttributes>)
                                            }
                                        }
                                    }
                                    
                                    if isTimerContains {
                                        self.activitiesOnTimer.remove(activity)
                                    } else {
                                        self.activitiesOnTimer.add(activity)
                                    }
                                    self.updateUI()
                                    self.showToast(message: "Activity \(isTimerContains ? "stop" : "start")")
                                }
                                .tint(.green)
                                
                                Text("End")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .onTapGesture {
                                        self.endActivity(activity: activity)
                                        self.updateUI()
                                        self.showToast(message: "Activity ended")
                                    }
                                Text("Info")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .onTapGesture {
                                        var pushToken: String?
                                        if let data = activity.pushToken {
                                            pushToken = data.map { String(format: "%02x", $0) }.joined()
                                        }
                                        print("Activity \(activity.id), token is: \(pushToken ?? "")")
                                        
                                    }
                            }
                            
                            Text(activity.id)
                                .font(.caption)
                            
                                .padding([.top, .bottom], 8)
                        }
                    }
                    
                    
                }
                
            }
            .navigationTitle("Welcome")
            .fontWeight(.light)
            
        }
        .toast(isShow: $showToast, info: showToastMessage)
    }
    
    
    
    
    func createActivity() {
        let attributes = DeliveryTrackAttributes(numberOfGroceryItems: 16)
        let state = DeliveryTrackAttributes.LiveDeliveryData(courierName: "Mike", progress: 0, deliveryTime: Date.now + 120)
        do {
            let _ = try Activity<DeliveryTrackAttributes>.request(attributes: attributes, contentState: state, pushType: .token)
        } catch (let error) {
            print(error.localizedDescription);
        }
    }
    
    func listAllActivities() {
        var activities = Activity<DeliveryTrackAttributes>.activities
        activities.sort { $0.id > $1.id }
        self.activities = activities
    }
    
    func endAllActivity() {
        Task {
            for activity in Activity<DeliveryTrackAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }
    
    func updateActivity(activity: Activity<DeliveryTrackAttributes>) {
        Task {
            let o: DeliveryTrackAttributes.LiveDeliveryData = activity.contentState
            let newState = DeliveryTrackAttributes.LiveDeliveryData(courierName: o.courierName, progress: o.progress + 5, deliveryTime: o.deliveryTime)
            await activity.update(using: newState)
        }
    }
    
    func endActivity(activity: Activity<DeliveryTrackAttributes>) {
        Task {
            await activity.end(dismissalPolicy: .immediate)
        }
    }
    
}

