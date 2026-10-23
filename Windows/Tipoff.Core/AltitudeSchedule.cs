using System.Globalization;
using System.Net;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace Tipoff.Core;

public sealed record AltitudeEntry(
    string Day,
    string OpponentCode,
    bool DenverHome,
    DateTimeOffset Start,
    DateTimeOffset? Pregame,
    DateTimeOffset? Postgame,
    IReadOnlyList<string> Networks,
    IReadOnlyList<string> Notes);

public sealed record AltitudeSchedule(IReadOnlyList<AltitudeEntry> Entries, DateTimeOffset FetchedAt);

public sealed record AltitudeDetails(
    DateTimeOffset? Pregame,
    DateTimeOffset? Postgame,
    IReadOnlyList<string> Networks,
    IReadOnlyList<string> Notes,
    DateTimeOffset FetchedAt,
    bool Saved);

public sealed record AltitudeLoadResult(AltitudeSchedule? Schedule, string? Warning, bool Saved);

public static partial class AltitudeDecoder
{
    public const string SourceUrl = "https://www.altitudeplus.com/nuggets-broadcasts";
    private static readonly TimeZoneInfo Mountain = Dates.FindZone("Mountain Standard Time", "America/Denver");
    private static readonly IReadOnlyDictionary<string, string> Opponents = new Dictionary<string, string>
    {
        ["Atlanta Hawks"] = "ATL", ["Boston Celtics"] = "BOS", ["Brooklyn Nets"] = "BKN", ["Charlotte Hornets"] = "CHA",
        ["Chicago Bulls"] = "CHI", ["Cleveland Cavaliers"] = "CLE", ["Dallas Mavericks"] = "DAL", ["Detroit Pistons"] = "DET",
        ["Golden State Warriors"] = "GSW", ["Houston Rockets"] = "HOU", ["Indiana Pacers"] = "IND", ["Los Angeles Clippers"] = "LAC",
        ["LA Clippers"] = "LAC", ["Los Angeles Lakers"] = "LAL", ["Memphis Grizzlies"] = "MEM", ["Miami Heat"] = "MIA",
        ["Milwaukee Bucks"] = "MIL", ["Minnesota Timberwolves"] = "MIN", ["New Orleans Pelicans"] = "NOP", ["New York Knicks"] = "NYK",
        ["Oklahoma City Thunder"] = "OKC", ["Orlando Magic"] = "ORL", ["Philadelphia 76ers"] = "PHI", ["Phoenix Suns"] = "PHX",
        ["Portland Trail Blazers"] = "POR", ["Sacramento Kings"] = "SAC", ["San Antonio Spurs"] = "SAS", ["Toronto Raptors"] = "TOR",
        ["Utah Jazz"] = "UTA", ["Washington Wizards"] = "WAS"
    };

    public static AltitudeSchedule Page(string html, DateTimeOffset? fetchedAt = null)
    {
        var assignment = PageDataRegex().Match(html);
        if (!assignment.Success) throw new FeedException("Altitude returned an unexpected page.");
        var json = ExtractObject(html, assignment.Index + assignment.Length);
        using var document = JsonDocument.Parse(json);
        var root = document.RootElement;
        if (FeedDecoder.Text(root, "path") != "/nuggets-broadcasts" || !root.TryGetProperty("page", out var page) || !page.TryGetProperty("modules", out var modules) || modules.ValueKind != JsonValueKind.Array)
            throw new FeedException("Altitude returned the wrong page.");
        var tables = modules.EnumerateArray()
            .Select(module => FeedDecoder.Text(module, "rawText"))
            .Where(value => value.Contains("<table", StringComparison.OrdinalIgnoreCase))
            .ToList();
        if (tables.Count == 0) throw new FeedException("Altitude omitted its schedule table.");
        return new AltitudeSchedule(Table(string.Join('\n', tables)), fetchedAt ?? DateTimeOffset.UtcNow);
    }

    public static IReadOnlyList<AltitudeEntry> Table(string html)
    {
        var expected = new[] { "date", "matchup", "home/away", "pregame", "game start", "postgame", "networks" };
        var notes = ParagraphRegex().Matches(html).Select(match => PlainText(match.Groups[1].Value)).Where(value => value.StartsWith('*') || value.StartsWith('^')).ToList();
        var entries = new List<AltitudeEntry>();
        var foundHeader = false;
        foreach (Match rowMatch in RowRegex().Matches(html))
        {
            var row = rowMatch.Groups[1].Value;
            if (HeaderCellRegex().IsMatch(row))
            {
                var headers = HeaderCellRegex().Matches(row).Select(match => PlainText(match.Groups[1].Value).ToLowerInvariant()).ToArray();
                if (!headers.SequenceEqual(expected)) throw new FeedException("Altitude changed its table headers.");
                foundHeader = true;
                continue;
            }
            var cells = CellRegex().Matches(row).Select(match => PlainText(match.Groups[1].Value)).ToArray();
            if (!foundHeader || cells.Length != 7) throw new FeedException("Altitude returned a malformed schedule row.");
            if (cells.All(value => value.Equals("TBD", StringComparison.OrdinalIgnoreCase))) continue;
            if (!DateOnly.TryParseExact(cells[0], "M/d/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out var day) ||
                !TryMountainDateTime(cells[0], cells[4], out var start) || cells[2] is not ("Home" or "Away"))
                throw new FeedException("Altitude returned an invalid schedule date or venue.");
            var matchup = ParentheticalRegex().Replace(cells[1], "").Replace("Pre Season: ", "", StringComparison.Ordinal);
            var candidates = Opponents.Where(pair => matchup.Contains(pair.Key, StringComparison.Ordinal)).Select(pair => pair.Value).Distinct().ToList();
            if (!matchup.Contains("Nuggets", StringComparison.Ordinal) || candidates.Count != 1) throw new FeedException("Altitude returned an unknown matchup.");
            var pregame = ParseShowTime(cells[0], cells[3], start, false);
            var postgame = ParseShowTime(cells[0], cells[5], start, true);
            var networks = cells[6].Equals("none", StringComparison.OrdinalIgnoreCase)
                ? []
                : NetworkSeparatorRegex().Split(cells[6]).Select(value => value.Trim()).Where(value => value.Length > 0).ToList();
            if (networks.Any(value => value.Equals("TBD", StringComparison.OrdinalIgnoreCase))) throw new FeedException("Altitude returned a TBD network.");
            foreach (var marker in new[] { "*", "^" })
                if (cells[6].Contains(marker, StringComparison.Ordinal) && !notes.Any(note => note.StartsWith(marker, StringComparison.Ordinal)))
                    throw new FeedException("Altitude omitted a regional footnote.");
            entries.Add(new AltitudeEntry(Dates.Key(day), candidates[0], cells[2] == "Home", start, pregame, postgame, networks,
                notes.Where(note => cells[6].Contains(note[0])).ToList()));
        }
        if (!foundHeader || entries.Count == 0) throw new FeedException("Altitude returned an empty or malformed schedule.");
        return entries;
    }

    public static (Game Game, string? Warning) Enrich(Game game, AltitudeSchedule schedule, bool saved)
    {
        if (game.HomeCode != "DEN" && game.AwayCode != "DEN") return (game, null);
        if (game.Notice is not null) return (game, "Altitude’s listings weren’t applied to the changed Nuggets game schedule.");
        var day = game.Start is { } gameStart ? Dates.Key(DateOnly.FromDateTime(TimeZoneInfo.ConvertTime(gameStart, Mountain).DateTime)) : game.ScheduleDay;
        var opponent = game.HomeCode == "DEN" ? game.AwayCode : game.HomeCode;
        var matches = schedule.Entries.Where(entry => entry.Day == day && entry.DenverHome == (game.HomeCode == "DEN") && entry.OpponentCode == opponent).ToList();
        if (matches.Count != 1) return (game, "No matching Nuggets listing on Altitude’s schedule.");
        var entry = matches[0];
        if (game.Start is not { } start || Math.Abs((start - entry.Start).TotalSeconds) >= 60)
            return (game, "Altitude’s tipoff differs from the game schedule; its listings weren’t applied.");
        var existing = game.Broadcasts.Select(item => Canonical(item.Name).ToLowerInvariant()).ToHashSet();
        var additions = entry.Networks.Where(name => existing.Add(Canonical(name).ToLowerInvariant()))
            .Select(name => new Broadcast(Canonical(name) + (name.EndsWith('*') ? "*" : name.EndsWith('^') ? "^" : ""), "Altitude guide"));
        var broadcasts = additions.Concat(game.Broadcasts).ToList();
        var details = new AltitudeDetails(entry.Pregame, entry.Postgame, entry.Networks, entry.Notes, schedule.FetchedAt, saved);
        return (game with { Broadcasts = broadcasts, Altitude = details }, null);
    }

    private static string Canonical(string name)
    {
        var clean = name.TrimEnd('*', '^');
        return clean switch { "ALT" => "Altitude", "ALT2" => "Altitude 2", "Prime" => "Prime Video", _ => clean };
    }

    private static DateTimeOffset? ParseShowTime(string day, string value, DateTimeOffset start, bool postgame)
    {
        if (value.Length == 0 || value.Equals("n/a", StringComparison.OrdinalIgnoreCase) || value.Equals("tbd", StringComparison.OrdinalIgnoreCase)) return null;
        if (!TryMountainDateTime(day, value, out var result)) throw new FeedException("Altitude returned an invalid show time.");
        if (postgame && result < start) result = result.AddDays(1);
        return result;
    }

    private static bool TryMountainDateTime(string day, string time, out DateTimeOffset value)
    {
        if (DateTime.TryParseExact($"{day} {time}", "M/d/yyyy h:mm tt", CultureInfo.InvariantCulture, DateTimeStyles.None, out var local))
        {
            local = DateTime.SpecifyKind(local, DateTimeKind.Unspecified);
            value = new DateTimeOffset(local, Mountain.GetUtcOffset(local));
            return true;
        }
        value = default;
        return false;
    }

    private static string ExtractObject(string source, int start)
    {
        var depth = 0;
        var inString = false;
        var escaped = false;
        var began = false;
        for (var index = start; index < source.Length; index++)
        {
            var character = source[index];
            if (inString)
            {
                if (escaped) escaped = false;
                else if (character == '\\') escaped = true;
                else if (character == '"') inString = false;
            }
            else if (character == '"') inString = true;
            else if (character == '{') { depth++; began = true; }
            else if (character == '}' && began && --depth == 0) return source[start..(index + 1)];
        }
        throw new FeedException("Altitude returned incomplete page data.");
    }

    private static string PlainText(string html)
    {
        var value = TagsRegex().Replace(html, " ");
        value = WebUtility.HtmlDecode(value).Replace('\u00a0', ' ');
        return WhitespaceRegex().Replace(value, " ").Trim();
    }

    [GeneratedRegex(@"window\.page_data\s*=\s*", RegexOptions.IgnoreCase)] private static partial Regex PageDataRegex();
    [GeneratedRegex(@"<tr\b[^>]*>(.*?)</tr>", RegexOptions.IgnoreCase | RegexOptions.Singleline)] private static partial Regex RowRegex();
    [GeneratedRegex(@"<th\b[^>]*>(.*?)</th>", RegexOptions.IgnoreCase | RegexOptions.Singleline)] private static partial Regex HeaderCellRegex();
    [GeneratedRegex(@"<td\b[^>]*>(.*?)</td>", RegexOptions.IgnoreCase | RegexOptions.Singleline)] private static partial Regex CellRegex();
    [GeneratedRegex(@"<p\b[^>]*>(.*?)</p>", RegexOptions.IgnoreCase | RegexOptions.Singleline)] private static partial Regex ParagraphRegex();
    [GeneratedRegex(@"<[^>]*>")] private static partial Regex TagsRegex();
    [GeneratedRegex(@"\s+")] private static partial Regex WhitespaceRegex();
    [GeneratedRegex(@"\s*\([^)]*\)")] private static partial Regex ParentheticalRegex();
    [GeneratedRegex(@"[/&]")] private static partial Regex NetworkSeparatorRegex();
}

public sealed class AltitudeProvider
{
    private readonly HttpClient client;
    private readonly string cachePath;
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };

    public AltitudeProvider(HttpClient client, string? cachePath = null)
    {
        this.client = client;
        this.cachePath = cachePath ?? Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Tipoff", "Altitude.Windows.json");
    }

    public async Task<AltitudeLoadResult> LoadAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            using var request = new HttpRequestMessage(HttpMethod.Get, AltitudeDecoder.SourceUrl);
            using var response = await client.SendAsync(request, cancellationToken);
            if (!response.IsSuccessStatusCode) throw new FeedException("Altitude was unavailable.");
            var schedule = AltitudeDecoder.Page(await response.Content.ReadAsStringAsync(cancellationToken));
            cancellationToken.ThrowIfCancellationRequested();
            try
            {
                Directory.CreateDirectory(Path.GetDirectoryName(cachePath)!);
                var temporary = cachePath + ".tmp";
                await File.WriteAllTextAsync(temporary, JsonSerializer.Serialize(schedule, JsonOptions), cancellationToken);
                File.Move(temporary, cachePath, true);
                return new(schedule, null, false);
            }
            catch (OperationCanceledException) { throw; }
            catch { return new(schedule, "Couldn’t save Altitude’s offline listings.", false); }
        }
        catch (OperationCanceledException) { throw; }
        catch
        {
            try
            {
                var saved = JsonSerializer.Deserialize<AltitudeSchedule>(await File.ReadAllTextAsync(cachePath, cancellationToken), JsonOptions);
                if (saved is not null) return new(saved, "Altitude refresh failed. Showing saved Altitude listings; check Details for their age.", true);
            }
            catch (OperationCanceledException) { throw; }
            catch { }
            return new(null, "Couldn’t check Altitude’s Nuggets listings. Other listings are still shown.", false);
        }
    }
}
