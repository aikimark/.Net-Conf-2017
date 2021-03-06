#=========================================================
# Raleigh .Net Conf 2017 Powershell scripts
# Place this file in your homepath directory
# Place the isbetween.ps1 file in the same or sub directory
# as this example script file.
#=========================================================
# general help
get-help 
# get-help alias = help ; speaking of aliases...
# show command aliases
get-alias
# look for "process"
help process
# clear the output window
clear-host
# help about the get-process cmdlet
help get-process
# cls = clear-host alias; chained commands with semi-colon
# look at the get-process examples
cls;help get-process -examples

#->PPT
break

#====================================================
# Strings
# $env (special weird var) exposes the environment values
$Env:username, $Env:homepath, $Env:temp, $Env:os

# displaying the results
# string concatenation and special chars (` and `t)
$Env:username + "`t -- `t" + $Env:homepath

# difference between quote and apostrophe-delimited strings
"$Env:username `t -- `t $Env:homepath"  # what we want
'$Env:username `t -- `t $Env:homepath'  # not helpful

#====================================================
# you have access to lots of system information
# Store the WMI call result in a variable
$w = Get-WmiObject -Class win32_OperatingSystem `
          -namespace "root\CIMV2" -ComputerName .
$w.version

# automatic substitution in quoted strings, sometimes weird
"$w.version=$w.version"
"`$w.version=$w.version"
'$w.version='+$w.version
"`$w.version=$($w.version)" #sometimes you need 
                            #to force the evaluation
#->PPT
break

#====================================================
cls
# Let's look at the file system, iterating a directory
$dirtreefiles = Get-ChildItem .\Downloads
$dirtreefiles.Count   #or .Length

# iterate the entire DOWNLOADS directory tree with the -recurse parameter
$dirtreefiles = Get-ChildItem .\Downloads -recurse
$dirtreefiles.count   #or .Length

# Pipeline Example 1
cls
# What does this object variable contain? (properties and methods)
# note the PSIsContainer property value of the directory items and the file items
$dirtreefiles | Get-Member   #or | gm

# Pipeline Example 2
cls
# Filter the object items
# where reduces the rows/items we have
$dirtreefiles | where {$_.name.StartsWith("l")}

# Pipeline Example 3
cls
# making the expression an object with () to get a property
($dirtreefiles | where {$_.name.StartsWith("l")}).count

# Pipeline Example 4
cls
# but what is in our l results?
# NOTE: I am using the -filter parameter because 
#       it is faster than -include
$dirtreefiles = Get-ChildItem .\Downloads -recurse -filter "l*"
$dirtreefiles.count   #or .Length
$dirtreefiles  # notice it contains files that begin with both upper and lower case "L"

# Pipeline Example 5
cls
# let's exclude the directories
# Since we already populated the variable, this is really quick
$dirtreefiles = Get-ChildItem .\Downloads | where {$_.PSisContainer -eq $false}
'$dirtreefiles.count='+$dirtreefiles.count   #or .Length
$dirtreefiles  # now it only contains files
#Note: in PS v3+, Get-ChildItem has a -File property

#->PPT

# Pipeline Example 6
cls
$dirtreefiles = Get-ChildItem .\Downloads
# chain multiple pipelines to get what you want
# select reduces the columns we have
$dirtreefiles | where {$_.Length -gt 1000000} | 
    select directory, name, basename, extension, length  
    # same output as "| format-list"

# Pipeline Example 7
cls
# prettier output
$dirtreefiles | where {$_.Length -gt 1000000} | 
    select directory, name, basename, extension,length | 
    format-table   # or ft

# Pipeline Example 8
cls
# let's slice and dice these big boys ourselves
# sorting the items and send output to the gridview window
$dirtreefiles | where {$_.Length -gt 1000000} | 
    select directory, name, basename, extension, length  | 
    Sort-Object -Property length -Descending | 
    Out-GridView
#->PPT
break

#==Extra=============================================
# Your moment of performance
# If you are interested in the performance differences, run
# these statements.
cls
"pipe to where"
Measure-Command{Get-ChildItem .\Downloads -recurse | where {$_.name.StartsWith("l")}}
"Get-ChildItem -include parameter"
Measure-Command{Get-ChildItem .\Downloads -recurse -include "l*"}
"Get-ChildItem -filter parameter"
Measure-Command{Get-ChildItem .\Downloads -recurse -filter "Q_*"}
# caching results is a good perf. trick
"assigning results to a variable"
Measure-Command{$dirtreefiles = Get-ChildItem .\Downloads -recurse}
"and then filtering the variable"
Measure-Command{$dirtreefiles | where {$_.name.StartsWith("l")}}
#->PPT
break

#====================================================
# The ForEach statement
cls
$dirtreefiles = Get-ChildItem .\Downloads
# ForEach Demo 1
# What if I only want the count of the large PDF files
$dirtreefiles | where {$_.Length -gt 1000000} |
     ForEach -Begin{$xls_cnt=0} `
             -process {if($_.extension -eq ".pdf") {$xls_cnt+=1} } `
             -end{write-host "Number of PDF files larger than 1M: $xls_cnt"}

cls
# how about some simple arithmetic operations
$xls_cnt   # current value
# Your choice of incrementers
$xls_cnt++          ; $xls_cnt
$xls_cnt+=1         ; $xls_cnt
$xls_cnt=$xls_cnt+1 ; $xls_cnt

cls
# ForEach Demo 2
# iterating $dirtreefiles without pipelining
$xls_cnt=0
foreach ($fl in $dirtreefiles) {if($fl.extension -eq ".pdf") {$xls_cnt+=1}}
write-host "Count of PDF files: $xls_cnt"

cls
# ForEach Demo 3
# using the IF() conditional as a replacement for the where operator
$xls_cnt=0
foreach ($fl in $dirtreefiles) 
    {if($fl.extension -eq ".pdf" -and $fl.Length -gt 1000000) 
        {$xls_cnt+=1}
    }
write-host "Count of PDF files > 1M: $xls_cnt"
#->PPT
break

#====================================================
# The switch statement
cls
$dirtreefiles = Get-ChildItem .\Downloads -File
# Switch Demo 1 - value matching
$MV=$null
$pFirstValueType="fi"  #"feo" #"fe"  #"SelectFirst"  #"itemzero"
switch ($pFirstValueType){
    "ItemZero" {$MV = $dirtreefiles[0].length; break}
    "ItemLast" {$MV = $dirtreefiles[-1].length; break}
    "SelectFirst" {$MV = ($dirtreefiles | select -first 1).length; break}
    "SelectLast" {$MV = ($dirtreefiles | select $_.length -last 1).length; break}
    "FE" {$dirtreefiles | foreach{
                            $MV = $_.length
                            break
                            }
          ; break}
    "FEO" {$dirtreefiles | foreach-object -process {
                                            $MV = $_.length
                                            break
                                            }
           ; break}
    "FI" {foreach ($MMV in $dirtreefiles){$MV=$MMV.length; break}}
    default {write-error "pFirstValueType not an allowable value ['ItemZero', 'SelectFirst', 'SelectLast', 'FE', 'FEO']"}
}
$MV

# Switch Demo 2 - casesensitive value matching
$MV=$null
$pFirstValueType="fi"  #"fi" will cause an error because case sensitive match
switch -casesensitive ($pFirstValueType){
    "ItemZero" {$MV = $dirtreefiles[0].length; break}
    "ItemLast" {$MV = $dirtreefiles[-1].length; break}
    "SelectFirst" {$MV = ($dirtreefiles | select -first 1).length; break}
    "SelectLast" {$MV = ($dirtreefiles | select $_.length -last 1).length; break}
    "FE" {$dirtreefiles | foreach{
                            $MV = $_.length
                            break
                            }
          ; break}
    "FEO" {$dirtreefiles | foreach-object -process {
                                            $MV = $_.length
                                            break
                                            }
           ; break}
    "FI" {foreach ($MMV in $dirtreefiles){$MV=$MMV.length; break}}
    default {write-error "pFirstValueType not an allowable value ['ItemZero', 'SelectFirst', 'SelectLast', 'FE', 'FEO']"}
}
$MV

# Switch Demo 3 - regular expression matching
$MV=$null
$pFirstValueType="ITemlast" #"slelctLaSt"
switch -regex ($pFirstValueType){
    "I.+o" {$MV = $dirtreefiles[0].length; break}
    "it[^t]+t" {$MV = $dirtreefiles[-1].length; break}
    ".*First" {$MV = ($dirtreefiles | select -first 1).length; break}
    "last$" {$MV = ($dirtreefiles | select -last 1).length; break}
    "FE|FEO" {$dirtreefiles | foreach{
                                $MV = $_.length
                                break
                                }
          ; break}
    "FI" {foreach ($MMV in $dirtreefiles){$MV=$MMV.length; break}}
    default {write-error "pFirstValueType not an allowable value ['ItemZero', 'SelectFirst', 'SelectLast', 'FE', 'FEO']"}
}
$MV
#->PPT  if time, show Switch Magic demos
break

#==Extra=================================
# Switch Magic
$a = 25
#Measure-Command{
switch ($true)
{
	(1..10 -contains $a){"low";break}
	(11..21 -contains $a){"med";break}
	(22..31 -contains $a){"high";break}
	default {"unknown"}
}
#}

$a = 15
switch ($true)
{
	($a -lt 11){"low";break}
	($a -lt 22){"med";break}
	($a -le 31){"high";break}
	default {"unknown"}
}

# NOTE: The current directory is assumed to be the user directory
#       with the isbetween.ps1 file in the documents sub-folder
#. "documents\isbetween.ps1" #include the function in this file
. (Get-ChildItem -Filter isbetween.ps1 -Path . -Recurse -Depth 2).FullName

$a = 25
#Measure-Command{
switch ($true)
{
	(isbetween $a 1 10){"low";break}
	(isbetween $a 11 21){"med";break}
	(isbetween $a 22 31){"high";break}
	default {"unknown"}
}
#}
Remove-Item function:isbetween  #remove the isbetween function
#->PPT
break

#========================================
# Conversion and export examples
cls
# ConvertTo-XML Demo
$dirtreefiles | select directory,
      name, basename, extension, length | ConvertTo-Xml -as string

cls
# Export-CSV and view the results Demo
$dirtreefiles | select directory,
      name, basename, extension, length | 
      Export-Csv -Path .\documents\PSexported.csv
$(notepad.exe .\documents\PSexported.csv)   # launch another program
#Note: the first line makes this a malformed CSV

cls
# We remove the header with the -NoTypeInformation parameter (parameter aliases, such as -NTI exist)
# Export-CSV (well-formed) and view the results Demo
$dirtreefiles | select directory,
      name, basename, extension, length | 
      Export-Csv -Path .\documents\PSexported.csv -NoTypeInformation
$(notepad.exe .\documents\PSexported.csv)    # the first line has been dropped
$(.\documents\PSexported.csv)                # invoke associated program
#->PPT
break
