using System.Globalization;
using System.Text.Json.Serialization;

namespace Tipoff.Core;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum ScheduleGuide { Nba, Nfl, Wnba, Nhl, Mlb }

public static class ScheduleGuideInfo
{
    public static string Title(this ScheduleGuide guide) => guide.ToString().ToUpperInvariant();
    public static string EspnPath(this ScheduleGuide guide) => guide switch
    {
        ScheduleGuide.Nba => "basketball/nba",
        ScheduleGuide.Nfl => "football/nfl",
        ScheduleGuide.Wnba => "basketball/wnba",
        ScheduleGuide.Nhl => "hockey/nhl",
        ScheduleGuide.Mlb => "baseball/mlb",
        _ => throw new ArgumentOutOfRangeException(nameof(guide))
    };
}

public sealed record Broadcast(string Name, string Category)
{
    [JsonIgnore] public string Id => $"{Category}:{Name.ToLowerInvariant()}";
}

public sealed record Game(
    string Id,
    string Away,
    string Home,
    string AwayCode,
    string HomeCode,
    DateTimeOffset? Start,
    string ScheduleDay,
    string? Notice,
    IReadOnlyList<Broadcast> Broadcasts,
    AltitudeDetails? Altitude = null)
{
    [JsonIgnore] public bool IsBroncos => Id.StartsWith("nfl-", StringComparison.Ordinal) && (AwayCode == "DEN" || HomeCode == "DEN");
    [JsonIgnore] public bool IsNuggets => (Id.StartsWith("nba-", StringComparison.Ordinal) || Id.StartsWith("espn-", StringComparison.Ordinal)) && (AwayCode == "DEN" || HomeCode == "DEN");
    [JsonIgnore] public bool IsAvalanche => Id.StartsWith("nhl-", StringComparison.Ordinal) && (AwayCode == "COL" || HomeCode == "COL");
    [JsonIgnore] public bool IsRockies => Id.StartsWith("mlb-", StringComparison.Ordinal) && (AwayCode is "115" or "COL" || HomeCode is "115" or "COL");
    [JsonIgnore] public string? PreferredTeamLabel => IsNuggets ? "NUGGETS" : IsBroncos ? "BRONCOS" : IsAvalanche ? "AVALANCHE" : IsRockies ? "ROCKIES" : null;

    public bool FallsOn(DateOnly day, TimeZoneInfo zone) => Start is { } start
        ? DateOnly.FromDateTime(TimeZoneInfo.ConvertTime(start, zone).DateTime) == day
        : ScheduleDay == day.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

    public string TimeLabel(TimeZoneInfo zone) => Start is { } start
        ? TimeZoneInfo.ConvertTime(start, zone).ToString("h:mm tt", CultureInfo.InvariantCulture)
        : "Time TBD";
}

public sealed record ScheduleSnapshot(
    IReadOnlyList<Game> Games,
    DateTimeOffset FetchedAt,
    string Day,
    string TimeZone,
    string Source,
    bool LimitedCoverage,
    ScheduleGuide Guide,
    string? AltitudeWarning = null)
{
    [JsonIgnore]
    public IReadOnlyList<Game> DisplayGames
    {
        get
        {
            if (Guide is ScheduleGuide.Nfl or ScheduleGuide.Wnba) return Games.ToList();
            Func<Game, bool>? preferred = Guide switch
            {
                ScheduleGuide.Nba => game => game.IsNuggets,
                ScheduleGuide.Nhl => game => game.IsAvalanche,
                ScheduleGuide.Mlb => game => game.IsRockies,
                _ => null
            };
            var ordered = Games.OrderBy(game => game.Start ?? DateTimeOffset.MaxValue).ThenBy(game => game.Id).ToList();
            return preferred is null ? ordered : ordered.Where(preferred).Concat(ordered.Where(game => !preferred(game))).ToList();
        }
    }
}

public sealed class FeedException(string message) : Exception(message);

public static class Dates
{
    public static string Key(DateOnly day) => day.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

    public static IReadOnlyList<string> SourceDays(DateOnly day, TimeZoneInfo localZone)
    {
        var eastern = FindZone("Eastern Standard Time", "America/New_York");
        var localStart = new DateTime(day.Year, day.Month, day.Day, 0, 0, 0, DateTimeKind.Unspecified);
        var localEnd = localStart.AddDays(1).AddTicks(-1);
        var startUtc = TimeZoneInfo.ConvertTimeToUtc(localStart, localZone);
        var endUtc = TimeZoneInfo.ConvertTimeToUtc(localEnd, localZone);
        var first = DateOnly.FromDateTime(TimeZoneInfo.ConvertTimeFromUtc(startUtc, eastern));
        var last = DateOnly.FromDateTime(TimeZoneInfo.ConvertTimeFromUtc(endUtc, eastern));
        var result = new List<string>();
        for (var cursor = first; cursor <= last; cursor = cursor.AddDays(1)) result.Add(Key(cursor));
        return result;
    }

    public static TimeZoneInfo FindZone(string windows, string iana)
    {
        try { return TimeZoneInfo.FindSystemTimeZoneById(windows); }
        catch (TimeZoneNotFoundException) { return TimeZoneInfo.FindSystemTimeZoneById(iana); }
    }
}
