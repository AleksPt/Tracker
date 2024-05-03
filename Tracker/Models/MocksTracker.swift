import UIKit

final class MocksTracker {
    static var mocksTrackers: [TrackerCategory] = [
        TrackerCategory(
            headerName: "Спорт",
            trackerArray: [
                Tracker(id: UUID(),
                        name: "Фитнес",
                        color: .ypColorSelection1,
                        emoji: "🏃",
                        schedule: [.Tuesday, .Thursday, .Saturday]),
                Tracker(
                    id: UUID(),
                    name: "Настольный теннис",
                    color: .ypColorSelection2,
                    emoji: "🏓",
                    schedule: [.Monday, .Wednesday, .Friday]),
                Tracker(
                    id: UUID(),
                    name: "Йога",
                    color: .ypColorSelection3,
                    emoji: "🧘‍♂️",
                    schedule: [.Monday]),
            ]),
        TrackerCategory(
            headerName: "Отдых",
            trackerArray: [
                Tracker(
                    id: UUID(),
                    name: "Просмотр фильма",
                    color: .ypColorSelection4,
                    emoji: "📺",
                    schedule: [.Friday, .Saturday]),
                Tracker(
                    id: UUID(),
                    name: "Встреча с друзьями",
                    color: .ypColorSelection5,
                    emoji: "🍻",
                    schedule: [.Monday]),
            ])
    ]
}
