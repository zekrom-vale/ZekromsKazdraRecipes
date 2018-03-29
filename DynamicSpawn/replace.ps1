$val= Read-Host 'Value'
$item = Get-ChildItem . *.json.patch -rec
foreach ($file in $item)
{
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace '"value": "human,apex,avian,hylotl,floran,glitch,kazdra"', $val } |
    Set-Content $file.PSPath
}