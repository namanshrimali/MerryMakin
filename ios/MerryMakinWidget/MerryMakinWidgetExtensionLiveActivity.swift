import ActivityKit
import WidgetKit
import SwiftUI

// Required by live_activities plugin: must be named exactly LiveActivitiesAppAttributes
struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState
    public struct ContentState: Codable, Hashable {}

    var id = UUID()
}

extension LiveActivitiesAppAttributes {
    func prefixedKey(_ key: String) -> String {
        return "\(id)_\(key)"
    }
}

private let appGroupId = "group.com.namanshrimali.merrymakin"

struct MerryMakinWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    EventThumbnailView(context: context, compact: false)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    EventTimeView(context: context, compact: false)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    EventDetailsView(context: context)
                }
            } compactLeading: {
                EventThumbnailView(context: context, compact: true)
            } compactTrailing: {
                EventTimeView(context: context, compact: true)
            } minimal: {
                EventThumbnailView(context: context, compact: true)
            }
        }
    }
}

// MARK: - Lock Screen (full) view
private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    private var sharedDefaults: UserDefaults? { UserDefaults(suiteName: appGroupId) }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            EventThumbnailView(context: context, compact: false)
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                EventTimeView(context: context, compact: false)
                if let guestCount = guestCount, guestCount > 0 {
                    Text("\(guestCount) guest\(guestCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if let location = locationString, !location.isEmpty {
                    LocationPinView(location: location)
                }
            }
            Spacer(minLength: 0)
        }
        .padding()
    }

    private var guestCount: Int? {
        guard let shared = sharedDefaults else { return nil }
        let key = context.attributes.prefixedKey("guestCount")
        let value = shared.object(forKey: key)
        if let n = value as? Int { return n }
        if let n = value as? NSNumber { return n.intValue }
        return nil
    }


    private var locationString: String? {
        sharedDefaults?.string(forKey: context.attributes.prefixedKey("location"))
            .flatMap { $0.isEmpty ? nil : $0 }
    }
}

// MARK: - Event thumbnail (image)
private struct EventThumbnailView: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    let compact: Bool
    private var sharedDefaults: UserDefaults? { UserDefaults(suiteName: appGroupId) }

    var body: some View {
        Group {
            if let path = sharedDefaults?.string(forKey: context.attributes.prefixedKey("eventImage")),
               let uiImage = UIImage(contentsOfFile: path) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            RoundedRectangle(cornerRadius: compact ? 6 : 10)
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    Image(systemName: "party.popper.fill")
                        .font(compact ? .body : .title)
                        .foregroundColor(.white)
                )
        }
        }
        .frame(width: compact ? 32 : 72, height: compact ? 32 : 72)
        .clipShape(RoundedRectangle(cornerRadius: compact ? 6 : 10))
    }
}

// MARK: - Time
private struct EventTimeView: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    var compact: Bool = false
    private var sharedDefaults: UserDefaults? { UserDefaults(suiteName: appGroupId) }

    var body: some View {
        if let startTime = sharedDefaults?.string(forKey: context.attributes.prefixedKey("startTime")), !startTime.isEmpty {
            Text(startTime)
                .font(compact ? .caption : .subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        } else {
            Text("—")
                .font(compact ? .caption : .subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Guest count + location for expanded
private struct EventDetailsView: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    private var sharedDefaults: UserDefaults? { UserDefaults(suiteName: appGroupId) }

    var body: some View {
        HStack(spacing: 12) {
            let key = context.attributes.prefixedKey("guestCount")
            let raw = sharedDefaults?.object(forKey: key)
            let guestCount: Int? = (raw as? Int) ?? (raw as? NSNumber).map(\.intValue)
            if let n = guestCount, n > 0 {
                Text("\(n) guest\(n == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if let location = sharedDefaults?.string(forKey: context.attributes.prefixedKey("location")), !location.isEmpty {
                LocationPinView(location: location)
            }
        }
    }
}

// MARK: - Location pin (opens Google Maps)
private struct LocationPinView: View {
    let location: String

    private var googleMapsURL: URL? {
        let encoded = location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? location
        let urlString = "https://www.google.com/maps/search/?api=1&query=\(encoded)"
        return URL(string: urlString)
    }

    var body: some View {
        if let url = googleMapsURL {
            Link(destination: url) {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                    Text(location)
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .foregroundColor(.accentColor)
            }
        } else {
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.caption2)
                Text(location)
                    .font(.caption)
                    .lineLimit(1)
            }
            .foregroundColor(.secondary)
        }
    }
}

@main
struct MerryMakinWidgetBundle: WidgetBundle {
    var body: some Widget {
        MerryMakinWidgetExtensionLiveActivity()
    }
}
