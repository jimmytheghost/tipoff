using System.Diagnostics;
using System.Reflection;
using System.Windows;

namespace Tipoff.App;

public partial class SettingsWindow : Window
{
    private bool appearanceReady;
    public SettingsWindow()
    {
        InitializeComponent();
        var version = Assembly.GetExecutingAssembly().GetName().Version;
        VersionLabel.Text = $"Version {version?.ToString(3)} · Windows";
        LightOption.IsChecked = AppearanceSettings.Current == "Light";
        DarkOption.IsChecked = AppearanceSettings.Current == "Dark";
        appearanceReady = true;
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
        StartupStatus.SetResourceReference(System.Windows.Controls.TextBlock.ForegroundProperty, error ? "WarningBrush" : "MintBrush");
    }

    private void Appearance_Checked(object sender, RoutedEventArgs e)
    {
        if (!appearanceReady || sender is not System.Windows.Controls.RadioButton { Tag: string appearance }) return;
        try
        {
            AppearanceSettings.Set(appearance);
            AppearanceError.Visibility = Visibility.Collapsed;
        }
        catch (Exception error)
        {
            appearanceReady = false;
            LightOption.IsChecked = AppearanceSettings.Current == "Light";
            DarkOption.IsChecked = AppearanceSettings.Current == "Dark";
            appearanceReady = true;
            AppearanceError.Text = $"Could not save appearance: {error.Message}";
            AppearanceError.Visibility = Visibility.Visible;
        }
    }

    private void Done_Click(object sender, RoutedEventArgs e) => Close();
}
