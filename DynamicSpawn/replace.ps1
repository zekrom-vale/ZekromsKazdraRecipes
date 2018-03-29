Write-Output "Ignores vanilla defaults"
Write-Output 'Default: "apex, avian, floran, glitch, human, hylotl, novakid"'
$prev= Get-Content prevVal.txt
$val= Read-Host 'New Value'
$val= "apex, avian, floran, glitch, human, hylotl, novakid, $($val)"
$item = Get-ChildItem . *.json.patch -rec
foreach ($file in $item){
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace $prev, $val } |
    Set-Content $file.PSPath
}
$val| Set-Content 'prevVal.txt'

Write-Output 'Default: "apex, avian, human, hylotl"'
$prev= Get-Content prevVal2.txt
$val= Read-Host 'Second New Value'
$val= "apex, avian, human, hylotl, $($val)"
foreach ($file in $item){
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace $prev, $val } |
    Set-Content $file.PSPath
}
$val| Set-Content 'prevVal2.txt'