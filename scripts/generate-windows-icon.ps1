param(
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\Windows\Tipoff.App\Tipoff.ico')
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

function New-BasketballPng([int]$Size) {
    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $stream = [System.IO.MemoryStream]::new()
    try {
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $dark = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 32, 37, 38))
        try {
            # Adapted from Google Material Icons' sports_basketball geometry.
            # Crop its 2...22 optical bounds so the ball reaches the canvas edges.
            $scale = [single]($Size / 20.0)
            $transform = [System.Drawing.Drawing2D.Matrix]::new($scale, 0, 0, $scale, -2 * $scale, -2 * $scale)
            $graphics.Transform = $transform
            $paths = [System.Collections.Generic.List[System.Drawing.Drawing2D.GraphicsPath]]::new()

            $path = [System.Drawing.Drawing2D.GraphicsPath]::new(); $path.AddLine(17.09,11,21.95,11); $path.AddBezier(21.95,11,21.79,9.39,21.24,7.89,20.41,6.6); $path.AddBezier(20.41,6.6,18.68,7.43,17.42,9.05,17.09,11); $path.CloseFigure(); $paths.Add($path)
            $path = [System.Drawing.Drawing2D.GraphicsPath]::new(); $path.AddLine(6.91,11,2.05,11); $path.AddBezier(2.05,11,2.21,9.39,2.76,7.89,3.59,6.6); $path.AddBezier(3.59,6.6,5.32,7.43,6.58,9.05,6.91,11); $path.CloseFigure(); $paths.Add($path)
            $path = [System.Drawing.Drawing2D.GraphicsPath]::new(); $path.AddLine(15.07,11,13,11); $path.AddLine(13,11,13,2.05); $path.AddBezier(13,2.05,15.39,2.29,17.53,3.37,19.13,5); $path.AddBezier(19.13,5,16.95,6.21,15.39,8.41,15.07,11); $path.CloseFigure(); $paths.Add($path)
            $path = [System.Drawing.Drawing2D.GraphicsPath]::new(); $path.AddLine(8.93,11,11,11); $path.AddLine(11,11,11,2.05); $path.AddBezier(11,2.05,8.61,2.29,6.46,3.37,4.87,5); $path.AddBezier(4.87,5,7.05,6.21,8.61,8.41,8.93,11); $path.CloseFigure(); $paths.Add($path)
            $path = [System.Drawing.Drawing2D.GraphicsPath]::new(); $path.AddLine(15.07,13,13,13); $path.AddLine(13,13,13,21.95); $path.AddBezier(13,21.95,15.39,21.71,17.54,20.63,19.13,19); $path.AddBezier(19.13,19,16.95,17.79,15.39,15.59,15.07,13); $path.CloseFigure(); $paths.Add($path)
            $path = [System.Drawing.Drawing2D.GraphicsPath]::new(); $path.AddBezier(3.59,17.4,5.31,16.57,6.58,14.94,6.91,13); $path.AddLine(6.91,13,2.05,13); $path.AddBezier(2.05,13,2.21,14.61,2.76,16.11,3.59,17.4); $path.CloseFigure(); $paths.Add($path)
            $path = [System.Drawing.Drawing2D.GraphicsPath]::new(); $path.AddBezier(17.09,13,17.42,14.95,18.68,16.57,20.41,17.4); $path.AddBezier(20.41,17.4,21.24,16.11,21.79,14.61,21.95,13); $path.AddLine(21.95,13,17.09,13); $path.CloseFigure(); $paths.Add($path)
            $path = [System.Drawing.Drawing2D.GraphicsPath]::new(); $path.AddLine(8.93,13,11,13); $path.AddLine(11,13,11,21.95); $path.AddBezier(11,21.95,8.61,21.71,6.47,20.63,4.87,19); $path.AddBezier(4.87,19,7.05,17.79,8.61,15.59,8.93,13); $path.CloseFigure(); $paths.Add($path)

            foreach ($panel in $paths) { $graphics.FillPath($dark, $panel); $panel.Dispose() }
            $transform.Dispose()
        } finally { $dark.Dispose() }

        $bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
        return $stream.ToArray()
    } finally {
        $stream.Dispose()
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

$sizes = @(16, 20, 24, 32, 40, 48, 64, 128, 256)
$images = @($sizes | ForEach-Object { ,(New-BasketballPng $_) })
$output = [System.IO.Path]::GetFullPath($OutputPath)
$directory = [System.IO.Path]::GetDirectoryName($output)
[System.IO.Directory]::CreateDirectory($directory) | Out-Null
$file = [System.IO.File]::Create($output)
$writer = [System.IO.BinaryWriter]::new($file)
try {
    $writer.Write([uint16]0)
    $writer.Write([uint16]1)
    $writer.Write([uint16]$sizes.Count)
    $offset = 6 + 16 * $sizes.Count
    for ($index = 0; $index -lt $sizes.Count; $index++) {
        $size = $sizes[$index]
        $writer.Write([byte]($(if ($size -eq 256) { 0 } else { $size })))
        $writer.Write([byte]($(if ($size -eq 256) { 0 } else { $size })))
        $writer.Write([byte]0)
        $writer.Write([byte]0)
        $writer.Write([uint16]1)
        $writer.Write([uint16]32)
        $writer.Write([uint32]$images[$index].Length)
        $writer.Write([uint32]$offset)
        $offset += $images[$index].Length
    }
    foreach ($image in $images) { $writer.Write([byte[]]$image) }
} finally {
    $writer.Dispose()
    $file.Dispose()
}

Write-Output "Generated $output"
