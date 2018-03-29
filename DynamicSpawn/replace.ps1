$prev= Get-Content prevVal.txt
$val= Read-Host 'New Value'
$item = Get-ChildItem . *.json.patch -rec
foreach ($file in $item){
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace $prev, $val } |
    Set-Content $file.PSPath
}
$val| Set-Content 'prevVal.txt'

$prev= Get-Content prevVal2.txt
$val= Read-Host 'Second New Value'
foreach ($file in $item){
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace $prev, $val } |
    Set-Content $file.PSPath
}
$val| Set-Content 'prevVal2.txt'