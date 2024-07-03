import ActivityKit
import WidgetKit
import SwiftUI

@main
struct Widgets: WidgetBundle {
    var body: some Widget {
        if #available(iOS 16.1, *) {
            GroceryDeliveryApp()
        }
    }
}

@available(iOSApplicationExtension 16.1, *)
struct GroceryDeliveryApp: Widget {
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeliveryTrackAttributes.self) { context in
            LiveInLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    dynamicIslandExpandedLeadingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    dynamicIslandExpandedTrailingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    dynamicIslandExpandedCenterView(context: context)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    dynamicIslandExpandedBottomView(context: context)
                }
                
            } compactLeading: {
                compactLeadingView(context: context)
            } compactTrailing: {
                compactTrailingView(context: context)
            } minimal: {
                minimalView(context: context)
            }
            .keylineTint(.cyan)
        }
    }
    
    
    //MARK: Expanded Views
    func dynamicIslandExpandedLeadingView(context: ActivityViewContext<DeliveryTrackAttributes>) -> some View {
        VStack {
            Label {
                Text("\(context.attributes.numberOfGroceryItems)")
                    .font(.title)
                    .frame(width: 64)
                    .multilineTextAlignment(.trailing)
            } icon: {
                Image("grocery")
                    .foregroundColor(.green)
            }
        }
    }
    
    func dynamicIslandExpandedTrailingView(context: ActivityViewContext<DeliveryTrackAttributes>) -> some View {
        return Label {
            Text(context.state.deliveryTime, style: .timer)
                .multilineTextAlignment(.trailing)
                .monospacedDigit()
            
        } icon: {
            Image(systemName: "timer").foregroundColor(.green).font(.title2)
        }
        .font(.title)
    }
    
    func dynamicIslandExpandedCenterView(context: ActivityViewContext<DeliveryTrackAttributes>) -> some View {
        Text("\(context.state.courierName) is on the way!")
            .lineLimit(1)
            .font(.caption)
    }
    
    func dynamicIslandExpandedBottomView(context: ActivityViewContext<DeliveryTrackAttributes>) -> some View {
        let url = URL(string: "LiveActivities://?CourierNumber=10086")
        return Link(destination: url!) {
            Label("Call courier", systemImage: "phone")
        }
        .frame(height: 32, alignment: .center)
        .foregroundColor(.green)
    }
    
    //MARK: Compact Views
    func compactLeadingView(context: ActivityViewContext<DeliveryTrackAttributes>) -> some View {
        VStack {
            Label {
                Text("\(context.attributes.numberOfGroceryItems) items")
            } icon: {
                Image("grocery")
                    .foregroundColor(.green)
            }
            .font(.caption2)
        }
    }
    
    func compactTrailingView(context: ActivityViewContext<DeliveryTrackAttributes>) -> some View {
        Text(context.state.deliveryTime, style: .timer)
            .multilineTextAlignment(.center)
            .frame(width: 40)
            .font(.caption2)
    }
    
    //MARK: Minimal Views
    func minimalView(context: ActivityViewContext<DeliveryTrackAttributes>) -> some View {
        VStack(alignment: .center) {
            Image(systemName: "timer")
            Text(context.state.deliveryTime, style: .timer)
                .multilineTextAlignment(.center)
                .monospacedDigit()
                .font(.caption2)
        }
    }
}





@available(iOSApplicationExtension 16.1, *)
struct LiveInLockScreenView: View {
    var context: ActivityViewContext<DeliveryTrackAttributes>
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .center) {
                Text(context.state.courierName + " is on the way!").font(.headline)
                HStack {
                    Text("You ordered")
                        .font(.subheadline)
                    Text("\(context.attributes.numberOfGroceryItems)")
                        .font(.title2)
                    Text("grocery items.")
                        .font(.subheadline)
                }
                ProgressLineView(progress: context.state.progress, time: context.state.deliveryTime)
                TotalWeightView(totalWeight: Measurement(value: 30, unit: UnitMass.kilograms))
            }
        }.padding(15)
    }
}

struct ProgressLineView: View {
    var progress: Int
    var time: Date
    var body: some View {
        HStack {
            Divider().frame(width: CGFloat(progress) * 2.08, height: 10).overlay(.gray).cornerRadius(5)
            Image("delivery")
            VStack {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .frame(height: 10)
                    .overlay(Text(time, style: .timer)
                        .font(.system(size: 8))
                        .multilineTextAlignment(.center))
            }
            Image("home")
        }
    }
}

struct TotalWeightView: View {
    let totalWeight: Measurement<UnitMass>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Total Weight")
                .font(.caption)
            
            Text(totalWeight.formatted())
                .font(.title)
                .minimumScaleFactor(0.8)
                .contentTransition(.numericText(value: totalWeight.value))
        }
        .foregroundColor(.green)
        .bold()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

