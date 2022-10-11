"[$([char][Convert]::ToUint32("20", 16))]"


$OwningProcessName = { (Get-Process -Id $_.OwningProcess).Name }

Get-NetTCPConnection | Select-Object -Property State, LocalAddress, LocalPort, @{N='ProcessName'; E=$OwningProcessName}
# Get-NetTCPConnection cmdlet and it turns out there is a similar one for UDP:  Get-NetUDPEndpoint
# A similar result can be built for bound UDP services:
Get-NetUDPEndpoint | Select-Object -Property LocalAddress, LocalPort, OwningProcess, @{N='ProcessName'; E=$OwningProcessName}



Function Write-Pyramid {
  Param(
    [UInt][ValidateRange(1,9)]$Maximum = 9
  )
  $Spacing = ' '
  $MaxWidth = $Maximum + ($Maximum - 1)
  ForEach ($N in 1..$Maximum) {
    $Line = (@(@($N) * $N) -join $Spacing)
    ' ' * (($MaxWidth - $Line.Length) / 2) + $Line
  }
}

Write-Pyramid


ForEach ($N in 0..8) {
  ForEach ($K in 0..($N)) {
    $Choose = NchooseK $N $K
    Write-Host "$Choose " -nonewline
  }
  Write-Host
}

Function Fact {
  Param($N)
  $Y = 1
  If ($N -gt 1) {
    ForEach ($X in (1..$N)) {
      $Y = $Y * $X
    }
  }
  $Y
}

Function NchooseK {
  Param(
    $N,
    $K
  )
  (Fact $N) / ((Fact $K) * (Fact ($N - $K)))
}


# Mandelbrot Set
$x = $y = $i = $j = $r = 99
$y = -16
$colors = [Enum]::GetValues([System.ConsoleColor])
while(($y++) -lt 15) {
  for($x=0; ($x++) -lt 84; Write-Host " " -BackgroundColor ($colors[$k -band 15]) -NoNewline) {
    $i = $k = $r = 0
    do {
      $j = $r * $r - $i * $i -2 + $x / 25
      $i = 2 * $r * $i + $y / 10
      $r = $j
    } while (($j * $j + $i * $i) -lt 11 -band ($k++) -lt 111)
  }
  Write-Host
}

# Mandelbrot Set
$x = $y = $i = $j = $r = 99
$y = -16
$colors = [Enum]::GetValues([System.ConsoleColor])
while(($y++) -lt 15) {
  $Line = ''
  for($x=0; ($x++) -lt 84; Write-Host " " -BackgroundColor ($colors[$k -band 15]) -NoNewline) {
    $i = $k = $r = 0
    do {
      $j = $r * $r - $i * $i -2 + $x / 25
      $i = 2 * $r * $i + $y / 10
      $r = $j
    } while (($j * $j + $i * $i) -lt 11 -band ($k++) -lt 111)
  }
  Write-Host
}


<#
Transducers (video) Strange Loop Sep 2014 by Rich Hickey
  Introduction to Functional Programming with Clojure Michiel Borkat Dutch -> English
    https://www-michielborkent-nl.translate.goog/clojurecursus/dictaat.html?_x_tr_sl=nl&_x_tr_tl=en&_x_tr_hl=en-US&_x_tr_pto=nui
  Lectures on Constructive Functional Programming  by R.S. Bird
    Lectures on Constructive Functional Programming  by R.S. Bird-PRG69.pdf
  A tutorial the universality and expressiveness of Fold  Graham Hutton
    https://swizec.com/blog/week-15-a-tutorial-on-the-expressiveness-and-universality-of-fold/

I wrote the first Patterns -- CoPilot suggested the rest of each pattern:
  Much of what Rich Hickey offers in his talk, we can use | in our own programs.
  Much of what Rich Hickey offers in his talk, | you can do with the .NET framework.
  Much of what Rich Hickey offers in his talk, | he also writes in his book.
  Much of what Rich Hickey offers in his talk, | is a pattern language that is very similar to the Lisp programming language.
  Much of what Rich Hickey offers in his talk, PowerShell | can be used to implement.
  Much of what Rich Hickey offers in his talk | is already implemented in the .NET framework.
  Much of what Rich Hickey offers in his talk | is a good example of how to use the PowerShell language.

Getting Clojure Pragmatic Bookshelf Russ Olsen 2018
Functional Thinking: Paradigm Over Syntax O'Reilly Media Neal Ford 2014
Land of Lisp: Learn to Program in Lisp, One Game at a Time! No Starch Press Conrad Barski M.D. 2010
Presentation Patterns: Techniques for Crafting Better Presentations Neal Ford, Matthew McCullough, Nathaniel Schutta 2012 Addison-Wesley Professional
  ..A select few include Rich Hickey,2 Martin Fowler,3 and Kent Beck.4 In the legal space, that same position is held by Lawrence Lessig.5 In the arts, Ralph...
Grokking Simplicity: Taming complex software with functional thinking Manning Publications Eric Normand  2021
Code That Fits in Your Head: Heuristics for Software Engineering Addison-Wesley Professional Mark Seemann 2021
Functional Design and Architecture leanpub.com Alexander Granin 2021
Architecture Patterns with Python O'Reilly Media, Inc. Bob Gregory & Harry Percival [Bob Gregory]
Release It!: Design and Deploy Production-Ready Software, 2nd Edition Pragmatic Bookshelf Michael T. Nygard [Nygard, Michael T.]

Inspired by the 180 websites I will understand 52 papers in 52 weeks site:swizec.com
  https://swizec.com/blog/inspired-by-the-180-websites-i-will-understand-52-academic-papers-in-52-weeks/

Algorithm Design with Haskell Richard Bird, Jeremy Gibbons
  https://www.haskell.org/haskellwiki/Algorithm_design_with_Haskell
  Also video Chalmers Functional Programming seminar 2020
  Programs are values, not commands.
  Equational reasoning (is a programming paradigm)
  efficient implentations from clear specifications <----
  simplicity (no GADTs, Monads Traversables...)
  thinning -- algorithm novelty  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<---
    foldr, fusion law for foldr
Functional vs. Array Strange Loop 2021 Conor Hoekstra @code_report APL & J

Combinatory Logic Curry/Feys and Combinator Birds APL SK Combinators
to Mock a Mockingbird and other logic puzzles Raymond Smulyan
  Composition patterns


UNIX: A History and a Memoir Brian Kernighan
Software Tools In Pascal
Programming Pearls Addison Wesley Jon Louis Bentley 1986
More Programming Pearls: Confessions of a Coder Jon Louis Bentley 1988
Higher-order Perl : a guide to program transformation Morgan Kaufmann Publishers Mark Jason Dominus 2005

PAIP
Starting Forth
Thinking Functionally in Haskell

Practical Common Apress Lisp Peter Seibel 2005
Lisp for the Web leanpub.com Adam Tornhill  2014
Coders at Work: Reflections on the Craft of Programming Apress Peter Seibel 2009
Modern Perl Pragmatic Bookshelf chromatic 2015
Effective Perl, C++ etc.
The Problem With Software: Why Smart Engineers Write Bad Code MIT Press Adam Barr 2018

Python Wise Head Junior
Analysis Patterns: Reusable Object Models
Use Case Driven Object Modeling with UML Theory and Practice by Doug Rosenberg, Matt Stephens (z-lib.org).pdf

Domain-Driven Design: Tackling Complexity in the Heart of Software Eric Evans
Object Oriented Software Construction

BOOKS:
Design Pattens Beck Gamma
Design Patterns in .NET Core 3: Reusable Approaches in C# and F# for Object-Oriented Software Design
  Dmitri Nesteruk 2021
TypeScript 4 Design Patterns and Best Practices Discover effective techniques and design patterns for every programming task by Theo Despoudis (z-lib.org).epub.pdf
Designing Interfaces: Patterns for Effective Interaction Design
Hands-On Design Patterns with C# and .NET Core

PowerShell Fast Track: Hacks for Non-Coders
Cloud Defense Strategies with Azure Sentinel


AZURE
Exam Ref AZ-304 Microsoft Azure Architect Design Certification and Beyond: Design secure and reliable solutions for the real world in Microsoft Azure



Writing Effective Use Cases Alistair Cockburn
Design Patterns: Elements of Reusable Object-Oriented Software Erich Gamma, Richard Helm, Ralph Johnson, John M. Vlissides
Code Complete: A Practical Handbook of Software Construction by Gerald Weinberg
The Clean Coder: A Code of Conduct for Professional Programmers by Robert C. Martin
The Art of Computer Programming by Donald E. Knuth
The Pragmatic Programmer: From Journeyman to Master by Andrew Hunt and David Thomas
Core Techniques and Algorithms in Game Programming by Daniel Sanchez-Crespo Dalmau
Programming Games with Visual Basic: An Intermediate Step by Step Tutorial Philip Conrod & Lou Tylee
BASIC Game Plans: Computer Games and Puzzles Programmed in BASIC Rüdeger Baumann (auth.), Thomas S. Hansen, Donald Kahn (eds.) 1982
BASIC Computer Games: Microcomputer Edition David H. Ahl 1978
Games, Puzzles, and Computation Robert A. Hearn, Erik D. Demaine 2009
Game Development Patterns and Best Practices John P. Doran, Matt Casanova 2017
Pixel Art for Game Developers Daniel Silber 2015

Agile Technical Practices Distilled: A Journey Toward Mastering Software Design
  Pedro Moreira Santos, Marco Consolaro, Alessandro Di Gioia 2018
Programming Language Explorations (12 languages) Ray Toal, Rachel Rivera, Alexander Schneider, Eileen Choe 2017
Clojure Standard Library: An annotated reference MEAP V14 Renzo Borgatti and Nicola Mometto 2017
FunctionalProgramming\Functional Design and Architecture by Alexander Granin (z-lib.org).pdf 2021
Haskell in Depth 2021  Vitaly Bragilevsky
Good Code, Bad Code: Think like a software engineer Tom Long 2021
The Programmer's Brain: What every programmer needs to know about cognition Felienne Hermans 2021
Five Lines of Code: How and when to refactor
Engineer Your Software!
Grokking Simplicity: Taming complex software with functional thinking Manning Publications Eric Normand
Racket Programming the Fun Way 2021
Clean Craftsmanship Disciplines, Standards, and Ethics (Robert C. Martin Series) by Martin, Robert C. 2021
Python For Beginners A Practical Guide For The People Who Want to Learn Python The Right and Simple Way (Computer Programming Book 1) by Snowden, John (z-lib.org).epub.pdf 2021
Hackers & Painters Big Ideas from the Computer Age by Paul Graham

Systematic Program Design: From Clarity to Efficiency Professor Yanhong Annie Liu  2013
The Art of Coding-The Language of Drawing, Graphics, and Animation Chapman and Hall/CRC Mohammad Majid al-Rifaie (Author), Anna Ursyn (Author), Theodor Wyeld (Author) 2020
The little typer MIT Press Bibby, Duane, Christiansen, David Thrane, Friedman, Daniel P., Harper, Robert, McBride, Conor 2018
Software Architecture for Busy Developers: Talk and act like a software architect in one weekend
Microservices in .NET, 2nd Edition

Code That Fits in Your Head: Heuristics for Software Engineering
http://www.paulgraham.com/head.html Paul Graham, holiding programs in your head a more

**** Learn to earn Learn & earn freemote.com/strategy

Software Architecture for Busy Developers: Talk and act like a software architect in one weekend
Grady Booch Recommended: Continuous Architecture in Practice: Software Architecture in the Age of Agility and DevOps

> I love the idea of coding. I just don’t know where to start. I’m 15 and just want to code. What are the best languages to learn and what is easy for a teen with little money to their name?
Do you have reasonable access to a computer?
Or even a programmable calculator?
IF YES, then the simple answer is: START CODING.
What has stopped you so far?
If you have already started then a better question would have included your previous experience and current efforts.
If you don’t have access to a computer, OBTAIN that access. Work to buy something trivially cheap (by your standards) or to find a friend, family member, or program that will provide you that access.
Once you have a “love of programmng” AND access to a coding environment then JUST START.
To be clear, there are better and more effective methods to optimize your time and results, but that is not nearly as important as making progress.
Then ADD those optimizations by researching them — and by reseaching answer to the problems you encounter by writing code or more effective way to use your current language etc.
I am entirely self-taught (and rose to a highly respected professional level), but started on nothing more than an Apple II using Basic (a very OLD form of Basic.)
At the time, an Apple II was expensive, but compared to the CAPABILITIES of modern computers it is worth less than $5 (other than as a collector’s item.)
Presuming you have access to a Windows computer, start with PowerShell for these reasons:
1. It’s built-in
2. **A tiny amount of PowerShell is immediately useful** — a tiny or even small amount of most programming languages is seldom very useful.
3. **You need to learn it anyway to run your Windows computer** system (and it would be helpful on Linux or MacOS.)
4. It’s mostly a subset of C# and thus also similar to C/C++/Perl and to a lesser extent many other languages.
5. Every programmer on Windows should know PowerShell (and Linux folks would benefit by adopting it too) to support the work they do in their favorite language.
6. All DotNet languages benefit from know PowerShell since it is an INTERNACTIVE, command line interface to all of DOTNET (and much more)
7. It’s easy to start but sophisticated enough to allow you to learn much more advanced programming: **Object-Oriented, Functional Programming, Declarative Programming, Active Directory, WMI/CIM, Web Scraping/REST, Network, SQL database access**, and much more.
8. You can **write PROGRAMS in the same language you use DAILY** to “run your machine” (Stop using the GUI tools as much as possible.)
If you are not on a Windows computer, perhaps a ChromeBook then start in JavaScript.
1. It’s on practically every computers “in the browser”
2. You probably need to learn it eventually if you ever do “web site” development
3. It’s mostly a subset of C++ and thus also similar to C/C#/Perl and to a lesser extent many other languages.
4. It’s easy to start but sophisticated enough to allow you to learn much more advanced programming: Object-Oriented, Functional Programming, Declarative Programming, SQL database access, and much more.


Make your own Algorithmic Art. A gentle Introduction to creative Coding with P5js Tariq Rashid 2018
The Art of Algorithm Design Chapman and Hall/CRC Sachi Nandan Mohanty, Pabitra Kumar Tripathy, Suneeta Satpathy 2021
Flowchart and Algorithm Basics: The Art of Programming Mercury Learning & Information Chaudhuri, A. B. 2020
Art of Programming Contest: C Programming, Data Structures, Algorithms Gyankosh Prokashoni Ahmed Shamsul Arefin 2006
Python Playground: Geeky Projects for the Curious Programmer No Starch Press Mahesh Venkitachalam
Computer Science Illuminated (6th Edition) Nell dale and John Lewis  1016 pages
Algorithms for visual design using the Processing language Kostas Terzidis 2009
Retrogame Archeology: Exploring Old Computer Games Springer International Publishing John Aycock 2016
How debuggers work Wiley Jonathan B. Rosenberg 1996
Computer Graphics from Scratch Gabriel Gambetta 2021
Programming Languages Application and Interpretation it-ebooks 2nd Ed 2017
Programming Languages Lecture Notes (NEU CS4400) iBooker it-ebooks 2017

Framework Design Guidelines Conventions Idioms and Patterns  epub only????
Software Architecture with C++ Packt Publishing by Adrian Ostrowski & Piotr Gaczkowski [Adrian Ostrowski]
Programming: Principles and Practice Using C

Learning C# by Programming Games Springer Arjan Egges, Jeroen D. Fokker, Mark H. Overmars 2013
Learning C# by Programming Games by Wouter van Toll, Arjan Egges, et al. | Nov 21, 2019

Land of Lisp: Learn to Program in Lisp, One Game at a Time! No Starch Press  Conrad Barski 2010?
Realm of Racket: Learn to Program, One Game at a Time!  No Starch Press
  Matthias Felleisen, Conrad Barski M.D., David Van Horn, Eight Students Northeastern University of 2013

The Joy of JavaScript Manning Publications Atencio, Luis 2021
Magical Sentences -- Stories from Sentences

The PowerShell Practice Primer Jeff Hicks 2021
Programming for Beginners: Learn to Code by Making Little Games Tom Dalling 2015

The Absolutely Awesome Book on C# and .NET DotNetCurry / A2Z Knowledge Visuals Pvt Ltd. Damir Arh

Leo Brody cartoons/Beginner book, humorous, one clear idea at a time.
  Thinking Forth: encapsulation, refactoring (Chuck Moore)
Processing: Creative Coding and Computational Art Ira Greenberg 2007

How to Design Programs
  'D:\Books\new\How to Design Programs An Introduction to Programming and Computing by Matthias Felleisen (z-lib.org).pdf'
  D:\Books\Scheme\HowToDesignPrograms.pdf
  D:\Books\In\Your Code as a Crime Scene Use Forensic Techniques to Arrest Defects, Bottlenecks, and Bad Design in Your Programs by Adam Tornhill (z-lib.org).epub
  D:\Books\FunctionalProgramming\TheDesignOfFunctionalPrograms-ACalculationalApproach.pdf

  D:\books\haskell\functional-design-and-architecture.pdf
  D:\Books\Haskell\[Eric_Elliott]_Composing_Software(z-lib.org).pdf

Algorithms:
  The Algorithm Design Manual by Steven S. Skiena (z-lib.org).pdf
  D:/Books/Algorithms/0201120372%20%7B6AA3B752%7D%20Introduction%20to%20Algorithms_%20A%20Creative%20Approach%20[Manber%201989-01-11].pdf
    Introduction%20to%20Algorithms -- A Creative Approach (old but good) 198 Manber 1989
############################################################################################################################

learning programming using "deep practice" | "deliberate practice"
learning programming using "deep practice" | "deliberate practice"
learning programming using "deep practice" | "deliberate practice"
https://www.google.com/search?q=learning+programming+using+%22deep+practice%22+%7C+%22deliberate+practice%22&rlz=1C1CHBF_enUS921US921&oq=learning+programming+using+%22deep+practice%22+%7C+%22deliberate+practice%22&aqs=chrome..69i57.27303j0j4&sourceid=chrome&ie=UTF-8
https://www.google.com/search?q=learning+programming+using+%22deep+practice%22+%7C+%22deliberate+practice%22&rlz=1C1CHBF_enUS921US921&oq=learning+programming+using+%22deep+practice%22+%7C+%22deliberate+practice%22&aqs=chrome..69i57.27303j0j4&sourceid=chrome&ie=UTF-8
https://www.google.com/search?q=learning+programming+using+%22deep+practice%22+%7C+%22deliberate+practice%22&rlz=1C1CHBF_enUS921US921&oq=learning+programming+using+%22deep+practice%22+%7C+%22deliberate+practice%22&aqs=chrome..69i57.27303j0j4&sourceid=chrome&ie=UTF-8
https://www.google.com/search?q=learning+programming+using+%22deep+practice%22+%7C+%22deliberate+practice%22&rlz=1C1CHBF_enUS921US921&oq=learning+programming+using+%22deep+practice%22+%7C+%22deliberate+practice%22&aqs=chrome..69i57.27303j0j4&sourceid=chrome&ie=UTF-8

############################################################################################################################


Alertness AND Focuse with a sense of urgency  then don't think about it (Sleep) Huber on Plasticity NOW IT MAKES SENSE
This is also likely why peple can seldom improve actual intelligence.
Identify current ASSUMPTIONS
TOC, troubleshooting
Creativity like combine movable type with presses -- NLP creativity hack
Look where no one else is looking
Abandon FORM and optimize FUNCTION
Eyes laterally reduces agitation? Moving forward reduces depression???
500 Lines or Less or Less: Experienced programmers solve interesting problems
  -> Python Interpreter Written in Python (and more)

UCB CS61AS SICP with Racket

Logic Math logic
  D:\Books\In\Discrete Mathematics with Applications, Metric Version by Susanna S. Epp (z-lib.org).pdf
    Extremely good beginner book, logic
  D:\Books\In\Discrete Mathematical Structures Pearson New International Edition by Bernard Kolman, Robert C. Busby, Sharon Cutler Ross (z-lib.org).pdf 6TH ED
Proofs
  D:\Books\Mathematica\Pearson.Mathematical.Proofs.A.Transition.to.Advanced.Mathematics.3rd.Edition.0321797094.pdf
  D:\Books\newC\Academic.A.Transition.to.Abstract.Mathematics.2nd.Edition.0123744806.pdf
Pre-Algebra

D:\Books\Science\How To Solve Word Problems In Algebra by Johnson and Johnson 2nd Edition.pdf
The Humongous Book of Algebra Problems ????
Wacky word problems: games and activities that make math easy and fun
D:\Books\In\Master Essential Algebra Skills The Word Problems Collectiom Book With Answers Prealgebra Skills by Zin, Eva (z-lib.org).epub


cd C:\ZipFileRoot
dir -file *.zip -Recurse | ForEach-Object {
  $Dir  = $_.fullname
  $Name = $_.name
  cd -LiteralPath $Dir
  7z -y x $Name
}
The above will mostly work but it doesn’t have any serious error handling.

Notes:
  Get files ending in zips recursing subdirectories
  For Each file do the code in brackets
  Extract the Directory part
  Extract the filename part
  cd to Directory, using -literalpath in case there are weird characters
  7x x (extract) using -y to answer yes for overwriting duplicate files.
  You could do something more extrensive like creating a different subdirectory for each file etc.



For my part, I have about a dozen books that I consider absolutely essential to capture the key points and add them to anything produced by me.
“Software Tools in Pascal” (Kernighan & Plauger, “Paradigms of Artificial Intelligence: Case Studies in Common Lisp” (Norvig), perhaps “Thinking Functionally with Haskell” (Bird), “Higher Order PerlTransforming: Programs with Programs” (Dominus), “Starting Forth” (Brody), “The Structure and Interpretation of Computer Programs” (Abelson) Scheme-based but there now a JavaScript version I think.

Note: Despite every one of these books using a specific language to deliver the content, none of them are focused primarily on being a primary tutorial or reference for THAT language (except maybe “Starting Forth”).
They all are about “how to program” and “deveoping programmer excellence”.

I need to read this to determine if it belongs in the list aove: “Programming: Principles and Practice Using C++” (Stroustrup).

A few language specific books that are really good ON THE LANGUAGE don’t make this top dozen, but are in a 2nd tier. “The C++ Programming Language” (Stroustrup), “Programming Perl” (Wall), “Windows PowerShell in Action, 3rd Edition” (Payette & Siddaway”, MAYBE “The.Quick.Python.Book.3rd.Edition” (Ceder) or several other candidate,

I really don’t have superior Python, JavaScripts, Rust, C#, titles pinned down - work in progress.

If you have any ideas for any such categories please advise me.

There are also about 100 really good, but not classicly outstanding books, that I also consider very important. Right now your book(s) is in that category. There is much to extract from these that should be at least mentioned, given space and time.

My book will (likely) use PowerShell as is currently intended, but it’s not ABOUT PowerShell. It’s about become a programmer and developer, a troubleshooter and debugger, a designer and tester.

Conceivably I could switch the book to Python (I only learned Python this August) or JavaScript (where I am no expert and haven’t work much in almost 2 decades.)

Like though, to do those would mean doing a follow-up “translation” to the other programming language.

PowerShell is greatly undervalued and even dismissed, but it an amazingly productive language, and there are currently NO books on “how to become a programmer” using it as a vehicle, though quite a few on using the language itself that are of decent to excellent quality.

Most of the Python “How to Program” books are dreck, which is why your ideas stand out so much.



Corrected: The Forth book was “Thinking Forth” also by Brody and not the earlier “Starting Forth” I indicated above.

This is important because “Starting Forth” is only in the category of language reference or language tutorial, excellent but not in the category of books with ideas that change lives.

“Thinking Forth” describes a method of developing and philosophy of software construction that later became the norm. Brody says plainly that this methodology “has no name” EXCEPT “Forth”, which is merely the same name as the LANGUAGE but not the same THING.

At that time, few understood the value and effectiveness of designing with functions (or methods) and modules (or later objects) and then frameworks which offerred inoperating and support modules on a grand scale.
5

Structured Programming and Design is almost never “taught” today, and was only obtaining language support at that time to do the bookkeeping instead of making the programmer maintain the connections, functions, and modules mentally.
Structured Programming SHOULD be taught — even if we don’t call it that.
A programmer who cannot design and code quality “Functions” (Procedures, methods, commands, cmdlets, etc.) cannot assemble module from sets of functions and assemble programs from modules, or even assemble solutions from sets of programs.
One cannot be a “Functional Programmer” without being able to code a quality FUNCTION.
One cannot be an Object-Oriented Programmer without being able to code high quality Methods or Member Functions.
One cannot be a Module developer or an Event (windows) without being able to write quality functions to compose the module or supply the variety of even handlers needed.
Something as simple in concept as the Unix pipeline was a revolution in productivity and functionality based on nothing much more than treating “small programs” (cat, grep, sort, cut, wc, more/less, tr (anslate), tail, ps, etc.) as components to be developed and tested separately then plugged together like Legos, train cars, assembly lines, or other building blocks.
None of these programs need to KNOW about each other, they merely need to produce output to STDOUT and accept input from STDIN to be hooked together in almost infinite combinations with almost infinite utility.
Component based development is at the heart of (almost?) all of the successful higher layer programming methodologies including the idea of “Interfaces” and “REST/Web APIs”.
Amazon even calls their “serverless” functions ‘Lambdas’ which is the computer traditional computer science name for “anonymous functions” and Google simple calls their version “Google Functions”
All of DOTNET is assembled like this using a loose and simple object-oriented inheritance scheme of MULTIPLE almost disjoint component trees that interoperate smoothly without (much) coupling by using INTERFACES rather than inheritance as the meta-assembly model.
Your component doesn’t haveto be “my object type” to use my services, it only needs to implement the INTERFACES (functions) my service requires.
Complexity is the enemy for all but the most trivial programs.
Component based assembly (of any kind) is one of the most powerful models for building highly functional software with manageable complexity.


Programming for Beginners: Learn to Code by Making Little Games Tom Dalling 2015
  (Graphics Programming) However, the learning curve can be very steep and frustrating. The majority of programming books and tutorials are made for people who already know the basics. They are too advanced for true beginners – people who have never written any code before – which makes them difficult to absorb if you are just beginning to learn.

Sparse Estimation with Math and Python: 100 Exercises for Building Logic 2021
Data Science Bookcamp: Five real-world Python projects 2021
Python Brain Teasers: Exercise Your Mind Miki Tebeka 2021
Machine Learning Bookcamp: Build a portfolio of real-life projects (Final release) Grigorev, Alexey 2021
Learning Test-Driven Development: A Polyglot Guide to Writing Uncluttered Code 2021

Thanks for the kinds words, this portion in specific represents a great compliment,

“… I didn’t remember when I read anything such with such great insight. With a great mentor, students can cover their experience of 10 yrs in 10 minutes. I felt the same and i able to guess how much you create difference with your teaching.”

Yes, I am trying to bring a fresh take on PowerShell but that is a tertiary purpose.

You’ve hit precisely on my real goals: Condense years of trial error, studying, practice in such a ways that “10 years of learning” is possible in minutes, hours, weeks, or months.

That is in fact my proven speciality when teaching — I am so honored that your recognized and phrased it so precisely.

This is also what drew me to YOUR content; the explanation for my seeing such value and being so impressed by it.

Such won’t elimated “practice, practice, practice” but can GUIDE “deep practice” (aka “deliberate practice”) which itself can accelerate 5 years of ordinary practice into 1 year of deep practice time.

See, “The Talent Code” (Coyle) or “Bounce” (Syed) for quality explanations of Deep Practice which was first identified by Ericsson as “Deliberate Practice”.

It’s also (in my opinion) why your approach works for many people more effectively than “language tutorials”.

You are setting up practice exercises that are short & easy enough to be completed by beginners, interesting enough to be fulfilling (at least at that level), and difficult enough to require deep thinking and engender at least the beginning of deep practice.

At this point, I’m curious if you already knew this mechanism is the main reason your methos work? Or if you disagree.

Or if you have other ideas (in addition) on why your method is so effective?

> You have a great heart to share invaluable experiences, and you encompass a lot, many towards yourself. I did not know about my approach until I faced that situation. You know "Necessity is the mother of invention" is a well-known proverb. I had to live by that. As said before I got a teaching assignment at the beginning of my career and that was an urban college. Most of the students were below average or just above average in academics. 90


> 90% of students were below average or just above average and they were not interested in learning as most of the kids belonged to the well-settled business class people. So i had to start with something with minimal technical theory because more theoretically explanation may switched off their interest in the subject.

> The theory covered was so basic that everybody was able to pickup easily. If we observe anyone who is good in any subject, their visualization about that subject works actively, whether it could be story-telling, solving math problems or whatever. I think I need to pick those examples which can help to improve their visualization about - how the flow of data happening in a program. The approach clicked very well. Interest makes hard tasks easy, and they could learn the rest of the things quickly after this crash-course of logic-building skills. Obviously, the problems should be in the order of increasing difficulties without major jerks. This was very important to me, as most of them had the mindset that “programming is not my thing” and they were in a ready position to confirm this. If something goes blank after a few attempts, they are ready to quit learning. I had to present programming in such a way that should sound very familiar to them. What happened was opposite and they themselves, with their own interests, used to spend twice or thrice extra lab sessions. It shocked me how this seems to be a simple strategy that can be so much more effective. There were two batches of 50+ students with C & C++ as introductory language. They are from commerce backgrounds and understand statistical tables well, at-least of simpler types. They were habitual of applying statistical formulae to the tabular data. I used this background to explain the flow of data in the program and help them derive a logical expression from the tabular data and fit into the programming constructs. This activity inherently becomes well-thought work as opposed to the trail-error method. An average person easily understood simple tabular information as we see such examples a lot around us. I believe this is the main reason for its calm acceptance. Later point of time, i observed that unknowingly i followed the steps of computational thinking. I found this basic crash-course was enough to create interest and develop confidence so that students to try more topics. Although this set works fine for beginners, I need to include more variety of exercise and problems to give a feeling of completeness in the first view.

My largest problem is related to “Interest makes hard tasks easy,” though not as deeply as yours. I do want to reach primarily people who already have an interest (It’s almost a rule of MINE that I only teach people who at least want to learn and are willing to do SOME work.)

You have had a different and more difficult problem in reaching those without initial interest or any (significant) pre-existing specific skills.

My issue is MAINTAINING interest and motivating the “reading of a book” plus the “determination and follow through to complete the necessary exercise”. (You have much of this issue in addition to your initial problem of generating interested but by teaching live in a classroom your students are partially motivated by the requirement to take or complete the course, to earn a passing grade, to show up consistently etc.)

Presumably you find this discussion interest, so I’ll keep corresponding with you if that is true. (Let me know if that is ever not the case with you.)

Note that deep practice does not require “deliberation” or “intent” despite what Ericsson (the originator of the concept) claims and named it.

It only requires that the student consistently participate in deep practice even if that requires spending 10 years to obtain a year’s worth of that type of practice.

Thus I prefer Danial Coyle’s term “deep practice” to the more specific and unnecessarily restrictive “deliberate” term.

44m ago
Once one knows the clear principles of “deep practice”, one can take the effective exercises, practices, and habits and emphasize or ehnance those aspect that maximize effectively even further.

Thus, I commen “The Talent Code” to your attention (Bound is good too but more useful if you first find Talent Code compelling and just want to read more of the fantastic context of this subject: both are good, Talent Code is better and more essential.)

Let me know if you pursue that and I’ll offer some of my notes on the key points which actually only cover a couple of pages of the lengthier book. The book is longer due to explaining the reasoning and motivating the rules by offering compelling and interesting examples throughout.

A simple summary is something like this: chunking (practice small parts), high repetition, right near the boundary between existing competence and failure, immediate feedback (knowing as quickly as possible if the practice is working effectively or not), etc.

(I am not doing it full justice here in the interests of brevity.)

There’s another body of knowledge on keeping interest and motivating learners who don’t (yet) understand the importance or have an inherent interest — this impinges more on the ‘generating intial motivation’ issue you have and ‘keeping interest’ and ‘maintaing both interest and action” to complete the necessary exercises and other work.

This is related AND overlapping to deep practice but quite distinct.

My best examples of this are from the series of books by Glenn Doman starting with “How to Teach Your Baby to Read” which will likely cause you to tear up in several places during the descriptions of repeatable successes by severely handicapped small children.

The second item offering a detailed example (and less theory) of these principles is the book “Teach Your Child to Read in 100 Easy Lessons” by Siegfried Engelmann , Phyllis Haddox.

The main points being something like this: Short, fun lessons, quit WHILE YOU BOTH are still having FUN, high repetition, consistency over time, clarity, and elimate unneccary complications (in the beginning.)

You can certainly see the large overlap with the main additions being:

1. Fun (explicitly mentioned)
2. Stop while YOU are STILL having fun — not AFTER you notice that you are the baby are no longer enjoying the practice session (this is very difficult for most people to do in practice since success encourages the parent to go on and on to maximize the benefit).
3. High repeition of small practices **throughout the day** — the multiple practices in a single day  aren’t explicitly mentioned in most “deep practice” but entirely consistent with it.
I don’t know if these books are worth your time and expense, but the former (Doman) is cheap and easy to read, as well as enjoyable and interesting even as a simple set of stories.
The Engelmann book is much more of a “detailed lesson plan book” offering more of a do this precisely to teach this precise skill than to discuss the general principles supporting the methods.
For my part one of the most difficult things is to find clear, compelling, highly valuable, incremental, discrete/small, interesting (even fun) exercises to provide the “practice” portion using these principles.
You probably can understand much of my interest in your examples and in your successes in doing this.
(Too many young people want to “build video games”, or similar, without having any concept of how large and difficult an endeavor that is, and no concept of incremental practice — they expect almost immediate tangible results.)




### > What are the terminologies in computers you are finding difficult?
There are 3 main categories:
1. Terms that use incorrect names and words based on the other meanings of those words in English (or another language too.)
2. Terms that are based on obscure English words that SOUND FAMILIAR but that most people don’t actually know
3. Terms that are based on tertiary of meanings of English words that have little relationship to the common and even secondary meanings of those words.
4. [Joke intended, read to the end to understand]
Terms that have multiple distinct meaning depending on context that is left unspecified.
Part of my well-know skill in explaining such difficult words and the ideas they are used to assemble is based on explaining the ACTUAL meanings of those words and ideas as well as how they were chosen so my friends and students can understand them or know when a particular context changes the meaning.
A few examples:
**RING — **meaning derived from math, and carried into category theory and functional programming. It derives from the German word commonly meaning “group” as in an “criminal ring” or “circle of friends”.
It was used to distinguish a concept from a different concept known as a “Group” The concepts are distinct and they needed another term to make fine technical distinctions.
**DOMAIN — **two problems (see joke below), it has ordinary meanings in English and but it not commonly used, most people think they know what it means but never bother to look it up or gain clarity, and it’s used differently in different contexts mostly based on “area of control” or “area/scope of responsibility”, as in the “King’s Domain” or the “domain of control” or “domain/area of expertise”
* Active Directory Domain (which has relationships to the next item DNS but means something entirely different)
* DNS — Domain Name System
* Domain Modeling and Domain Driven Design (which aren’t even the same thing)
* Broadcast or Collision domains — the area or scope of a the ‘wire’ where broadcasts can be heard or separately where collisions can occur from two devices.
* And then there is the term “Realm” which has similar English meaning but is used (mostly) for distinct concepts such as security token authentication “Realms” which might use AD and DNS as well.
**BUS or Computer BUS** — it’s one of those things that all (?) really experience hardware people sort of understand but typicaly cannot explain and don’t know how the word was chosen.
BUS from Autobus — the original term for the vehicle that passed through a town and was “available everywhere” or could be accessed from any part of the town (as long as you lived near the main route) to “access the bus”.
Thus the reasoning: The BUS of a computer is communication pathway between all/most/many of the components such as the CPU, Memory, Motherboard devices that allows for requesting services or memory values to be transmitted.
“There are two hard problems in computing”:
1. **Naming**
2. **Off by one bugs**
3. Invalid memory pointers (it’s an old joke and serious point)
4. In modern times we also recognize among these 2 problems:
Buffer overflows

#>


