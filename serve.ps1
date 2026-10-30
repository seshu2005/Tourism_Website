param (
    [int]$Port = 8080
)

$Folder = Join-Path $PSScriptRoot "tourism-website-main (1)\tourism-website-main"

if (-not (Test-Path $Folder)) {
    Write-Error "Could not find folder: $Folder"
    exit 1
}

$Listener = New-Object System.Net.HttpListener
$Listener.Prefixes.Add("http://localhost:$Port/")
$Listener.Start()

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Adventure Tourism Website Server" -ForegroundColor Green
Write-Host " Serving at: http://localhost:$Port/" -ForegroundColor Yellow
Write-Host " Press Ctrl+C in this terminal to stop." -ForegroundColor Gray
Write-Host "==========================================" -ForegroundColor Cyan

Start-Process "http://localhost:$Port/"

try {
    while ($Listener.IsListening) {
        $Context = $Listener.GetContext()
        $Request = $Context.Request
        $Response = $Context.Response

        $LocalPath = $Request.Url.LocalPath.TrimStart('/')
        if ([string]::IsNullOrEmpty($LocalPath) -or $LocalPath -eq "/") { 
            $LocalPath = "index.html" 
        }

        $FilePath = Join-Path $Folder $LocalPath

        if (Test-Path $FilePath -PathType Leaf) {
            $Bytes = [System.IO.File]::ReadAllBytes($FilePath)
            $Ext = [System.IO.Path]::GetExtension($FilePath).ToLower()
            $Mime = switch ($Ext) {
                '.html' { 'text/html; charset=utf-8' }
                '.css'  { 'text/css' }
                '.js'   { 'application/javascript' }
                '.png'  { 'image/png' }
                '.jpg'  { 'image/jpeg' }
                '.jpeg' { 'image/jpeg' }
                '.jfif' { 'image/jpeg' }
                '.ico'  { 'image/x-icon' }
                '.json' { 'application/json' }
                '.webmanifest' { 'application/manifest+json' }
                default { 'application/octet-stream' }
            }
            $Response.ContentType = $Mime
            $Response.ContentLength64 = $Bytes.Length
            $Response.OutputStream.Write($Bytes, 0, $Bytes.Length)
        } else {
            $Response.StatusCode = 404
            $NotFoundBytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $Response.ContentLength64 = $NotFoundBytes.Length
            $Response.OutputStream.Write($NotFoundBytes, 0, $NotFoundBytes.Length)
        }
        $Response.Close()
    }
}
finally {
    $Listener.Stop()
}

