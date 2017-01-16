. .\Set-RandomBackground.ps1
. .\ShutdownTimer.ps1

Function Get-WordFromDictionary 
{
    [Cmdletbinding()]
    Param(
            [String]$StartingAlphabet
    )

    $Results = @()
    $i = 1

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

        Write-Verbose "Harvesting data on Page-$i of $URL for Alphabet : $StartingAlphabet"
        $WebRequest = Invoke-WebRequest $URL
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

            If(-not ($WebRequest.ParsedHtml.all | where {$_.nodename -eq 'a' -and $_.classname -eq 'button next'}))
            {
                break
            }
    }
    $Results
} 

[char[]]"abcdefghijklmnopqrstuvwxyz" | ForEach-Object {
    
    $Alpha = $_
    Get-WordFromDictionary $Alpha -Verbose | ConvertTo-Json | `
    Out-File "C:\Data\Powershell\Scripts\DictionaryAlphabetJSON\$Alpha.json"
    Write-Host "Alphabet : $Alpha is complete" -ForegroundColor Yellow
}

Set-RandomBackground -DanceFloorMode

#ShutdownTimer -mins 5


