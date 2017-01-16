Function Get-DictionaryWord
{
    [Cmdletbinding()]
    Param(
            [String]$StartingAlphabet
    )

    $Results = @()
    $i = 1
    $StartingAlphabet = $StartingAlphabet.toLower()


    While($true)
    {
        $WebRequest = ''
        If($i -eq 1)
        {
            $URLSubString = "$StartingAlphabet"
        }
        else
        {
            $URLSubString = "$StartingAlphabet/$i"
        }

        $URL = "http://learnersdictionary.com/3000-words/alpha/$URLSubString"

        Write-Verbose "Harvesting data from Page-$i of $URL for Alphabet : $StartingAlphabet"
        
        $WebRequest = Invoke-WebRequest $URL
        
        Write-Verbose "Converting raw data into structured data [PSObjects]"
        $Innertext = ($WebRequest.parsedhtml.all |where{$_.nodename -eq 'ul' -and $_.classname -eq 'a_words'}).innertext 
        $InnerText = $Innertext -split [environment]::NewLine | ?{$_}

        $Item = $Innertext | ForEach-Object{
        
            $word = '';$POS = ''
            
            $text = $_.trim()
            $splitWords = $text.split(" ")
            $Word = $splitWords[0]
            
            If($splitWords.count -gt 1)
            {
                $POS  = $splitWords.replace('(','').replace(')','')[1..$text.Length] -join ' '

                If($POS)
                {
                    $POS = $POS.replace("(",'').replace(")",'')
                }
            }

            ''|Select @{n='Word';e={$Word}}, @{n='PartOfSpeech';e={$POS}}
        }

            $Results = $Results + $Item
            $i = $i + 1

            # When Pagination ends on a page (no next button) break the Loop
            # Output the results
            If(-not ($WebRequest.ParsedHtml.all | where {$_.nodename -eq 'a' -and $_.classname -eq 'button next'}))
            {
                break
            }
    }
    $Results
} 

[char[]]"vwxyz" | ForEach-Object {
    
    $Alpha = $_
    Get-DictionaryWord $Alpha -Verbose | ConvertTo-Json | `
    Out-File ".\DictionaryAlphabetJSON\$Alpha.json"
    Write-Host "Alphabet : $Alpha is complete" -ForegroundColor Yellow
}
