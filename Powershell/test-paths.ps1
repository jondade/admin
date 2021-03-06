#
# Test Paths
#    Splits down a path fed as a string and tests for child items.
#
#  Todo
#  1: Add testing with alternate user via invoke-command and credentials
#  2: Functionise the path test to use naked and in invoke-command.
##############################################################################################

$paths = "$env:PATH_TO_TEST".split("\")
test-path -path "${env:PATH_TO_TEST}" -ErrorVariable +logging -ErrorAction continue
$pathtotest = ""
foreach( $path in $paths ){
  if($path.Length -gt 0){
    $pathtotest += "$path\";
    get-childitem $pathtotest -ErrorVariable +logging -ErrorAction continue | write-output;
    get-acl -Path $pathtotest -ErrorVariable +logging -ErrorAction continue | write-output;
  }
}

invoke-command -scriptblock{
    