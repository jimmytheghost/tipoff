using System.IO;
using System.Windows;
using Tipoff.App;
using Tipoff.Core;

var tests = new List<(string, Func<Task>)>
{
    ("Preferred card outline uses actual WPF template in both themes", NativeCardOutline),
    ("Unavailable differs from valid empty and recovers", async () => {
        using var h = new Harness();
        h.Provider.Fail = true;
        await h.Model.RefreshAsync();
        Check(h.Model.EmptyMessage.Contains("unavailable"));
        Check(!h.Model.EmptyMessage.Contains("No NBA"));
        h.Provider.Fail = false;
        await h.Model.RefreshAsync();
        Check(h.Model.EmptyMessage.Contains("No NBA games"));
        Check(h.Model.MessageVisibility == Visibility.Collapsed);
    }),
    ("Saved empty schedule remains a valid empty schedule", async () => {
        using var h = new Harness();
        h.Cache.Write(h.Snapshot());
        h.Provider.Fail = true;
        await h.Model.RefreshAsync();
        Check(h.Model.EmptyMessage.Contains("No NBA games"));
        Check(h.Model.Freshness.StartsWith("Saved"));
    }),
    ("Saved cards and original timestamps survive repeated failures", async () => {
        using var h = new Harness();
        h.Cache.Write(h.Snapshot([h.Game(true)]));
        h.Provider.Fail = true;
        await h.Model.RefreshAsync();
        var card = h.Model.Games.Single();
        Check(card.DetailsFreshness.Contains("saved just now"));
        var notified = false;
        card.PropertyChanged += (_, e) => notified |= e.PropertyName == "DetailsFreshness";
        h.Now = h.Now.AddMinutes(8);
        await h.Model.RefreshAsync();
        Check(ReferenceEquals(card, h.Model.Games.Single()));
        Check(card.DetailsFreshness.Contains("saved 8m ago") && notified);
        Check(h.Cache.Read(h.Model.SelectedDate, h.Zone, h.Model.Guide)!.FetchedAt == h.Start);
    }),
    ("Checked Altitude age updates without replacing expanded cards", async () => {
        using var h = new Harness();
        h.Provider.Games = [h.Game(false)];
        await h.Model.RefreshAsync();
        var card = h.Model.Games.Single();
        h.Now = h.Now.AddHours(2);
        h.Provider.Fail = true;
        await h.Model.RefreshAsync();
        Check(card.DetailsFreshness.Contains("checked 2h ago"));
        h.Now = h.Now.AddDays(1);
        h.Model.UpdateRelativeTime();
        Check(card.DetailsFreshness.Contains("checked 1d ago"));
    }),
    ("Resume forces refresh within throttle interval", async () => {
        using var h = new Harness();
        await h.Model.OpenedAsync();
        await h.Model.OpenedAsync();
        Check(h.Provider.Calls == 1);
        await h.Model.OpenedAsync(force: true);
        Check(h.Provider.Calls == 2);
        h.Now = h.Now.AddMinutes(6);
        await h.Model.OpenedAsync();
        Check(h.Provider.Calls == 3);
    }),
    ("Midnight follows calendar day", async () => {
        using var h = new Harness();
        await h.Model.OpenedAsync();
        h.Now = h.Now.AddMinutes(2);
        await h.Model.OpenedAsync();
        Check(h.Model.SelectedDate == new DateOnly(2026, 11, 12));
        Check(h.Provider.Calls == 2);
    }),
    ("Midnight preserves deliberately selected date", async () => {
        using var h = new Harness();
        await h.Model.MoveDayAsync(-1);
        var selected = h.Model.SelectedDate;
        h.Now = h.Now.AddDays(1);
        await h.Model.OpenedAsync();
        Check(h.Model.SelectedDate == selected);
    }),
    ("Timezone change reloads isolated schedule", async () => {
        using var h = new Harness();
        await h.Model.OpenedAsync();
        h.Zone = TimeZoneInfo.FindSystemTimeZoneById("Pacific Standard Time");
        await h.Model.OpenedAsync();
        Check(h.Model.TimeZone.Id == h.Zone.Id && h.Provider.Calls == 2);
    }),
    ("Interrupted refresh cannot overwrite newer result or failure state", async () => {
        using var h = new Harness();
        var pending = new TaskCompletionSource<ScheduleSnapshot>();
        h.Provider.Pending = pending.Task;
        var old = h.Model.RefreshAsync();
        Check(!h.Model.CanRefresh);
        h.Provider.Pending = null;
        await h.Model.SelectGuideAsync(ScheduleGuide.Nhl);
        pending.SetException(new IOException("late failure"));
        await old;
        Check(h.Model.Guide == ScheduleGuide.Nhl && h.Model.CanRefresh);
        Check(h.Model.MessageVisibility == Visibility.Collapsed);
        Check(h.Model.Source == "test-Nhl");
    }),
    ("Interrupted successful response cannot replace newer date", async () => {
        using var h = new Harness();
        var pending = new TaskCompletionSource<ScheduleSnapshot>();
        h.Provider.Pending = pending.Task;
        var old = h.Model.RefreshAsync();
        await h.Model.OpenedAsync();
        Check(h.Provider.Calls == 1);
        h.Provider.Pending = null;
        await h.Model.MoveDayAsync(1);
        pending.SetResult(h.Snapshot([h.Game(false)]));
        await old;
        Check(h.Model.Games.Count == 0 && h.Model.CanRefresh);
    }),
    ("Preferred identities include league and fallback cards", () => {
        using var h = new Harness();
        foreach (var (id, code) in new[] { ("nba-1", "DEN"), ("espn-1", "DEN"), ("nfl-1", "DEN"), ("nhl-1", "COL"), ("mlb-1", "115") })
            Check(GameCard.From(h.Game(false) with { Id = id, HomeCode = code }, h.Zone).IsPreferred);
        Check(!GameCard.From(h.Game(false) with { HomeCode = "BOS" }, h.Zone).IsPreferred);
        return Task.CompletedTask;
    })
};
var failed = 0;
foreach (var (name, test) in tests)
{
    try { await test(); Console.WriteLine($"PASS  {name}"); }
    catch (Exception e) { failed++; Console.WriteLine($"FAIL  {name}: {e}"); }
}
Console.WriteLine($"Executed {tests.Count} tests: {tests.Count - failed} passed, {failed} failed.");
return failed == 0 ? 0 : 1;
static Task NativeCardOutline()
{
    Exception? failure = null;
    var thread = new Thread(() => { try { NativeCardCheck.Run(); } catch (Exception e) { failure = e; } });
    thread.SetApartmentState(ApartmentState.STA);
    thread.Start();
    thread.Join();
    if (failure is not null) throw failure;
    return Task.CompletedTask;
}
static void Check(bool value) { if (!value) throw new Exception("Assertion failed"); }

sealed class Harness : IDisposable
{
    public DateTimeOffset Start { get; } = DateTimeOffset.Parse("2026-11-11T23:59:00Z");
    public DateTimeOffset Now;
    public TimeZoneInfo Zone = TimeZoneInfo.Utc;
    private readonly string directory = Path.Combine(Path.GetTempPath(), "Tipoff-App-Tests-" + Guid.NewGuid());
    public ScheduleCache Cache { get; }
    public FakeProvider Provider { get; }
    public MainViewModel Model { get; }
    public Harness()
    {
        Now = Start;
        Cache = new(directory);
        Provider = new(this);
        Model = new(Provider, Cache, () => Now, () => Zone);
    }
    public ScheduleSnapshot Snapshot(IReadOnlyList<Game>? games = null) => new(games ?? [], Start, Dates.Key(DateOnly.FromDateTime(Now.DateTime)), Zone.Id, "test", false, ScheduleGuide.Nba);
    public Game Game(bool saved) => new("nba-1", "Celtics", "Nuggets", "BOS", "DEN", Start, "2026-11-11", null, [], new(null, null, ["Altitude"], ["Regional note"], Start, saved));
    public void Dispose() { Model.Dispose(); if (Directory.Exists(directory)) Directory.Delete(directory, true); }
}
sealed class FakeProvider(Harness h) : IScheduleLoading
{
    public bool Fail;
    public int Calls;
    public IReadOnlyList<Game> Games = [];
    public Task<ScheduleSnapshot>? Pending;
    public Task<ScheduleSnapshot> LoadAsync(DateOnly day, TimeZoneInfo zone, ScheduleGuide guide, CancellationToken cancellationToken = default)
    {
        Calls++;
        if (Pending is not null) return Pending;
        if (Fail) throw new IOException("offline");
        return Task.FromResult(new ScheduleSnapshot(Games, h.Now, Dates.Key(day), zone.Id, "test-" + guide, false, guide));
    }
}

static class NativeCardCheck
{
    public static void Run()
    {
        using var window = new MainWindow();
        static IEnumerable<DependencyObject> Descendants(DependencyObject root)
        {
            yield return root;
            foreach (var child in LogicalTreeHelper.GetChildren(root).OfType<DependencyObject>())
                foreach (var item in Descendants(child)) yield return item;
        }
        var items = Descendants(window).OfType<System.Windows.Controls.ItemsControl>().Single();
        using var h = new Harness();
        foreach (var theme in new[] { "Light", "Dark" })
        {
            var card = (System.Windows.Controls.Border)items.ItemTemplate.LoadContent();
            card.Resources.MergedDictionaries.Add(new ResourceDictionary
            {
                Source = new Uri($"/Tipoff;component/Themes/{theme}.xaml", UriKind.Relative)
            });
            card.DataContext = GameCard.From(h.Game(false), h.Zone, h.Now);
            card.Dispatcher.Invoke(() => { }, System.Windows.Threading.DispatcherPriority.DataBind);
            if (!Equals(card.BorderBrush, card.FindResource("MintBrush"))) throw new Exception(theme + " preferred outline");
            card.DataContext = GameCard.From(h.Game(false) with { HomeCode = "BOS" }, h.Zone, h.Now);
            card.Dispatcher.Invoke(() => { }, System.Windows.Threading.DispatcherPriority.DataBind);
            if (!Equals(card.BorderBrush, card.FindResource("CardBorderBrush"))) throw new Exception(theme + " ordinary outline");
        }
    }
}
