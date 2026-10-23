using System.Globalization;
using Tipoff.Core;

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
    Console.WriteLine(result.LimitedCoverage ? "Coverage warning applies." : "Primary schedule source decoded successfully.");
    return 0;
}
catch (Exception error)
{
    Console.Error.WriteLine($"TipoffCheck failed: {error.Message}");
    return 1;
}
