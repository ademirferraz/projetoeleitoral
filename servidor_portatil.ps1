# Servidor HTTP portátil para o App Eleitoral
# Basta dar duplo clique ou executar no PowerShell

$porta = 8080
$dir = Join-Path $PSScriptRoot "build\web"

if (-not (Test-Path $dir)) {
    Write-Host "ERRO: Pasta build\web não encontrada." -ForegroundColor Red
    Write-Host "Execute primeiro: flutter build web" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "===================================" -ForegroundColor Green
Write-Host " App Eleitoral - Servidor Portátil" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host "URL: http://localhost:$porta" -ForegroundColor Cyan
Write-Host "Pressione CTRL+C para parar." -ForegroundColor Yellow
Write-Host ""

# Tenta Python, depois Node, depois .NET
if (Get-Command "python" -ErrorAction SilentlyContinue) {
    python -m http.server $porta --directory $dir
} elseif (Get-Command "npx" -ErrorAction SilentlyContinue) {
    npx serve $dir -p $porta
} else {
    # Fallback: cria um servidor básico em .NET
    $assembly = @"
using System;
using System.IO;
using System.Net;
using System.Text.RegularExpressions;

class Servidor {
    static void Main() {
        var prefixo = "http://localhost:$porta/";
        var http = new HttpListener();
        http.Prefixes.Add(prefixo);
        http.Start();
        Console.WriteLine("Servidor rodando em " + prefixo);
        while (true) {
            var ctx = http.GetContext();
            var req = ctx.Request;
            var path = req.Url.LocalPath.TrimStart('/');
            if (string.IsNullOrEmpty(path)) path = "index.html";
            path = Path.Combine(@"$($dir.Replace('\','\\'))", path);
            if (File.Exists(path)) {
                var ext = Path.GetExtension(path);
                var map = new[] {
                    Tuple.Create(".html", "text/html"),
                    Tuple.Create(".js", "application/javascript"),
                    Tuple.Create(".css", "text/css"),
                    Tuple.Create(".png", "image/png"),
                    Tuple.Create(".wasm", "application/wasm"),
                };
                var mime = "application/octet-stream";
                foreach (var x in map) { if (ext == x.Item1) { mime = x.Item2; break; } }
                ctx.Response.ContentType = mime;
                ctx.Response.OutputStream.Write(File.ReadAllBytes(path), 0, (int)new FileInfo(path).Length);
            } else {
                ctx.Response.StatusCode = 404;
            }
            ctx.Response.Close();
        }
    }
}
"@
    $exe = Join-Path $env:TEMP "servidor_app.exe"
    Add-Type -TypeDefinition $assembly -Language CSharp -OutputAssembly $exe
    & $exe
}
