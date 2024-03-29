$Y = { 
  param($f) { 
    param($x)
    $f.InvokeReturnAsIs({
      param ($y)
      $x.InvokeReturnAsIs($x).InvokeReturnAsIs($y)
    }.GetNewClosure())
  }.InvokeReturnAsIs({
    param($x)
    $f.InvokeReturnAsIs({
      param($y)
      $x.InvokeReturnAsIs($x).InvokeReturnAsIs($y)
    }.GetNewClosure())
  }.GetNewClosure())
}
 
$fact = {
  param($f){
    param($n)
    if ($n -eq 0) { 1 } else { $n * $f.InvokeReturnAsIs($n - 1) }
  }.GetNewClosure()
}
 
$fib = { param($f){
    param ($n)
    if ($n -lt 2) { 1 } else { $f.InvokeReturnAsIs($n - 1) + $f.InvokeReturnAsIs($n - 2) }
  }.GetNewClosure()
}

$countList = { 
  param ($f){ 
    param($n)
    If (!$n) { 0 } else { $null, $n = $n; 1 + $f.InvokeReturnAsIs($n) }
  }.GetNewClosure
} 
$Y.invoke($countList).invoke(@(2,3,4,5))
$Y.invoke($fact).invoke(5)
$Y.invoke($fib).invoke(5)
