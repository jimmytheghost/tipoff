using System.Text.Json;
using Tipoff.Core;

var tests = new List<(string Name, Action Body)>
{
    ("NBA page decodes three games", () => Equal(3, Nba().Count)),
    ("NBA page keeps streaming listings", () => True(Nba()[0].Broadcasts.Any(item => item.Name == "Peacock"))),
    ("NBA page keeps source radio listings", () => True(Nba()[0].Broadcasts.Any(item => item.Category == "Home radio"))),
    ("NBA rejects wrong selected date", () => Throws(() => FeedDecoder.NbaPage(Fixture("nba-page.html"), "2026-10-21"))),
    ("NBA rejects challenge page", () => Throws(() => FeedDecoder.NbaPage("Access denied", "2026-10-20"))),
    ("ESPN decodes NBA fixture", () => Equal(3, FeedDecoder.Espn(Fixture("espn.json"), ScheduleGuide.Nba).Count)),
    ("ESPN rejects unknown feed", () => Throws(() => FeedDecoder.Espn("{}", ScheduleGuide.Nba))),
    ("Scores never enter serialized game model", ScoresNeverEnterModel),
    ("Mountain day spans two Eastern source dates", SourceDaysCoverLocalDay),
    ("Preferred NBA team sorts first", PreferredTeamSortsFirst),
    ("NHL fixture decodes expected day", () => Equal(12, LeagueFeedDecoder.Nhl(Fixture("nhl.json"), "2026-10-22").Count)),
    ("NHL excludes Canadian-only network", () => Equal("MSG", LeagueFeedDecoder.Nhl(Fixture("nhl.json"), "2026-10-22")[1].Broadcasts.Single().Name)),
    ("NHL rejects wrong day", () => Throws(() => LeagueFeedDecoder.Nhl(Fixture("nhl.json"), "2026-11-22"))),
    ("MLB fixture decodes all games", () => Equal(14, LeagueFeedDecoder.Mlb(Fixture("mlb.json"), "2026-07-01").Count)),
    ("MLB includes Rockies.TV source listing", () => True(LeagueFeedDecoder.Mlb(Fixture("mlb.json"), "2026-07-01").Any(game => game.Broadcasts.Any(item => item.Name == "Rockies.TV")))),
    ("MLB excludes radio", () => True(LeagueFeedDecoder.Mlb(Fixture("mlb.json"), "2026-07-01").All(game => game.Broadcasts.All(item => item.Category is not ("AM" or "FM"))))),
    ("WNBA preserves source networks", WnbaNetworks),
    ("NFL puts Broncos first", BroncosFirst),
    ("Sport identities stay scoped", SportIdentitiesAreScoped),
    ("Cache round trip stays sport/date/zone isolated", CacheRoundTrip),
    ("Altitude parses full season and regional notes", AltitudeParsesSeason),
    ("Altitude handles multiple stations and neutral sites", AltitudeHandlesVariants),
    ("Altitude enriches a matching Nuggets game", AltitudeEnrichesMatch),
    ("Altitude requires opponent venue and tipoff agreement", AltitudeRequiresAgreement),
    ("Altitude does not invent coverage or duplicate listings", AltitudeDoesNotInventOrDuplicate),
    ("Altitude rejects malformed pages", AltitudeRejectsMalformedPages),
    ("Altitude metadata survives serialization without scores", AltitudeMetadataRoundTrip),
    ("Altitude failed refresh preserves saved supplement and age", AltitudeFailedRefreshKeepsSavedSchedule)
};

var failures = 0;
foreach (var (name, body) in tests)
{
    try { body(); Console.WriteLine($"PASS  {name}"); }
    catch (Exception error) { failures++; Console.Error.WriteLine($"FAIL  {name}: {error.Message}"); }
}
Console.WriteLine($"Executed {tests.Count} tests: {tests.Count - failures} passed, {failures} failed.");
return failures == 0 ? 0 : 1;

static string Fixture(string name) => File.ReadAllText(Path.Combine(AppContext.BaseDirectory, "Fixtures", name));
static IReadOnlyList<Game> Nba() => FeedDecoder.NbaPage(Fixture("nba-page.html"), "2026-10-20");
static AltitudeSchedule Altitude() => AltitudeDecoder.Page(Fixture("altitude-page.html"), DateTimeOffset.Parse("2026-10-22T12:00:00Z"));
static Game NuggetsGame(string opponent = "NOP", bool denverHome = true, string start = "2026-10-25T01:00:00Z", string day = "2026-10-24") =>
    new("nba-test", denverHome ? "Pelicans" : "Nuggets", denverHome ? "Nuggets" : "Pelicans",
        denverHome ? opponent : "DEN", denverHome ? "DEN" : opponent, DateTimeOffset.Parse(start), day, null,
        [new Broadcast("League Pass", "Subscription")]);
static void True(bool value) { if (!value) throw new Exception("Expected true."); }
static void Equal<T>(T expected, T actual) where T : notnull { if (!EqualityComparer<T>.Default.Equals(expected, actual)) throw new Exception($"Expected {expected}; received {actual}."); }
static void Throws(Action action) { try { action(); } catch { return; } throw new Exception("Expected an exception."); }

static void ScoresNeverEnterModel()
{
    var json = JsonSerializer.Serialize(Nba()).ToLowerInvariant();
    True(!json.Contains("score", StringComparison.Ordinal) && !json.Contains("period", StringComparison.Ordinal) && !json.Contains("clock", StringComparison.Ordinal));
}

static void SourceDaysCoverLocalDay()
{
    var mountain = Dates.FindZone("Mountain Standard Time", "America/Denver");
    var days = Dates.SourceDays(new DateOnly(2026, 10, 20), mountain);
    Equal("2026-10-20,2026-10-21", string.Join(',', days));
}

static void PreferredTeamSortsFirst()
{
    var others = FeedDecoder.Espn(Fixture("espn.json"), ScheduleGuide.Nba);
    var nuggets = new Game("nba-denver", "Denver Nuggets", "New Orleans Pelicans", "DEN", "NOP", DateTimeOffset.Parse("2026-10-21T05:00:00Z"), "2026-10-20", null, []);
    var snapshot = new ScheduleSnapshot([others[0], nuggets, others[1]], DateTimeOffset.UtcNow, "2026-10-20", "Mountain Standard Time", "test", false, ScheduleGuide.Nba);
    Equal(nuggets.Id, snapshot.DisplayGames[0].Id);
}

static void WnbaNetworks()
{
    var games = FeedDecoder.Espn(Fixture("wnba.json"), ScheduleGuide.Wnba);
    Equal(3, games.Count);
    Equal("CBS,Paramount+", string.Join(',', games[0].Broadcasts.Select(item => item.Name)));
}

static void BroncosFirst()
{
    var games = FeedDecoder.Espn(Fixture("nfl.json"), ScheduleGuide.Nfl);
    var snapshot = new ScheduleSnapshot(games, DateTimeOffset.UtcNow, "2026-10-25", "Mountain Standard Time", "ESPN", true, ScheduleGuide.Nfl);
    True(snapshot.Games.Any(game => game.IsBroncos));
    var ordered = snapshot.Games.OrderByDescending(game => game.IsBroncos).ThenBy(game => game.Start).ToList();
    True(ordered[0].IsBroncos);
    var displaySnapshot = snapshot with { Games = ordered };
    True(displaySnapshot.DisplayGames[0].IsBroncos);
}

static void SportIdentitiesAreScoped()
{
    var nhl = new Game("nhl-1", "Away", "Home", "COL", "OTHER", null, "2026-10-22", null, []);
    var nba = nhl with { Id = "nba-1" };
    True(nhl.IsAvalanche && !nba.IsAvalanche && !nhl.IsNuggets);
}

static void CacheRoundTrip()
{
    var directory = Path.Combine(AppContext.BaseDirectory, "TestData", Guid.NewGuid().ToString("N"));
    try
    {
        var cache = new ScheduleCache(directory);
        var zone = TimeZoneInfo.Local;
        var day = new DateOnly(2026, 10, 20);
        var value = new ScheduleSnapshot([], DateTimeOffset.UtcNow, Dates.Key(day), zone.Id, "Test", false, ScheduleGuide.Nba);
        cache.Write(value);
        Equal("Test", cache.Read(day, zone, ScheduleGuide.Nba)!.Source);
        True(cache.Read(day, zone, ScheduleGuide.Nfl) is null);
        True(cache.Read(day.AddDays(1), zone, ScheduleGuide.Nba) is null);
    }
    finally { try { if (Directory.Exists(directory)) Directory.Delete(directory, true); } catch { } }
}

static void AltitudeParsesSeason()
{
    var value = Altitude();
    Equal(85, value.Entries.Count);
    var entry = value.Entries.Single(item => item.Day == "2026-10-24");
    Equal("NOP", entry.OpponentCode);
    True(entry.DenverHome);
    Equal("ALT,Altitude+,KTVD-20*", string.Join(',', entry.Networks));
    Equal(DateTimeOffset.Parse("2026-10-25T00:00:00Z"), entry.Pregame!.Value);
    Equal(DateTimeOffset.Parse("2026-10-25T03:30:00Z"), entry.Postgame!.Value);
    True(entry.Notes[0].Contains("exclusive in the Denver DMA", StringComparison.Ordinal));
}

static void AltitudeHandlesVariants()
{
    var value = Altitude();
    Equal("ALT2,Altitude+,KUSA-9*,KTVD-20*", string.Join(',', value.Entries.Single(item => item.Day == "2026-11-02").Networks));
    var neutral = value.Entries.Single(item => item.Day == "2026-11-07");
    Equal("IND", neutral.OpponentCode);
    True(!neutral.DenverHome);
    True(value.Entries.Single(item => item.Day == "2026-11-09").Notes[0].StartsWith('^'));
    Equal(DateTimeOffset.Parse("2027-01-02T22:00:00Z"), value.Entries.Single(item => item.Day == "2027-01-02").Start);
}

static void AltitudeEnrichesMatch()
{
    var input = NuggetsGame();
    var result = AltitudeDecoder.Enrich(input, Altitude(), false);
    True(result.Warning is null);
    Equal("Altitude,Altitude+,KTVD-20*,League Pass", string.Join(',', result.Game.Broadcasts.Select(item => item.Name)));
    True(result.Game.Altitude is { Saved: false } && result.Game.Altitude.Notes.Count > 0);
    Equal(input.Start!.Value, result.Game.Start!.Value);
}

static void AltitudeRequiresAgreement()
{
    var value = Altitude();
    foreach (var input in new[]
    {
        NuggetsGame(opponent: "LAL"),
        NuggetsGame(denverHome: false),
        NuggetsGame(start: "2026-10-25T02:00:00Z")
    })
    {
        var result = AltitudeDecoder.Enrich(input, value, false);
        Equal(input, result.Game);
        True(result.Warning is not null);
    }
    var duplicate = new AltitudeSchedule(value.Entries.Concat(value.Entries).ToList(), value.FetchedAt);
    True(AltitudeDecoder.Enrich(NuggetsGame(), duplicate, false).Game.Altitude is null);
}

static void AltitudeDoesNotInventOrDuplicate()
{
    var national = NuggetsGame(opponent: "OKC", denverHome: false, start: "2026-10-23T01:30:00Z", day: "2026-10-22");
    var nationalResult = AltitudeDecoder.Enrich(national, Altitude(), false);
    True(nationalResult.Warning is null);
    True(!nationalResult.Game.Broadcasts.Any(item => item.Name == "Altitude+"));

    var listed = NuggetsGame() with { Broadcasts = [new Broadcast("Altitude+", "Home streaming"), new Broadcast("League Pass", "Subscription")] };
    var result = AltitudeDecoder.Enrich(listed, Altitude(), true);
    Equal(1, result.Game.Broadcasts.Count(item => item.Name == "Altitude+"));
    True(result.Game.Altitude is { Saved: true });
}

static void AltitudeRejectsMalformedPages()
{
    Throws(() => AltitudeDecoder.Page("<html>Access denied</html>"));
    var html = Fixture("altitude-page.html");
    Throws(() => AltitudeDecoder.Page(html.Replace("/nuggets-broadcasts", "/avs-broadcasts", StringComparison.Ordinal)));
    Throws(() => AltitudeDecoder.Page(html.Replace("<th>Networks</th>", "<th>Unknown</th>", StringComparison.Ordinal)));
    Throws(() => AltitudeDecoder.Page(html.Replace("* Games on KUSA-9", "Games on KUSA-9", StringComparison.Ordinal)));
}

static void AltitudeMetadataRoundTrip()
{
    var game = AltitudeDecoder.Enrich(NuggetsGame(), Altitude(), true).Game;
    var input = new ScheduleSnapshot([game], DateTimeOffset.UtcNow, "2026-10-24", "Mountain Standard Time", "NBA.com + Altitude", false, ScheduleGuide.Nba, "Saved Altitude listings");
    var json = JsonSerializer.Serialize(input);
    True(!json.Contains("score", StringComparison.OrdinalIgnoreCase));
    var output = JsonSerializer.Deserialize<ScheduleSnapshot>(json)!;
    Equal(input.Source, output.Source);
    Equal(input.AltitudeWarning!, output.AltitudeWarning!);
    var details = output.Games[0].Altitude;
    True(details is not null);
    Equal("ALT,Altitude+,KTVD-20*", string.Join(',', details!.Networks));
    True(details is { Saved: true } && details.Notes.Count > 0);
}

static void AltitudeFailedRefreshKeepsSavedSchedule()
{
    var directory = Path.Combine(AppContext.BaseDirectory, "TestData", Guid.NewGuid().ToString("N"));
    var cachePath = Path.Combine(directory, "Altitude.json");
    try
    {
        Directory.CreateDirectory(directory);
        var schedule = Altitude();
        File.WriteAllText(cachePath, JsonSerializer.Serialize(schedule));
        var original = File.ReadAllBytes(cachePath);
        using var client = new HttpClient(new UnavailableHandler());
        var result = new AltitudeProvider(client, cachePath).LoadAsync().GetAwaiter().GetResult();
        True(result.Saved && result.Warning is not null && result.Schedule is not null);
        Equal(schedule.FetchedAt, result.Schedule!.FetchedAt);
        True(original.SequenceEqual(File.ReadAllBytes(cachePath)));

        var missing = new AltitudeProvider(client, Path.Combine(directory, "Missing.json")).LoadAsync().GetAwaiter().GetResult();
        True(!missing.Saved && missing.Warning is not null && missing.Schedule is null);
    }
    finally { try { if (Directory.Exists(directory)) Directory.Delete(directory, true); } catch { } }
}

sealed class UnavailableHandler : HttpMessageHandler
{
    protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken) =>
        Task.FromResult(new HttpResponseMessage(System.Net.HttpStatusCode.ServiceUnavailable) { Content = new StringContent("unavailable") });
}
