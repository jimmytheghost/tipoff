using System.Globalization;
using System.Net;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace Tipoff.Core;

public static partial class FeedDecoder
{
    public static IReadOnlyList<Game> NbaPage(string html, string expectedDay)
    {
        var match = NextDataRegex().Match(html);
        if (!match.Success) throw new FeedException("NBA.com returned an unexpected page.");
        using var document = JsonDocument.Parse(WebUtility.HtmlDecode(match.Groups[1].Value));
        var page = document.RootElement.GetProperty("props").GetProperty("pageProps");
        if (page.TryGetProperty("hasError", out var hasError) && hasError.ValueKind == JsonValueKind.True) throw new FeedException("NBA.com reported an error.");
        if (page.GetProperty("selectedDate").GetString() != expectedDay) throw new FeedException("NBA.com returned the wrong date.");
        var feed = page.GetProperty("gameCardFeed");
        if (feed.TryGetProperty("nextPageToken", out var token) && token.ValueKind is not (JsonValueKind.Null or JsonValueKind.Undefined)) throw new FeedException("NBA.com schedule was incomplete.");
        var games = new List<Game>();
        foreach (var module in feed.GetProperty("modules").EnumerateArray())
        foreach (var card in module.GetProperty("cards").EnumerateArray())
        {
            if (!card.TryGetProperty("cardData", out var row) || !row.TryGetProperty("gameId", out _)) continue;
            games.Add(ParseNbaGame(row, expectedDay));
        }
        return games;
    }

    private static Game ParseNbaGame(JsonElement row, string expectedDay)
    {
        var home = row.GetProperty("homeTeam");
        var away = row.GetProperty("awayTeam");
        var status = Text(row, "gameStatusText");
        var tbd = status.Contains("tbd", StringComparison.OrdinalIgnoreCase) || status.Contains("tba", StringComparison.OrdinalIgnoreCase) || Bool(row, "gameTimeTBD");
        DateTimeOffset? start = null;
        var startText = Text(row, "gameTimeUtc");
        if (!tbd && DateTimeOffset.TryParse(startText, CultureInfo.InvariantCulture, DateTimeStyles.AssumeUniversal, out var parsed)) start = parsed;
        if (!tbd && start is null) throw new FeedException("NBA.com omitted a game time.");
        var broadcasts = new List<Broadcast>();
        if (row.TryGetProperty("broadcasters", out var groups))
        {
            var categories = new (string Key, string Category)[] {
                ("nationalBroadcasters", "National"), ("nationalTvBroadcasters", "National"), ("nationalOttBroadcasters", "Streaming"),
                ("homeTvBroadcasters", "Home TV"), ("awayTvBroadcasters", "Away TV"), ("homeOttBroadcasters", "Home streaming"),
                ("awayOttBroadcasters", "Away streaming"), ("nationalRadioBroadcasters", "National radio"),
                ("homeRadioBroadcasters", "Home radio"), ("awayRadioBroadcasters", "Away radio"), ("subscriptionBroadcasters", "Subscription") };
            foreach (var (key, category) in categories)
            {
                if (!groups.TryGetProperty(key, out var list) || list.ValueKind != JsonValueKind.Array) continue;
                foreach (var item in list.EnumerateArray())
                {
                    var name = Text(item, "broadcasterDisplay");
                    if (name.Length == 0) name = Text(item, "broadcasterDisplayName");
                    if (name.Length == 0) name = Text(item, "broadcasterName");
                    if (name.Length > 0) broadcasts.Add(new(name, category));
                }
            }
        }
        return new Game("nba-" + Required(row, "gameId"), TeamName(away), TeamName(home), Text(away, "teamTricode"), Text(home, "teamTricode"), start, expectedDay, Notice(status), Unique(broadcasts));
    }

    public static IReadOnlyList<Game> Espn(string json, ScheduleGuide guide)
    {
        using var document = JsonDocument.Parse(json);
        var root = document.RootElement;
        if (!root.TryGetProperty("events", out var events) || events.ValueKind != JsonValueKind.Array) throw new FeedException("ESPN returned an unexpected format.");
        if (guide != ScheduleGuide.Nba)
        {
            if (!root.TryGetProperty("leagues", out var leagues) || leagues.GetArrayLength() == 0 || Text(leagues[0], "abbreviation") != guide.Title() || events.GetArrayLength() >= 100)
                throw new FeedException("ESPN returned an unexpected league or incomplete list.");
        }
        var eastern = Dates.FindZone("Eastern Standard Time", "America/New_York");
        var games = new List<Game>();
        foreach (var row in events.EnumerateArray())
        {
            var competition = row.GetProperty("competitions")[0];
            JsonElement home = default, away = default;
            foreach (var competitor in competition.GetProperty("competitors").EnumerateArray())
            {
                if (Text(competitor, "homeAway") == "home") home = competitor.GetProperty("team");
                else if (Text(competitor, "homeAway") == "away") away = competitor.GetProperty("team");
            }
            if (home.ValueKind == JsonValueKind.Undefined || away.ValueKind == JsonValueKind.Undefined) throw new FeedException("ESPN omitted a team.");
            var dateText = Text(competition, "date");
            if (!DateTimeOffset.TryParse(dateText, CultureInfo.InvariantCulture, DateTimeStyles.AssumeUniversal, out var start)) throw new FeedException("ESPN omitted a game time.");
            var status = competition.TryGetProperty("status", out var statusValue) ? statusValue : default;
            var type = status.ValueKind != JsonValueKind.Undefined && status.TryGetProperty("type", out var typeValue) ? typeValue : default;
            var statusName = type.ValueKind == JsonValueKind.Undefined ? "" : Text(type, "name");
            var tbd = statusName == "STATUS_SCHEDULED" && competition.TryGetProperty("timeValid", out var valid) && valid.ValueKind == JsonValueKind.False;
            if (guide != ScheduleGuide.Nba) ValidateEspnBroadcasts(competition);
            var broadcasts = ParseEspnBroadcasts(competition);
            var prefix = guide == ScheduleGuide.Nba ? "espn-" : $"{guide.ToString().ToLowerInvariant()}-espn-";
            var easternDay = DateOnly.FromDateTime(TimeZoneInfo.ConvertTime(start, eastern).DateTime);
            games.Add(new(prefix + Required(row, "id"), Required(away, "displayName"), Required(home, "displayName"), Required(away, "abbreviation"), Required(home, "abbreviation"), tbd ? null : start, Dates.Key(easternDay), Notice(statusName), broadcasts));
        }
        return games;
    }

    private static void ValidateEspnBroadcasts(JsonElement competition)
    {
        foreach (var key in new[] { "geoBroadcasts", "broadcasts" })
        {
            if (!competition.TryGetProperty(key, out var entries)) continue;
            if (entries.ValueKind != JsonValueKind.Array) throw new FeedException("ESPN returned malformed broadcasters.");
            foreach (var entry in entries.EnumerateArray())
            {
                var hasMedia = entry.TryGetProperty("media", out var media) && media.ValueKind == JsonValueKind.Object && Text(media, "shortName").Length > 0;
                var hasNames = entry.TryGetProperty("names", out var names) && names.ValueKind == JsonValueKind.Array;
                if (!hasMedia && !hasNames) throw new FeedException("ESPN changed its broadcast format.");
            }
        }
    }

    private static IReadOnlyList<Broadcast> ParseEspnBroadcasts(JsonElement competition)
    {
        var result = new List<Broadcast>();
        if (competition.TryGetProperty("geoBroadcasts", out var geo) && geo.ValueKind == JsonValueKind.Array)
        foreach (var item in geo.EnumerateArray())
        {
            var region = Text(item, "region");
            if (region.Length > 0 && !region.Equals("us", StringComparison.OrdinalIgnoreCase)) continue;
            var media = item.TryGetProperty("media", out var mediaValue) ? mediaValue : default;
            var market = item.TryGetProperty("market", out var marketValue) ? marketValue : default;
            var type = item.TryGetProperty("type", out var typeValue) ? typeValue : default;
            var name = media.ValueKind == JsonValueKind.Undefined ? "" : Text(media, "shortName");
            if (name.Length == 0) continue;
            var kind = type.ValueKind == JsonValueKind.Undefined ? "" : Text(type, "shortName");
            var locale = market.ValueKind == JsonValueKind.Undefined ? "" : Text(market, "type");
            result.Add(new(name, kind.Equals("radio", StringComparison.OrdinalIgnoreCase) ? $"{locale} radio".Trim() : locale.Length == 0 ? "TV / streaming" : locale));
        }
        if (result.Count == 0 && competition.TryGetProperty("broadcasts", out var older) && older.ValueKind == JsonValueKind.Array)
        foreach (var item in older.EnumerateArray())
        {
            if (!item.TryGetProperty("names", out var names) || names.ValueKind != JsonValueKind.Array) continue;
            var market = Text(item, "market");
            foreach (var name in names.EnumerateArray()) if (name.GetString() is { Length: > 0 } value) result.Add(new(value, market.Length == 0 ? "TV / streaming" : CultureInfo.InvariantCulture.TextInfo.ToTitleCase(market)));
        }
        return Unique(result);
    }

    internal static string Text(JsonElement element, string name) => element.ValueKind == JsonValueKind.Object && element.TryGetProperty(name, out var value) && value.ValueKind == JsonValueKind.String ? value.GetString() ?? "" : "";
    internal static string Required(JsonElement element, string name) => Text(element, name) is { Length: > 0 } value ? value : throw new FeedException($"The source omitted {name}.");
    internal static bool Bool(JsonElement element, string name) => element.TryGetProperty(name, out var value) && value.ValueKind == JsonValueKind.True;
    internal static IReadOnlyList<Broadcast> Unique(IEnumerable<Broadcast> values) => values.Where(value => value.Name.Length > 0).DistinctBy(value => value.Id).ToList();
    internal static string? Notice(string status) => status.Contains("postpon", StringComparison.OrdinalIgnoreCase) ? "Postponed" : status.Contains("cancel", StringComparison.OrdinalIgnoreCase) ? "Cancelled" : status.Contains("delay", StringComparison.OrdinalIgnoreCase) ? "Delayed" : status.Contains("suspend", StringComparison.OrdinalIgnoreCase) ? "Suspended" : null;
    private static string TeamName(JsonElement team) => string.Join(' ', new[] { Text(team, "teamCity"), Text(team, "teamName") }.Where(value => value.Length > 0));

    [GeneratedRegex("<script\\b[^>]*\\bid=[\"']__NEXT_DATA__[\"'][^>]*>([\\s\\S]*?)</script>", RegexOptions.IgnoreCase)]
    private static partial Regex NextDataRegex();
}
