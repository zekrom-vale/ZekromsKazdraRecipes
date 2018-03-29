$prev= Get-Content prevVal.txt
$val= "apex, avian, floran, glitch, human, hylotl, novakid"
$item = Get-ChildItem . *.json.patch -rec
foreach ($file in $item){
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace $prev, $val } |
    Set-Content $file.PSPath
}
$val| Set-Content 'prevVal.txt'

$prev= Get-Content prevVal2.txt
$val= "apex, avian, human, hylotl"
foreach ($file in $item){
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace $prev, $val } |
    Set-Content $file.PSPath
}
$val| Set-Content 'prevVal2.txt'