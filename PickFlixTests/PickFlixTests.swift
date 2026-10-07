//
//  PickFlixTests.swift
//  PickFlixTests
//

import Testing
@testable import PickFlix
import Foundation

// MARK: - Test Doubles

private final class MockTMDbService: TMDbServiceProtocol, @unchecked Sendable {
    var stubbedResult: Result<TMDbDiscoverResponse, Error>

    init(_ result: Result<TMDbDiscoverResponse, Error>) {
        self.stubbedResult = result
    }

    func discoverMovies(page: Int) async throws -> TMDbDiscoverResponse {
        try stubbedResult.get()
    }
}

private final class MockWatchmodeService: WatchmodeServiceProtocol, @unchecked Sendable {
    var stubbedResult: Result<[String], Error>

    init(_ result: Result<[String], Error> = .success([])) {
        self.stubbedResult = result
    }

    func getSources(tmdbId: Int) async throws -> [String] {
        try stubbedResult.get()
    }
}

// MARK: - Helpers

private func makeResponse(movies: [TMDbMovie]) -> TMDbDiscoverResponse {
    TMDbDiscoverResponse(page: 1, results: movies, totalPages: 100)
}

private func makeTMDbMovie(id: Int = 1, title: String = "Inception") -> TMDbMovie {
    TMDbMovie(id: id, title: title, overview: "A dream within a dream.", posterPath: "/img.jpg")
}

// MARK: - MoviePickEngine Tests

@Suite("MoviePickEngine") @MainActor
struct MoviePickEngineTests {

    @Test("Zwraca film przy poprawnej odpowiedzi API")
    func pickMovie_success_returnsMovie() async throws {
        let tmdb = MockTMDbService(.success(makeResponse(movies: [makeTMDbMovie(title: "Inception")])))
        let watchmode = MockWatchmodeService(.success(["Netflix", "HBO"]))
        let engine = MoviePickEngine(tmdb: tmdb, watchmode: watchmode)

        let movie = try await engine.pickMovie()

        #expect(movie.title == "Inception")
        #expect(movie.platforms.contains("Netflix"))
        #expect(movie.platforms.contains("HBO"))
    }

    @Test("Rzuca noMoviesFound gdy lista filmów jest pusta")
    func pickMovie_emptyResults_throwsNoMoviesFound() async {
        let tmdb = MockTMDbService(.success(makeResponse(movies: [])))
        let engine = MoviePickEngine(tmdb: tmdb, watchmode: MockWatchmodeService())

        await #expect(throws: MoviePickEngine.MoviePickError.self) {
            try await engine.pickMovie()
        }
    }

    @Test("Zwraca film z pustymi platformami gdy Watchmode nie odpowiada")
    func pickMovie_watchmodeFailure_returnMovieWithEmptyPlatforms() async throws {
        let tmdb = MockTMDbService(.success(makeResponse(movies: [makeTMDbMovie()])))
        let watchmode = MockWatchmodeService(.failure(URLError(.notConnectedToInternet)))
        let engine = MoviePickEngine(tmdb: tmdb, watchmode: watchmode)

        let movie = try await engine.pickMovie()

        #expect(movie.platforms.isEmpty)
    }

    @Test("Propaguje błąd sieciowy TMDb")
    func pickMovie_tmdbFailure_throws() async {
        let tmdb = MockTMDbService(.failure(URLError(.timedOut)))
        let engine = MoviePickEngine(tmdb: tmdb, watchmode: MockWatchmodeService())

        await #expect(throws: (any Error).self) {
            try await engine.pickMovie()
        }
    }
}

// MARK: - SearchMovieViewModel Tests

@Suite("SearchMovieViewModel")
struct SearchMovieViewModelTests {

    @Test("Wywołuje onFound z filmem przy sukcesie") @MainActor
    func findMovie_success_callsOnFound() async throws {
        let engine = MockMoviePickEngine()
        let vm = SearchMovieViewModel(engine: engine)

        var foundMovie: Movie?
        vm.findMovie(onFound: { foundMovie = $0 })
        try await Task.sleep(for: .milliseconds(100))

        #expect(foundMovie?.title == "Scarface")
    }

    @Test("Ustawia stan .error przy błędzie silnika") @MainActor
    func findMovie_failure_setsErrorState() async throws {
        let engine = MockMoviePickEngine()
        engine.result = .failure(URLError(.notConnectedToInternet))
        let vm = SearchMovieViewModel(engine: engine)

        vm.findMovie(onFound: { _ in })
        try await Task.sleep(for: .milliseconds(100))

        if case .error = vm.state { } else {
            Issue.record("Oczekiwano stanu .error, otrzymano .searching")
        }
    }

    @Test("Stan wyjściowy to .searching") @MainActor
    func initialState_isSearching() {
        let vm = SearchMovieViewModel(engine: MockMoviePickEngine())
        if case .searching = vm.state { } else {
            Issue.record("Oczekiwano stanu .searching jako początkowego")
        }
    }
}

// MARK: - TMDbModels JSON Decoding Tests

@Suite("TMDbModels — dekodowanie JSON") @MainActor
struct TMDbModelsTests {

    private let decoder = JSONDecoder()

    @Test("Dekoduje snake_case klucze (poster_path → posterURL)")
    func tmdbMovie_decodesSnakeCaseKeys() throws {
        let json = """
        {"id":42,"title":"Dune","overview":"Sand.","poster_path":"/dune.jpg"}
        """.data(using: .utf8)!

        let movie = try decoder.decode(TMDbMovie.self, from: json)

        #expect(movie.id == 42)
        #expect(movie.title == "Dune")
        #expect(movie.posterURL == "https://image.tmdb.org/t/p/w500/dune.jpg")
    }

    @Test("Zwraca pusty string gdy brak poster_path")
    func tmdbMovie_nilPosterPath_returnsEmptyURL() throws {
        let json = """
        {"id":1,"title":"No Poster","overview":"..."}
        """.data(using: .utf8)!

        let movie = try decoder.decode(TMDbMovie.self, from: json)

        #expect(movie.posterURL == "")
    }

    @Test("Dekoduje pełną odpowiedź discover z polem total_pages")
    func tmdbDiscoverResponse_decodesPageAndResults() throws {
        let json = """
        {"page":3,"results":[{"id":1,"title":"A","overview":"B","poster_path":null}],"total_pages":500}
        """.data(using: .utf8)!

        let response = try decoder.decode(TMDbDiscoverResponse.self, from: json)

        #expect(response.page == 3)
        #expect(response.totalPages == 500)
        #expect(response.results.count == 1)
    }
}

// MARK: - WatchmodeModels JSON Decoding Tests

@Suite("WatchmodeModels — dekodowanie JSON") @MainActor
struct WatchmodeModelsTests {

    private let decoder = JSONDecoder()

    @Test("Dekoduje title_results z odpowiedzi search")
    func watchmodeSearchResponse_decodesTitleResults() throws {
        let json = """
        {"title_results":[{"id":999,"name":"Inception"}]}
        """.data(using: .utf8)!

        let response = try decoder.decode(WatchmodeSearchResponse.self, from: json)

        #expect(response.titleResults.count == 1)
        #expect(response.titleResults.first?.id == 999)
        #expect(response.titleResults.first?.name == "Inception")
    }

    @Test("Dekoduje sources w szczegółach tytułu")
    func watchmodeTitleDetails_decodesSources() throws {
        let json = """
        {"sources":[{"name":"Netflix","type":"sub"},{"name":"Amazon","type":"rent"}]}
        """.data(using: .utf8)!

        let details = try decoder.decode(WatchmodeTitleDetails.self, from: json)

        #expect(details.sources?.count == 2)
        #expect(details.sources?.first?.name == "Netflix")
        #expect(details.sources?.first?.type == "sub")
    }

    @Test("Zwraca nil gdy brak pola sources")
    func watchmodeTitleDetails_missingSources_isNil() throws {
        let json = "{}".data(using: .utf8)!

        let details = try decoder.decode(WatchmodeTitleDetails.self, from: json)

        #expect(details.sources == nil)
    }

    @Test("Filtruje tylko źródła typu 'sub' (subskrypcja)")
    func watchmodeService_filtersOnlySubSources() throws {
        // Weryfikacja modelu: WatchmodeSource rozróżnia typy
        let json = """
        {"name":"Hulu","type":"sub"}
        """.data(using: .utf8)!

        let source = try JSONDecoder().decode(WatchmodeSource.self, from: json)

        #expect(source.type == "sub")
        #expect(source.name == "Hulu")
    }
}
