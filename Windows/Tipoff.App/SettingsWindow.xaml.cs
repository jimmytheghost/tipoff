using System.Diagnostics;
using System.Reflection;
using System.Windows;
using System.Windows.Media;
using Color = System.Windows.Media.Color;

namespace Tipoff.App;

public partial class SettingsWindow : Window
{
    public SettingsWindow()
    {
        InitializeComponent();
        var version = Assembly.GetExecutingAssembly().GetName().Version;
        VersionLabel.Text = $"Version {version?.ToString(3)} · Windows";
        Activated += (_, _) => ReadStartup();
        ReadStartup();
    }

    private void ReadStartup()
    {
        try
        {
            var enabled = StartupRegistration.IsEnabled;
            StartupCheckBox.IsChecked = enabled;
            StartupCheckBox.IsEnabled = true;
            SetStatus(enabled ? "Registered to start this copy at sign-in." : "This copy is not registered to start at sign-in.");
        }
        catch (Exception error)
        {
            StartupCheckBox.IsChecked = false;
            StartupCheckBox.IsEnabled = false;
            SetStatus($"Could not read startup settings: {error.Message}", true);
        }
    }

    private void Startup_Click(object sender, RoutedEventArgs e)
    {
        try
        {
            StartupRegistration.SetEnabled(StartupCheckBox.IsChecked == true);
            ReadStartup();
        }
        catch (Exception error)
        {
            ReadStartup();
            SetStatus($"Could not update startup settings: {error.Message}", true);
        }
    }

    private void WindowsStartup_Click(object sender, RoutedEventArgs e)
    {
        try { Process.Start(new ProcessStartInfo("ms-settings:startupapps") { UseShellExecute = true }); }
        catch (Exception error) { SetStatus($"Could not open Windows settings: {error.Message}", true); }
    }

    private void SetStatus(string message, bool error = false)
    {
        StartupStatus.Text = message;
        StartupStatus.Foreground = new SolidColorBrush(error ? Color.FromRgb(138, 90, 0) : Color.FromRgb(8, 127, 91));
    }

    private void Done_Click(object sender, RoutedEventArgs e) => Close();
}
