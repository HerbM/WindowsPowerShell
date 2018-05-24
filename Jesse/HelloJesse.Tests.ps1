pushd .
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

. "$here\$sut"
<#
describe string    {
test1
test2
}
describe is a pester runner
"it" blocks
should  is a pester test command
-Be is a parameter

#>

Describe "Pester Describe with one test" {
  It "Should say 'Hello Jesse'" {
    Hello Jesse              | Should -Be 'Hello Jesse'
  }  
}

Describe "Jesse's first test" {
  It "Should say 'Hello Jesse'" {
    Hello Jesse              | Should -Be 'Hello Jesse'
  }  
  It "Should say 'Hello Herb'" {
    Hello Herb               | Should -Be 'Hello Herb'
  }  
  It "Should say 'Hello World'" {
    Hello World              | Should -Be 'Hello World'
  }  
  It "Should say 'Hello World by default'" {
    Hello                    | Should -Be 'Hello World'
  }  
  It "Should say 'Hello Terri'" {
    Hello Terri              | Should -Be 'Hello Terri'
  }
  ForEach ($Name in 'Herb','Jesse', 'Carol','Terri', 'Fred', 'Ethyl') {  
    It "Should say 'Hello $Name'" {
      Hello $Name            | Should -Be "Hello $Name"
    }  
  }  
  $testCases = @(   # Another way to test: array of hashes with: input params & result
    @{ Name = 'Fred'  ; expectedResult = 'Hello Fred'   }
    @{ Name = 'Wilma' ; expectedResult = 'Hello Wilma'  }
    @{ Name = 'Barney'; expectedResult = 'Hello Barney' }
    @{ Name = 'Betty' ; expectedResult = 'Hello Betty'  }
  )
  It 'Say Hello to <Name> with result: <expectedResult>' -TestCases $testCases {
    param ($Name, $expectedResult)
    Hello $Name              | Should -Be $ExpectedResult
  }  
}