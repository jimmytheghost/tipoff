using System.Globalization;
using System.Text.Json;

namespace Tipoff.Core;

public static class LeagueFeedDecoder
{
    public static IReadOnlyList<Game> Nhl(string json, string expectedDay)
    {
        using var document = JsonDocument.Parse(json);
        var root = document.RootElement;
        if (!root.TryGetProperty("gameWeek", out var week) || !root.TryGetProperty("numberOfGames", out var countValue)) throw new FeedException("NHL.com returned an unexpected format.");
        var total = 0;
        var matched = false;
        var selected = new List<JsonElement>();
        foreach (var day in week.EnumerateArray())
        {
            var games = day.GetProperty("games");
            total += games.GetArrayLength();
            if (FeedDecoder.Required(day, "date") != expectedDay) continue;
            matched = true;
            selected.AddRange(games.EnumerateArray());
        }
        if (!matched || countValue.GetInt32() != total) throw new FeedException("NHL.com returned an incomplete schedule.");
        return selected.Select(row =>
        {
            var away = row.GetProperty("awayTeam");
            var home = row.GetProperty("homeTeam");
            var state = FeedDecoder.Required(row, "gameScheduleState");
            if (state is not ("OK" or "TBD" or "PPD" or "CNCL" or "SUSP")) throw new FeedException("NHL.com returned an unknown schedule state.");
            if (!DateTimeOffset.TryParse(FeedDecoder.Required(row, "startTimeUTC"), CultureInfo.InvariantCulture, DateTimeStyles.AssumeUniversal, out var start)) throw new FeedException("NHL.com omitted a game time.");
            var broadcasts = new List<Broadcast>();
            if (row.TryGetProperty("tvBroadcasts", out var listings))
            {
                if (listings.ValueKind != JsonValueKind.Array) throw new FeedException("NHL.com returned malformed broadcasters.");
                foreach (var item in listings.EnumerateArray())
                {
                    if (FeedDecoder.Required(item, "countryCode") != "US") continue;
                    var category = FeedDecoder.Required(item, "market") switch { "H" => "Home TV", "A" => "Away TV", "N" => "National", _ => throw new FeedException("NHL.com returned an unknown TV market.") };
                    broadcasts.Add(new(FeedDecoder.Required(item, "network"), category));
                }
            }
            var id = row.GetProperty("id").GetInt64();
            return new Game($"nhl-{id}", TeamName(away), TeamName(home), FeedDecoder.Required(away, "abbrev"), FeedDecoder.Required(home, "abbrev"), state == "TBD" ? null : start, expectedDay, state == "PPD" ? "Postponed" : state == "CNCL" ? "Cancelled" : state == "SUSP" ? "Suspended" : null, FeedDecoder.Unique(broadcasts));
        }).ToList();
    }

    public static IReadOnlyList<Game> Mlb(string json, string expectedDay)
    {
        using var document = JsonDocument.Parse(json);
        var root = document.RootElement;
        if (!root.TryGetProperty("dates", out var dates) || !root.TryGetProperty("totalGames", out var countValue)) throw new FeedException("MLB.com returned an unexpected format.");
        var rows = new List<JsonElement>();
        foreach (var day in dates.EnumerateArray())
        {
            if (FeedDecoder.Required(day, "date") != expectedDay) throw new FeedException("MLB.com returned the wrong date.");
            rows.AddRange(day.GetProperty("games").EnumerateArray());
        }
        if (countValue.GetInt32() != rows.Count) throw new FeedException("MLB.com returned an incomplete schedule.");
        return rows.Select(row =>
        {
            var away = row.GetProperty("teams").GetProperty("away").GetProperty("team");
            var home = row.GetProperty("teams").GetProperty("home").GetProperty("team");
            var status = row.GetProperty("status");
            var tbd = status.GetProperty("startTimeTBD").GetBoolean();
            if (!DateTimeOffset.TryParse(FeedDecoder.Required(row, "gameDate"), CultureInfo.InvariantCulture, DateTimeStyles.AssumeUniversal, out var start)) throw new FeedException("MLB.com omitted a game time.");
            var detail = FeedDecoder.Required(status, "detailedState");
            var notices = new List<string>();
            var doubleHeader = FeedDecoder.Text(row, "doubleHeader");
            if (doubleHeader is "Y" or "S") notices.Add($"Game {row.GetProperty("gameNumber").GetInt32()}");
            var stateNotice = FeedDecoder.Notice(detail);
            if (stateNotice is not null) notices.Add(stateNotice);
            var broadcasts = new List<Broadcast>();
            if (row.TryGetProperty("broadcasts", out var listings))
            {
                if (listings.ValueKind != JsonValueKind.Array) throw new FeedException("MLB.com returned malformed broadcasters.");
                foreach (var item in listings.EnumerateArray())
                {
                    var type = FeedDecoder.Required(item, "type");
                    if (type is "AM" or "FM") continue;
                    if (type != "TV") throw new FeedException("MLB.com returned an unknown broadcast type.");
                    var national = item.GetProperty("isNational").GetBoolean();
                    var side = FeedDecoder.Text(item, "homeAway");
                    var category = national ? "National" : side == "home" ? "Home" : side == "away" ? "Away" : throw new FeedException("MLB.com omitted a TV market.");
                    broadcasts.Add(new(FeedDecoder.Required(item, "name"), category));
                }
            }
            return new Game($"mlb-{row.GetProperty("gamePk").GetInt64()}", FeedDecoder.Required(away, "name"), FeedDecoder.Required(home, "name"), away.GetProperty("id").GetInt32().ToString(CultureInfo.InvariantCulture), home.GetProperty("id").GetInt32().ToString(CultureInfo.InvariantCulture), tbd ? null : start, expectedDay, notices.Count == 0 ? null : string.Join(" · ", notices), FeedDecoder.Unique(broadcasts));
        }).ToList();
    }

    private static string TeamName(JsonElement team)
    {
        var place = FeedDecoder.Required(team.GetProperty("placeName"), "default");
        var common = FeedDecoder.Required(team.GetProperty("commonName"), "default");
        return $"{place} {common}";
    }
}
