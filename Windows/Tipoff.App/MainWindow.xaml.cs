using System.Windows;
using System.Windows.Controls;
using System.Windows.Threading;
using Tipoff.Core;

namespace Tipoff.App;

public partial class MainWindow : Window, IDisposable
{
    private readonly MainViewModel viewModel = new();
    private readonly DispatcherTimer clock;
    private DateTimeOffset ignoreDeactivationUntil;
    private bool allowClose;
    public bool AutoHide { get; set; } = true;

    public MainWindow()
    {
        InitializeComponent();
        DataContext = viewModel;
        clock = new DispatcherTimer { Interval = TimeSpan.FromMinutes(1) };
        clock.Tick += (_, _) => viewModel.UpdateRelativeTime();
        clock.Start();
        Loaded += (_, _) => UpdateGuideButtons();
        SizeChanged += (_, _) => { if (IsVisible) PositionNearTaskbar(); };
    }

    public Task OpenedAsync() => viewModel.OpenedAsync();
    public Task RefreshAsync() => viewModel.RefreshAsync();

    public void ShowNearTaskbar()
    {
        ignoreDeactivationUntil = DateTimeOffset.UtcNow.AddSeconds(1);
        Show();
        UpdateLayout();
        PositionNearTaskbar();
    }

    private void PositionNearTaskbar()
    {
        var workArea = SystemParameters.WorkArea;
        Left = Math.Max(workArea.Left + 8, workArea.Right - ActualWidth - 10);
        Top = Math.Max(workArea.Top + 8, workArea.Bottom - ActualHeight - 10);
    }

    private async void Guide_Click(object sender, RoutedEventArgs e)
    {
        if (sender is System.Windows.Controls.Button { Tag: string value } && Enum.TryParse<ScheduleGuide>(value, out var guide))
        {
            var selection = viewModel.SelectGuideAsync(guide);
            UpdateGuideButtons();
            await selection;
            UpdateGuideButtons();
        }
    }

    private void UpdateGuideButtons()
    {
        foreach (var button in new[] { NbaButton, NflButton, WnbaButton, NhlButton, MlbButton })
        {
            var selected = string.Equals(button.Tag?.ToString(), viewModel.Guide.ToString(), StringComparison.OrdinalIgnoreCase);
            button.SetResourceReference(BackgroundProperty, selected ? "SelectedBrush" : "ButtonBrush");
            button.SetResourceReference(BorderBrushProperty, selected ? "SelectedBorderBrush" : "ButtonBorderBrush");
            button.SetResourceReference(ForegroundProperty, selected ? "SelectedTextBrush" : "TextBrush");
            button.FontWeight = selected ? FontWeights.SemiBold : FontWeights.Normal;
        }
    }

    private async void Previous_Click(object sender, RoutedEventArgs e) => await viewModel.MoveDayAsync(-1);
    private async void Next_Click(object sender, RoutedEventArgs e) => await viewModel.MoveDayAsync(1);
    private async void Jump_Click(object sender, RoutedEventArgs e) => await viewModel.JumpAsync();
    private async void Refresh_Click(object sender, RoutedEventArgs e) => await viewModel.RefreshAsync();
    private void Quit_Click(object sender, RoutedEventArgs e) => RequestQuit();
    private void Settings_Click(object sender, RoutedEventArgs e) => ((App)System.Windows.Application.Current).ShowSettings();
    private void Window_Deactivated(object sender, EventArgs e)
    {
        if (AutoHide && DateTimeOffset.UtcNow >= ignoreDeactivationUntil) Hide();
    }

    protected override void OnClosing(System.ComponentModel.CancelEventArgs e)
    {
        if (allowClose) return;
        e.Cancel = true;
        Hide();
    }

    public void RequestQuit()
    {
        allowClose = true;
        System.Windows.Application.Current.Shutdown();
    }

    public void Dispose()
    {
        clock.Stop();
        viewModel.Dispose();
    }
}
