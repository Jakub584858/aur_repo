# CleanAndAdd.ps1
$RepoPath = "./x86_64"

Write-Host "--- Rozpoczynam porządki w repozytorium ---" -ForegroundColor Cyan

# 1. Usuwanie fizyczne plików debug
Write-Host "Usuwanie plików *-debug-*" -ForegroundColor Yellow
Get-ChildItem -Path $RepoPath -Filter "*-debug-*" -Recurse | Remove-Item -Force -ErrorAction SilentlyContinue

# 2. Usuwanie starych wersji (zostawiamy 2 najnowsze)
$Files = Get-ChildItem -Path $RepoPath -Filter "*.pkg.tar.zst"
$Groups = $Files | Group-Object { $_.Name -replace '-[0-9].*', '' }

foreach ($Group in $Groups) {
    if ($Group.Count -gt 2) {
        $ToDelete = $Group.Group | Sort-Object LastWriteTime -Descending | Select-Object -Skip 2
        foreach ($File in $ToDelete) {
            Write-Host "Usuwanie starej wersji: $($File.Name)"
            Remove-Item $File.FullName -Force
        }
    }
}

# 3. Przebudowa bazy danych (tylko z tego co zostało)
Write-Host "Aktualizacja bazy aur_repo.db..." -ForegroundColor Green
# Używamy repo-add (dostępne w kontenerze Arch)
$Packs = Get-ChildItem -Path $RepoPath -Filter "*.pkg.tar.zst" | ForEach-Object { $_.FullName }
if ($Packs) {
    & repo-add "$RepoPath/aur_repo.db.tar.gz" $Packs
}
