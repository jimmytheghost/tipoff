using System.Globalization;
using Tipoff.Core;

if (args.Length > 0 && args[0].Equals("altitude", StringComparison.OrdinalIgnoreCase))
{
    try
    {
        using var client = new HttpClient(new HttpClientHandler { AutomaticDecompression = System.Net.DecompressionMethods.All }) { Timeout = TimeSpan.FromSeconds(25) };
        client.DefaultRequestHeaders.UserAgent.ParseAdd("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36");
        client.DefaultRequestHeaders.AcceptLanguage.ParseAdd("en-US,en;q=0.9");
        var html = await client.GetStringAsync(AltitudeDecoder.SourceUrl);
        Console.WriteLine($"Altitude response · {html.Length} characters · page data at {html.IndexOf("page_data", StringComparison.OrdinalIgnoreCase)}");
        var schedule = AltitudeDecoder.Page(html);
        Console.WriteLine($"Altitude · {schedule.Entries.Count} Nuggets listing(s) · checked {schedule.FetchedAt:u}");
        return 0;
    }
    catch (Exception error)
    {
        Console.Error.WriteLine($"TipoffCheck failed: {error.Message}");
        return 1;
    }
}

var guide = args.Length > 0 && Enum.TryParse<ScheduleGuide>(args[0], true, out var parsedGuide) ? parsedGuide : ScheduleGuide.Nba;
var day = args.Length > 1 && DateOnly.TryParseExact(args[1], "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var parsedDay)
    ? parsedDay : DateOnly.FromDateTime(DateTime.Now);

try
{
    using var provider = new ScheduleProvider();
    var result = await provider.LoadAsync(day, TimeZoneInfo.Local, guide);
    Console.WriteLine($"{result.Day} · {result.Guide.Title()} · {result.Source} · {result.Games.Count} game(s)");
    foreach (var game in result.DisplayGames)
    {
        var video = game.Broadcasts.Where(item => !item.Category.Contains("radio", StringComparison.OrdinalIgnoreCase));
        Console.WriteLine($"{game.TimeLabel(TimeZoneInfo.Local),8}  {game.Away} @ {game.Home}  [{string.Join(", ", video.Select(item => item.Name))}]");
    }
    if (!string.IsNullOrWhiteSpace(result.AltitudeWarning)) Console.WriteLine($"Altitude warning: {result.AltitudeWarning}");
    Console.WriteLine(result.LimitedCoverage ? "Coverage warning applies." : "Primary schedule source decoded successfully.");
    return 0;
}
catch (Exception error)
{
    Console.Error.WriteLine($"TipoffCheck failed: {error.Message}");
    return 1;
}
