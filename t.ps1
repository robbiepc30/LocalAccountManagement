function t {
    $a = "test" | Where-Object {"A"}
    $b = Write-Output -InputObject '{"a"}'
    $a
}
