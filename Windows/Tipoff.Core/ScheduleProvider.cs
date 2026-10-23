using System.Net;

namespace Tipoff.Core;

public interface IScheduleLoading
{
    Task<ScheduleSnapshot> LoadAsync(DateOnly day, TimeZoneInfo zone, ScheduleGuide guide, CancellationToken cancellationToken = default);
}

public sealed class ScheduleProvider : IScheduleLoading, IDisposable
{
    private readonly HttpClient client;
    private readonly bool ownsClient;
    private readonly AltitudeProvider altitude;

    public ScheduleProvider(HttpClient? client = null)
    {
        ownsClient = client is null;
        this.client = client ?? new HttpClient(new HttpClientHandler { AutomaticDecompression = DecompressionMethods.All }) { Timeout = TimeSpan.FromSeconds(25) };
        this.client.DefaultRequestHeaders.UserAgent.ParseAdd("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36");
        this.client.DefaultRequestHeaders.AcceptLanguage.ParseAdd("en-US,en;q=0.9");
        altitude = new AltitudeProvider(this.client);
    }

    public async Task<ScheduleSnapshot> LoadAsync(DateOnly day, TimeZoneInfo zone, ScheduleGuide guide, CancellationToken cancellationToken = default)
    {
        var sourceDays = Dates.SourceDays(day, zone);
        IReadOnlyList<Game> games;
        string source;
        bool limited;
        if (guide == ScheduleGuide.Nba)
        {
            try
            {
                games = await FetchNbaDays(sourceDays, cancellationToken);
                source = "NBA.com";
                limited = false;
            }
            catch (OperationCanceledException) { throw; }
            catch
            {
                games = await FetchEspnDays(sourceDays, guide, cancellationToken);
                source = "ESPN fallback";
                limited = true;
            }
        }
        else if (guide is ScheduleGuide.Nhl or ScheduleGuide.Mlb)
        {
            try
            {
                var all = new List<Game>();
                foreach (var sourceDay in sourceDays)
                {
                    var address = guide == ScheduleGuide.Nhl
                        ? $"https://api-web.nhle.com/v1/schedule/{sourceDay}"
                        : $"https://statsapi.mlb.com/api/v1/schedule?sportId=1&date={sourceDay}&hydrate=broadcasts";
                    var text = await GetString(address, cancellationToken);
                    all.AddRange(guide == ScheduleGuide.Nhl ? LeagueFeedDecoder.Nhl(text, sourceDay) : LeagueFeedDecoder.Mlb(text, sourceDay));
                }
                games = all;
                source = guide == ScheduleGuide.Nhl ? "NHL.com" : "MLB.com";
                limited = guide == ScheduleGuide.Nhl;
            }
            catch (OperationCanceledException) { throw; }
            catch
            {
                games = await FetchEspnDays(sourceDays, guide, cancellationToken);
                source = $"ESPN · {guide.Title()} fallback";
                limited = true;
            }
        }
        else
        {
            games = await FetchEspnDays(sourceDays, guide, cancellationToken);
            source = $"ESPN · {guide.Title()}";
            limited = true;
        }

        var selected = games.Where(game => game.FallsOn(day, zone)).DistinctBy(game => game.Id).ToList();
        selected = (guide == ScheduleGuide.Nfl
            ? selected.OrderByDescending(game => game.IsBroncos).ThenBy(game => game.Start ?? DateTimeOffset.MaxValue)
            : selected.OrderBy(game => game.Start ?? DateTimeOffset.MaxValue)).ThenBy(game => game.Id).ToList();
        string? altitudeWarning = null;
        var usedAltitude = false;
        if (guide == ScheduleGuide.Nba && selected.Any(game => game.IsNuggets))
        {
            var supplement = await altitude.LoadAsync(cancellationToken);
            altitudeWarning = supplement.Warning;
            if (supplement.Schedule is not null)
            {
                selected = selected.Select(game =>
                {
                    var result = AltitudeDecoder.Enrich(game, supplement.Schedule, supplement.Saved);
                    if (result.Warning is not null) altitudeWarning = string.Join(' ', new[] { altitudeWarning, result.Warning }.Where(value => !string.IsNullOrWhiteSpace(value)));
                    if (result.Game.Altitude is not null) usedAltitude = true;
                    return result.Game;
                }).ToList();
            }
        }
        if (usedAltitude) source += " + Altitude";
        return new ScheduleSnapshot(selected, DateTimeOffset.UtcNow, Dates.Key(day), zone.Id, source, limited, guide, altitudeWarning);
    }

    private async Task<IReadOnlyList<Game>> FetchNbaDays(IEnumerable<string> days, CancellationToken cancellationToken)
    {
        var tasks = days.Select(async day => FeedDecoder.NbaPage(await GetString($"https://www.nba.com/games?date={day}", cancellationToken), day));
        return (await Task.WhenAll(tasks)).SelectMany(games => games).ToList();
    }

    private async Task<IReadOnlyList<Game>> FetchEspnDays(IEnumerable<string> days, ScheduleGuide guide, CancellationToken cancellationToken)
    {
        var games = new List<Game>();
        foreach (var day in days)
        {
            var compact = day.Replace("-", "", StringComparison.Ordinal);
            var json = await GetString($"https://site.api.espn.com/apis/site/v2/sports/{guide.EspnPath()}/scoreboard?dates={compact}&limit=100", cancellationToken);
            var decoded = FeedDecoder.Espn(json, guide);
            if (decoded.Any(game => game.ScheduleDay != day)) throw new FeedException("ESPN returned the wrong date.");
            games.AddRange(decoded);
        }
        return games;
    }

    private async Task<string> GetString(string address, CancellationToken cancellationToken)
    {
        using var response = await client.GetAsync(address, cancellationToken);
        if (response.StatusCode != HttpStatusCode.OK) throw new FeedException($"The schedule source returned HTTP {(int)response.StatusCode}.");
        return await response.Content.ReadAsStringAsync(cancellationToken);
    }

    public void Dispose() { if (ownsClient) client.Dispose(); }
}
