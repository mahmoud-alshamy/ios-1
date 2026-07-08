import XCTest
@testable import DynamicWin

class MediaViewModelTests: XCTestCase {
    var viewModel: MediaViewModel!
    var mockService: MockMediaPlayerService!

    override func setUp() {
        super.setUp()
        mockService = MockMediaPlayerService()
        viewModel = MediaViewModel(service: mockService)
    }

    func testInitialState() {
        XCTAssertNil(viewModel.track)
        XCTAssertFalse(viewModel.isPlaying)
        XCTAssertFalse(viewModel.isFavorite)
    }

    func testTrackUpdateBinding() {
        let testTrack = MediaTrack(
            title: "Test Song",
            artist: "Test Artist",
            album: "Test Album",
            duration: 180,
            isPlaying: true,
            isFavorite: false
        )

        mockService.currentTrack = testTrack
        mockService.objectWillChange.send()

        XCTAssertEqual(viewModel.track?.title, "Test Song")
        XCTAssertEqual(viewModel.track?.artist, "Test Artist")
    }

    func testPlayPauseToggle() {
        mockService.currentTrack = MediaTrack(
            title: "Test",
            artist: "Artist",
            album: "Album",
            duration: 180,
            isPlaying: false,
            isFavorite: false
        )

        viewModel.togglePlayPause()
        XCTAssertTrue(mockService.playWasCalled || mockService.pauseWasCalled)
    }

    func testFavoriteToggle() {
        mockService.currentTrack = MediaTrack(
            title: "Test",
            artist: "Artist",
            album: "Album",
            duration: 180,
            isPlaying: false,
            isFavorite: false
        )

        viewModel.toggleFavorite()
        XCTAssertTrue(mockService.toggleFavoriteWasCalled)
    }
}

class MockMediaPlayerService: MediaPlayerService {
    var playWasCalled = false
    var pauseWasCalled = false
    var nextTrackWasCalled = false
    var previousTrackWasCalled = false
    var toggleFavoriteWasCalled = false

    override func play() throws {
        playWasCalled = true
        currentTrack?.isPlaying = true
    }

    override func pause() throws {
        pauseWasCalled = true
        currentTrack?.isPlaying = false
    }

    override func nextTrack() throws {
        nextTrackWasCalled = true
    }

    override func previousTrack() throws {
        previousTrackWasCalled = true
    }

    override func toggleFavorite() throws {
        toggleFavoriteWasCalled = true
        currentTrack?.isFavorite.toggle()
    }
}
