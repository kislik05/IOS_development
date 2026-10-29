import Foundation

struct Track {
    let title: String
    let artist: String
    let fileName: String       // без расширения
    let coverImageName: String // без расширения
}

enum TrackLibrary {
    static let tracks: [Track] = [
        Track(title: "Midnight Drive", artist: "Neon Waves",
              fileName: "track1", coverImageName: "cover1"),
        Track(title: "Sunset Boulevard", artist: "The Coast",
              fileName: "track2", coverImageName: "cover2"),
        Track(title: "Lost in Tokyo", artist: "Kaito",
              fileName: "track3", coverImageName: "cover3"),
        Track(title: "Paper Planes", artist: "Aria",
              fileName: "track4", coverImageName: "cover4"),
        Track(title: "Golden Hour", artist: "Lumen",
              fileName: "track5", coverImageName: "cover5"),
        Track(title: "Ocean Eyes", artist: "Mira",
              fileName: "track6", coverImageName: "cover6"),
        Track(title: "City Lights", artist: "Pulse",
              fileName: "track7", coverImageName: "cover7"),
        Track(title: "Falling Slowly", artist: "Echo",
              fileName: "track8", coverImageName: "cover8"),
        Track(title: "Northern Sky", artist: "Aurora",
              fileName: "track9", coverImageName: "cover9"),
        Track(title: "Last Summer", artist: "Days",
              fileName: "track10", coverImageName: "cover10"),
    ]
}
