# =====================================================================
# PolyFlow - Deterministic test data generator
# Generates valid and invalid station records to stress-test the
# pipeline. Same seed -> same file, so results are reproducible.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File tests\generar_datos.ps1 `
#       -Count 1000 -OutFile tests\datos_1000.csv
# Then copy the file over data\datos_crudos.csv to run the pipeline
# against the large dataset (keep a backup of the demo data or use
#   git checkout -- data\datos_crudos.csv
# to restore it afterwards).
# =====================================================================

param(
    [int]$Count = 1000,
    [string]$OutFile = "tests\datos_1000.csv"
)

$stations = 1..40 | ForEach-Object { "ST{0:D2}" -f $_ }

# Deterministic, good-quality PRNG (same seed -> same file every run)
$null = Get-Random -SetSeed 42

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("ID,STATION,TEMPERATURE,PRECIPITATION,WIND,BATTERY")

for ($i = 1; $i -le $Count; $i++) {

    $id     = "D{0:D4}" -f $i
    $st     = $stations[(Get-Random -Minimum 0 -Maximum 40)]
    $temp   = [math]::Round((Get-Random -Minimum 150 -Maximum 450) / 10.0, 1)  # 15.0 .. 44.9
    $precip = Get-Random -Minimum 0 -Maximum 120                               # 0 .. 119
    $wind   = Get-Random -Minimum 0 -Maximum 80                                # 0 .. 79
    $bat    = Get-Random -Minimum 20 -Maximum 95                               # 20 .. 94

    # Deterministic invalid records (~15% combined coverage):
    if ($i % 13 -eq 0) { $bat    = ""    }   # missing field
    if ($i % 17 -eq 0) { $temp   = 99.0  }   # temperature out of range
    if ($i % 19 -eq 0) { $precip = -3    }   # negative precipitation
    if ($i % 23 -eq 0) { $wind   = -2    }   # negative wind
    if ($i % 29 -eq 0) { $bat    = 250   }   # battery out of range
    if ($i % 31 -eq 0 -and $i -gt 1) { $id = "D{0:D4}" -f ($i - 1) }  # duplicate ID

    $lines.Add("$id,$st,$temp,$precip,$wind,$bat")
}

[System.IO.File]::WriteAllLines($OutFile, $lines)
Write-Output "Generated $($lines.Count - 1) records -> $OutFile"
