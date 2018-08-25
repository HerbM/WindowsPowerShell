Add-Type -AssemblyName System.Web

$protocol = 'https://'
$wiki = 'en.wikiversity.org/w/'
$api = 'api.php'
$username = 'username'
$password = 'password'

$csrftoken
$websession
$wikiversion

function Add-Section($title, $summary, $text)
{
    $uri = $protocol + $wiki + $api
    
    $body = @{}
    $body.action = 'edit'
    $body.format = 'json'
    $body.bot = ''
    $body.title = $title
    $body.section = 'new'
    $body.summary = $summary
    $body.text = $text
    $body.token = Get-CsrfToken

    $object = Invoke-WebRequest $uri -Method Post -Body $body -WebSession (Get-WebSession)
    $json = $object.Content
    $object = ConvertFrom-Json $json
    if($object.edit.result -ne 'Success')
    {
        throw('Error adding section:' + $object + ',' + $object.error)

    }
}

function Add-MissingLicenseInformation($start, $end)
{
    if($start -eq $null -or $end -eq $null)
    {
        throw('Add-MissingLicenseInformation requires start and end dates for search')
    }

    $files = Get-FilesNeedingLicenses $start $end
    $files = $files | Sort-Object -Property user, title
    $users = $files | Select-Object -ExpandProperty user -Unique

    Write-Output '== Files Missing License Information =='
    foreach($user in $users)
    {
        Write-Output (';[[User_talk:' + $user + ']]')
        $text = 'Thank you for uploading files to Wikiversity. See [[Wikiversity:Media]] for copyright and license requirements for Wikiversity files. '
        $text += 'All files must have copyright and/or license information added to the file.' + "`n`n"
        $text += 'Instructions for adding copyright and/or license information are available at [[Wikiversity:License tags]].  Files must be updated within seven days '
        $text += 'or they may be removed without further notice.  See [[RFD#Category:_Pending_deletions|Requests For Deletion]] for more information.' + "`n`n"
        $text += 'The following files are missing copyright and/or license information:' + "`n"
        
        $userfiles = $files | Where-Object user -eq $user
        foreach($file in $userfiles)
        {
            Write-Output (':[[:' + $file.title + ']]')
            $text += '* [[:' + $file.title + ']]' + "`n"
            Add-Section $file.title 'Missing License Information' '{{subst:nld}}'
            Start-Sleep -Seconds 5
        }
        $text = $text + "`n" + '~~~~' + "`n"
        Add-Section ('User_talk:' + $user) 'Files Missing License Information' $text
        Start-Sleep -Seconds 5
    }
}

function Clean-Backlinks($titles)
{
    $result = @()
    foreach($title in $titles)
    {
        if($title.IndexOf('User talk:') -ge 0)
        {
            continue
        }
        if($title.IndexOf('Wikiversity:Resources with Files Pending Deletion') -ge 0)
        {
            continue
        }
        if($title.IndexOf('Wikiversity:User Pages with Files Pending Deletion') -ge 0)
        {
            continue
        }
        if($title.IndexOf('Wikiversity:Unused Files Pending Deletion') -ge 0)
        {
            continue
        }
        $result += $title
    }
    return $result
}

function Clear-Variables()
{
    if($csrftoken -ne $null)
    {
        Clear-Variable csrftoken -Scope Global
    }
    if($websession -ne $null)
    {
        Clear-Variable websession -Scope Global
    }
    if($wikiversion -ne $null)
    {
        Clear-Variable wikiversion -Scope Global
    }
}

function Edit-NoLicense($title)
{
    Write-Output $title

    if($title.Substring(0, 5) -ne 'File:')
    {
        return
    }

    $text = Get-Page $title
    $regex = [regex]::match($text, '(== Missing License Information ==\n\n)?{{no license[^}]*}}')
    if($regex.Length -gt 0)
    {
        $text = $text.Substring(0, $regex.Index) + $text.Substring($regex.Index + $regex.Length)
        if($text.Length -gt 0)
        {
            while($text.Substring($text.Length - 2) -ne "`n`n")
            {
                $text += "`n"
            }
        }
        $text += "== License ==`n`n"
        $text += "{{Fairuse}} for school project`n"

        Write-Output $text
        Write-Output ''
        Write-Output ''

        $summary = 'Adding Fairuse License'
        Edit-Page $title $summary $text
    }
}

function Edit-Page($title, $summary, $text)
{
    $uri = $protocol + $wiki + $api

    $body = @{}
    $body.action = 'edit'
    $body.format = 'json'
    $body.bot = ''
    $body.title = $title
    $body.summary = $summary
    $body.text = $text
    $body.token = Get-CsrfToken

    $object = Invoke-WebRequest $uri -Method Post -Body $body -WebSession (Get-WebSession)
    $json = $object.Content
    $object = ConvertFrom-Json $json

    if($object.edit.result -ne 'Success')
    {
        throw('Error editing page:' + $object + ',' + $object.error)
    }
}

function Get-AllImages($start, $end, $user)
{
    $uri = $protocol + $wiki + $api
    
    $body = @{}
    $body.action = 'query'
    $body.format = 'json'
    $body.list = 'allimages'
    $body.aiprop = 'user|timestamp'
    $body.ailimit = 'max'

    if($start -ne $null -or $end -ne $null -or $user -ne $null)
    {
        $body.aisort = 'timestamp'
    }
    if($start -ne $null)
    {
        $body.aistart = $start
    }
    if($end -ne $null)
    {
        $body.aiend = $end
    }
    if($user -ne $null)
    {
        $body.aiuser = $user
    }

    $result = @()
    while($true)
    {
        $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
        $json = $object.Content
        $object = ConvertFrom-Json $json
        $allimages = $object.query.allimages

        foreach($entry in $allimages)
        {
            $result += $entry | Select-Object title, user, timestamp
        }

        if($object.('query-continue') -eq $null)
        {
            break
        }

        $uri = $protocol + $wiki + $api
        
        $body = @{}
        $body.action = 'query'
        $body.format = 'json'
        $body.list = 'allimages'
        $body.aiprop = 'user|timestamp'
        $body.ailimit = 'max'
        $body.aicontinue = $object.('query-continue').allimages.aicontinue
    }

    return $result
}

function Get-AllPages($prefix, $namespace)
{
    $uri = $protocol + $wiki + $api
    
    $body = @{}
    $body.action = 'query'
    $body.format = 'json'
    $body.list = 'allpages'
    $body.aplimit = 'max'
    $body.apfilterredir = 'nonredirects'

    if($prefix.length -gt 0)
    {
        $body.apprefix = $prefix
    }    
    if($namespace.length -gt 0)
    {
        $body.apnamespace = $namespace
    }

    $result = @()

    $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
    $json = $object.Content
    $object = ConvertFrom-Json $json
    $allpages = $object.query.allpages

    foreach($entry in $allpages)
    {
        $result += $entry | Select-Object title
    }

    return $result
}

function Get-AllRedirects()
{
    $uri = $protocol + $wiki + $api

    $body = @{}
    $body.action = 'query'
    $body.format = 'json'
    $body.generator = 'allpages'
    $body.gaplimit = '500'
    $body.prop = 'info'

    $result = @()
    while($true)
    {
        $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
        $json = $object.Content
        $object = ConvertFrom-Json $json
        $pages = $object.query.pages

        $names = $pages | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty name
        foreach($name in $names)
        {
            if($pages.($name).redirect -ne $null)
            {
                $result += $pages.($name) | Select-Object -Property pageid, title
            }
        }

        if($object.('query-continue') -eq $null)
        {
            break
        }

        $uri = $protocol + $wiki + $api

        $body = @{}
        $body.action = 'query'
        $body.format = 'json'
        $body.generator = 'allpages'
        $body.gaplimit = '500'
        $body.prop = 'info'
        $body.gapcontinue = $object.('query-continue').allpages.gapcontinue
    }

    return $result
}

function Get-BackLinks($title)
{
    $uri = $protocol + $wiki + $api
    
    $body = @{}
    $body.action = 'query'
    $body.format = 'json'
    $body.list = 'backlinks'
    $body.bllimit = 'max'
    $body.bltitle = $title

    $result = @()
    while($true)
    {
        $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
        $json = $object.Content
        $object = ConvertFrom-Json $json
        $backlinks = $object.query.backlinks

        foreach($entry in $backlinks)
        {
            $result += $entry.title
        }

        if($object.('query-continue') -eq $null)
        {
            break
        }

        $uri = $protocol + $wiki + $api
        
        $body = @{}
        $body.action = 'query'
        $body.format = 'json'
        $body.list = 'backlinks'
        $body.bllimit = 'max'
        $body.bltitle = $title
        $body.blcontinue = $object.('query-continue').backlinks.blcontinue
    }

    return $result
}

function Get-CategoryDuplicateFiles($category)
{
    $uri = $protocol + $wiki + $api
    
    $body = @{}
    $body.action = 'query'
    $body.format = 'json'
    $body.prop = 'duplicatefiles'
    $body.generator = 'categorymembers'
    $body.gcmlimit = 'max'
    $body.gcmtitle = $category

    $result = @()
    while($true)
    {
        $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
        $json = $object.Content
        $object = ConvertFrom-Json $json
        $pages = $object.query.pages
        $names = $pages | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty name

        foreach($name in $names)
        {
            if($pages.($name).duplicatefiles.Count -gt 0)
            {
                $file = $pages.($name).duplicatefiles
                $file | Add-Member -type NoteProperty -Name 'title' -Value ($pages.($name).title)
                $result += $file | Select-Object -Property title, name, user, timestamp
            }
        }

        if($object.('query-continue') -eq $null)
        {
            break
        }
        
        $uri = $protocol + $wiki + $api
        
        $body = @{}
        $body.action = 'query'
        $body.format = 'json'
        $body.prop = 'duplicatefiles'
        $body.generator = 'categorymembers'
        $body.gcmlimit = 'max'
        $body.gcmtitle = $category
        $body.gcmcontinue = $object.('query-continue').categorymembers.gcmcontinue
    }

    return $result
}

function Get-CategoryImageInfo($category)
{
    $uri = $protocol + $wiki + $api
    
    $body = @{}
    $body.action = 'query'
    $body.format = 'json'
    $body.prop = 'imageinfo'
    $body.generator = 'categorymembers'
    $body.gcmlimit = 'max'
    $body.gcmtitle = $category

    $result = @()
    while($true)
    {
        $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
        $json = $object.Content
        $object = ConvertFrom-Json $json
        $pages = $object.query.pages
        $names = $pages | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty name

        foreach($name in $names)
        {
            $file = $pages.($name).imageinfo
            $file | Add-Member -type NoteProperty -Name 'title' -Value ($pages.($name).title)
            $result += $file | Select-Object -Property title, user, timestamp
        }

        if($object.('query-continue') -eq $null)
        {
            break
        }
        
        $uri = $protocol + $wiki + $api
        
        $body = @{}
        $body.action = 'query'
        $body.format = 'json'
        $body.prop = 'duplicatefiles'
        $body.generator = 'categorymembers'
        $body.gcmlimit = 'max'
        $body.gcmtitle = $category
        $body.gcmcontinue = $object.('query-continue').categorymembers.gcmcontinue
    }

    return $result
}

function Get-CategoryMembers($category)
{
    $uri = $protocol + $wiki + $api

    if($category.Substring(0, 9).ToLower() -ne 'category:')
    {
        $category = 'Category:' + $category
    }

    $body = @{}
    $body.action = 'query'
    $body.format = 'json'
    $body.list = 'categorymembers'
    $body.cmlimit = 'max'
    $body.cmtitle = $category

    $result = @()
    while($true)
    {
        $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
        $json = $object.Content
        $object = ConvertFrom-Json $json
        $categorymembers = $object.query.categorymembers

        foreach($entry in $categorymembers)
        {
            $result += $entry.title
        }

        if($object.('query-continue') -eq $null)
        {
            break
        }

        $uri = $protocol + $wiki + $api
        
        $body = @{}
        $body.action = 'query'
        $body.format = 'json'
        $body.list = 'categorymembers'
        $body.cmlimit = 'max'
        $body.cmtitle = $category
        $body.cmcontinue = $object.('query-continue').categorymembers.cmcontinue
    }

    return $result
}

function Get-CsrfToken()
{
    if($csrftoken -eq $null)
    {
        $uri = $protocol + $wiki + $api

        if((Get-Version) -lt '1.24')
        {
            $uri = $protocol + $wiki + $api

            $body = @{}
            $body.action = 'query'
            $body.format = 'json'
            $body.prop = 'info'
            $body.intoken = 'edit'
            $body.titles = 'User:' + $username

            $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
            $json = $object.Content
            $object = ConvertFrom-Json $json

            $pages = $object.query.pages
            $page = ($pages | Get-Member -MemberType NoteProperty).Name
            $csrftoken = $pages.($page).edittoken
        }
        else
        {
            $body = @{}
            $body.action = 'query'
            $body.format = 'json'
            $body.meta = 'tokens'
            $body.type = 'csrf'

            $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
            $json = $object.Content
            $object = ConvertFrom-Json $json

            $csrftoken = $object.query.tokens.csrftoken
        }
    }

    return $csrftoken
}

function Get-DuplicateFiles($titles)
{
    $uri = $protocol + $wiki + $api

    $body = @{}
    $body.action = 'query'
    $body.format = 'json'
    $body.prop = 'duplicatefiles'
    $body.dflimit = 'max'
    $body.titles = $titles

    $result = @()
    while($true)
    {
        $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
        $json = $object.Content
        $object = ConvertFrom-Json $json
        $pages = $object.query.pages
        $names = $pages | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty name

        foreach($name in $names)
        {
            $file = $pages.($name).duplicatefiles
            $file | Add-Member -type NoteProperty -Name 'title' -Value ($pages.($name).title)
            $result += $file | Select-Object -Property title, user, timestamp
        }

        if($object.('query-continue') -eq $null)
        {
            break
        }
        
        $uri = $protocol + $wiki + $api
        
        $body = @{}
        $body.action = 'query'
        $body.format = 'json'
        $body.prop = 'duplicatefiles'
        $body.dflimit = 'max'
        $body.titles = $titles
        $body.dfcontinue = $object.('query-continue').duplicatefiles.dfcontinue
    }

    return $result
}

function Get-EmbeddedIn($title)
{
    $uri = $protocol + $wiki + $api
    
    $body = @{}
    $body.action = 'query'
    $body.format = 'json'
    $body.list = 'embeddedin'
    $body.eilimit = 'max'
    $body.eititle = $title

    $result = @()
    while($true)
    {
        $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
        $json = $object.Content
        $object = ConvertFrom-Json $json
        $pages = $object.query.embeddedin

        foreach($page in $pages)
        {
            $result += $page | Select-Object -Property pageid, title
        }

        if($object.('query-continue') -eq $null)
        {
            break
        }

        $uri = $protocol + $wiki + $api
        
        $body = @{}
        $body.action = 'query'
        $body.format = 'json'
        $body.list = 'embeddedin'
        $body.eilimit = 'max'
        $body.eititle = $title
        $body.eicontinue = $object.('query-continue').embeddedin.eicontinue
    }

    return $result
}

function Get-FilesNeedingLicenses($start, $end)
{
    $result = @()
    $files = Get-AllImages $start $end
    foreach($file in $files)
    {
        $page = Get-Page $file.title
        $page = $page.ToLower()
        if($page.IndexOf('{{information') -ge 0)
        {
            continue
        }
        if($page.IndexOf('{{pd') -ge 0)
        {
            continue
        }
        if($page.IndexOf('{{cc-by') -ge 0)
        {
            continue
        }
        if($page.IndexOf('{{gfdl') -ge 0)
        {
            continue
        }
        if($page.IndexOf('{{self') -ge 0)
        {
            continue
        }
        if($page.IndexOf('{{bsd') -ge 0)
        {
            continue
        }
        if($page.IndexOf('{{gpl') -ge 0)
        {
            continue
        }
        if($page.IndexOf('{{lgpl') -ge 0)
        {
            continue
        }
        if($page.IndexOf('{{free') -ge 0)
        {
            continue
        }
        if($page.IndexOf('{{copyright') -ge 0)
        {
            continue
        }
        if($page.IndexOf('{{fairuse') -ge 0)
        {
            continue
        }
        if($page.IndexOf('{{non-free') -ge 0)
        {
            continue
        }
        if($page.IndexOf('{{software') -ge 0)
        {
            continue
        }
        if($page.IndexOf('{{no license') -ge 0)
        {
            continue
        }
        if($page.IndexOf('{{no fairuse') -ge 0)
        {
            continue
        }
        $result += $file
    }

    return $result
}

function Get-ImageInfo($titles)
{
    $uri = $protocol + $wiki + $api
    
    $body = @{}
    $body.action = 'query'
    $body.format = 'json'
    $body.prop = 'imageinfo'
    $body.titles = $titles

    $result = @()
    while($true)
    {
        $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
        $json = $object.Content
        $object = ConvertFrom-Json $json
        $pages = $object.query.pages
        $names = $pages | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty name

        foreach($name in $names)
        {
            $file = $pages.($name).imageinfo
            $file | Add-Member -type NoteProperty -Name 'title' -Value ($pages.($name).title)
            $result += $file | Select-Object -Property title, user, timestamp
        }

        if($object.('query-continue') -eq $null)
        {
            break
        }
        
        $uri = $protocol + $wiki + $api
        
        $body = @{}
        $body.action = 'query'
        $body.format = 'json'
        $body.prop = 'imageinfo'
        $body.titles = $titles
        $body.iicontinue = $object.('query-continue').imageinfo.iicontinue
    }

    return $result
}

function Get-ImageUsage($title)
{
    $uri = $protocol + $wiki + $api
    
    $body = @{}
    $body.action = 'query'
    $body.format = 'json'
    $body.list = 'imageusage'
    $body.iulimit = 'max'
    $body.iutitle = $title

    $result = @()
    while($true)
    {
        $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
        $json = $object.Content
        $object = ConvertFrom-Json $json
        $imageusage = $object.query.imageusage

        foreach($entry in $imageusage)
        {
            $result += $entry.title
        }

        if($object.('query-continue') -eq $null)
        {
            break
        }
        
        $uri = $protocol + $wiki + $api
        
        $body = @{}
        $body.action = 'query'
        $body.format = 'json'
        $body.list = 'imageusage'
        $body.iulimit = 'max'
        $body.iutitle = $title
        $body.iucontinue = $object.('query-continue').imageusage.iucontinue
    }

    return $result
}

function Get-Links($title)
{
    $uri = $protocol + $wiki + $api

    $body = @{}
    $body.action = 'query'
    $body.format = 'json'
    $body.generator = 'links'
    $body.prop = 'info'
    $body.gpllimit = 'max'
    $body.titles = $title

    $result = @()
    while($true)
    {
        $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
        $json = $object.Content
        $object = ConvertFrom-Json $json
        $pages = $object.query.pages

        $names = $pages | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty name
        foreach($name in $names)
        {
            $link = $pages.($name) | Select-Object -Property title
            if($pages.($name).redirect -ne $null)
            {
                $link | Add-Member -type NoteProperty -Name 'redirect' -Value $true
            }
            else
            {
                $link | Add-Member -type NoteProperty -Name 'redirect' -Value $false
            }
            $result += $link
        }

        if($object.('query-continue') -eq $null)
        {
            break
        }

        $uri = $protocol + $wiki + $api
        
        $body = @{}
        $body.action = 'query'
        $body.format = 'json'
        $body.generator = 'links'
        $body.prop = 'info'
        $body.gpllimit = 'max'
        $body.titles = $title
        $body.gplcontinue = $object.('query-continue').links.gplcontinue
    }

    return $result
}

function Get-OrphanedTalkPages($prefix)
{
    $titles = Get-AllPages $prefix '1'
    foreach($title in $titles)
    {
        $page = Get-PageInfo ($title.title -replace 'Talk:', '')
        if($page.missing -ne $null)
        {
            Write-Host ('* [[' + $title.title + ']]')
        }
    }
}

function Get-Page($title)
{
    $uri = $protocol + $wiki + 'index.php'
    
    $body = @{}
    $body.action = 'raw'
    $body.title = $title

    try
    {
        $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
        $result = $object.Content
    }
    catch [Net.WebException] 
    {
        if($error.Exception.ToString().IndexOf('404') -lt 0)
        {
            throw('Unexpected message returned from Get-Page ' + $title + ': ' + $error.Exception.ToString())
            exit
        }
        $result = ''
    }
    return $result
}

function Get-PageInfo($titles)
{
    $uri = $protocol + $wiki + $api

    $body = @{}
    $body.action = 'query'
    $body.format = 'json'
    $body.prop = 'info'
    $body.titles = $titles

    $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
    $json = $object.Content
    $object = ConvertFrom-Json $json
    $pages = $object.query.pages

    $result = @()
    $names = $pages | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty name
    foreach($name in $names)
    {
        $result += $pages.($name)
    }

    return $result
}

function Get-Pages($titles)
{
    $uri = $protocol + $wiki + $api
    
    $body = @{}
    $body.action = 'query'
    $body.format = 'json'
    $body.prop = 'revisions'
    $body.rvprop = 'content'
    $body.titles = $titles

    $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
    $json = $object.Content
    $object = ConvertFrom-Json $json
    $pages = $object.query.pages

    $result = @{}
    foreach($entry in $pages.Keys)
    {
        $page = $pages.Item($key)
        $result.Add($page.title, $page.revisions.('*'))
    }

    return $result
}

function Get-WebSession()
{
    if($websession -eq $null)
    {
        Invoke-LogIn $username $password
    }
    return $websession
}

function Get-Version()
{
    if($wikiversion -eq $null)
    {
        $uri = $protocol + $wiki + $api

        $body = @{}
        $body.action = 'query'
        $body.format = 'json'
        $body.meta = 'siteinfo'
        $body.siprop = 'general'

        $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
        $json = $object.Content
        $object = ConvertFrom-Json $json

        $wikiversion = $object.query.general.generator
        $wikiversion = $wikiversion -replace 'MediaWiki ', ''
    }

    return $wikiversion
}

function Invoke-Login($username, $password)
{
    $uri = $protocol + $wiki + $api

    $body = @{}
    $body.action = 'login'
    $body.format = 'json'
    $body.lgname = $username
    $body.lgpassword = $password

    $object = Invoke-WebRequest $uri -Method Post -Body $body -SessionVariable global:websession
    $json = $object.Content
    $object = ConvertFrom-Json $json

    if($object.login.result -eq 'NeedToken')
    {
        $uri = $protocol + $wiki + $api

        $body.action = 'login'
        $body.format = 'json'
        $body.lgname = $username
        $body.lgpassword = $password
        $body.lgtoken = $object.login.token

        $object = Invoke-WebRequest $uri -Method Post -Body $body -WebSession $global:websession
        $json = $object.Content
        $object = ConvertFrom-Json $json
    }
    if($object.login.result -ne 'Success')
    {
        throw ('Login.result = ' + $object.login.result)
    }
}

function Invoke-Logout()
{
    $uri = $protocol + $wiki + $api
    
    $body = @{}
    $body.action = 'logout'
    $body.format = 'json'

    $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
    
    Clear-Session
}

function Move-Title($from, $to, $reason)
{
    $uri = $protocol + $wiki + $api

    $body = @{}
    $body.action = 'move'
    $body.format = 'json'
    $body.bot = ''
    $body.from = $from
    $body.to = $to
    $body.reason = $reason
    $body.movetalk = ''
    $body.movesubpages = ''
    #$body.noredirect = ''
    $body.token = Get-CsrfToken

    $object = Invoke-WebRequest $uri -Method Post -Body $body -WebSession (Get-WebSession)
    $json = $object.Content
    $object = ConvertFrom-Json $json
}

function Show-Backlinks($title)
{
    Write-Output (';[[' + $title + ']]')
    $links = Get-BackLinks $title
    foreach($link in $links)
    {
        Write-Output (':[[' + $link + ']]')
    }
}

function Show-DuplicateFiles()
{
    Clear-Host

    Write-Host '== Duplicate Files =='
    $result = Get-CategoryDuplicateFiles 'Category:Pending deletions'
    $result += Get-CategoryDuplicateFiles 'Category:Files needing copyright information'

    foreach($file in $result)
    {
        Write-Host (';[[:' + $file.title + ']]')
        Write-Host (':[[:File:' + $file.name + ']]')
    }
}

function Show-FilesNeedingLicenses($start, $end)
{
    $result = Get-FilesNeedingLicenses $start $end

    Clear-Host
    Write-Output '== Files Needing Licenses =='
    foreach($file in $result)
    {
        Write-Host ('* [[:' + $file.title + ']]')
    }
}

function Show-FilesSortedByUser
{
    return
    #Work code used temporarily in main, preserved for future use

    #$result = @()
    #foreach($file in $unused)
    #{
    #    $file
    #    $result += Get-ImageInfo $file
    #}

    Clear-Host
    #$result = $result | Sort-Object
    $hold = ''
    foreach($line in $result)
    {
        $user = $line.Substring(0, $line.IndexOf('|'))
        $file = $line.Substring($line.IndexOf('|') + 1)

        if($hold -ne $user)
        {
            $hold = $user
            Write-Host (';[[User:' + $user + ']]')
        }
        Write-Host (':[[:' + $file + ']]')
    }
}

function Show-OrphanedRedirects
{
    $pages = Get-AllRedirects
    $hold = ''

    Write-Output '== Orphaned Redirects =='
    foreach($page in $pages)
    {
        $links = Get-BackLinks $page.title
        if($links.Count -eq 0)
        {
            $text = Get-Page $page.title
            $regex = [regex]::Match($text, '\[\[[^\]]*\]\]')
            if($regex.Length -gt 0)
            {
                if($hold -ne $page.title.Substring(0, 1).ToUpper())
                {
                    $hold = $page.title.Substring(0, 1).ToUpper()
                    Write-Output ('== ' + $hold + ' ==')
                }
                Write-Output ('* [[' + $page.title + ']] -> ' + $regex.Value)
            }
        }
    }
}

function Show-OrphanedRedirects2
{
    $orphans = Get-Page 'Wikiversity:Orphaned Redirects'
    $sisters = Get-Page 'Wikiversity:Sister Backlinks'

    $lines = $orphans -split "`n"
    foreach($line in $lines)
    {
        $regex = [regex]::Match($line, '\* \[\[[^]]*\]\]')
        if($regex.Length -gt 0)
        {
            $value = $regex.Value.Substring(4, $regex.Length - 6)
            $value = [regex]::Escape($value)
            $regex = [regex]::Match($sisters, '\[\[\s?' + $value + '\s?\]\]', 'IgnoreCase')
            if($regex.Length -gt 0)
            {
                continue
            }
        }
        Write-Output $line
    }
}

function Show-FilesNeedingCopyrightInformation
{
    $files = Get-CategoryMembers('Category:Files needing copyright information')
    $files = $files | Sort-Object

    Write-Output '== Files Needing Copyright Information =='
    $result = @()
    foreach($file in $files)
    {
        $text = Get-Page $file

        $regex = [regex]::Match($text, 'month=[^|]*', 'IgnoreCase')
        if($regex.Length -eq 0)
        {
            continue
        }
        $month = $regex.Value.Substring(6)

        $regex = [regex]::Match($text, 'day=[^|]*', 'IgnoreCase')
        if($regex.Length -eq 0)
        {
            continue
        }
        $day = $regex.Value.Substring(4)

        $value = $regex.Value
        $regex = [regex]::Match($text, 'year=[^}}]*', 'IgnoreCase')
        if($regex.Length -eq 0)
        {
            continue
        }
        $year = $regex.Value.Substring(5, 4)
        
        $date = $month + ' ' + $day + ' ' + $year
         
        $date = Get-Date $date -Format 'yyyy/MM/dd'
        $line = ('* ' + $date + ' [[' + $file + ']]')
        $result += $line
    }
    
    $result = $result | Sort-Object
    foreach($line in $result)
    {
        Write-Output $line
    }
}

function Show-PendingDeletions
{
    $files = @()
    $files += Get-CategoryImageInfo('Category:Pending deletions')
    $files += Get-CategoryImageInfo('Category:Files needing copyright information')
    $files = $files | Sort-Object -Property user, title

    Write-Output '== Unused Files =='
    $result = @()
    $hold = ''
    foreach($file in $files)
    {
        $links = @()
        $links += Get-ImageUsage $file.title
        $links += Get-BackLinks $file.title
        $links = Clean-Backlinks $links

        if($links.Count -eq 0)
        {
            if($hold -ne $file.user)
            {
                $hold = $file.user
                Write-Output (';[[User:' + $file.user + ']]')
            }
            Write-Output (':[[:' + $file.title + ']]')
            continue
        }

        foreach($link in $links)
        {
            $object = $file | Select-Object -Property title
            $object | Add-Member -type NoteProperty -Name 'link' -Value $link
            $result += $object | Select-Object -Property link, title
        }
    }

    Write-Output ''
    Write-Output '== Resource List and Linked Files =='
    $result = $result | Sort-Object -Property link, title
    $hold = ''
    foreach($file in $result)
    {
        if($hold -ne $file.link)
        {
            $hold = $file.link
            Write-Host (';[[' + $file.link + ']]')
        }
        Write-Host (':[[:' + $file.title + ']]')
    }
}

function Show-ProposedDeletions
{
    $files = Get-CategoryMembers('Category:Proposed deletions')
    $files = $files | Sort-Object

    Write-Output '== Proposed Deletions =='
    $result = @()
    foreach($file in $files)
    {
        $text = Get-Page $file
        $regex = [regex]::Match($text, '{{\s*proposed deletion\s*\|[^}]*}}', 'IgnoreCase')
        if($regex.Length -eq 0)
        {
            continue
        }
        $value = $regex.Value
        $regex = [regex]::Match($value, 'date=[^}]*', 'IgnoreCase')
        if($regex.Length -eq 0)
        {
            continue
        }
        $date = $regex.Value.Substring(5, $regex.Length - 5) 
        $date = Get-Date $date -Format 'yyyy/MM/dd'
        $line = ('* ' + $date + ' [[' + $file + ']]')
        $result += $line
    }
    
    $result = $result | Sort-Object
    foreach($line in $result)
    {
        Write-Output $line
    }
}

function Show-SisterLinks($wiki)
{
    $hold = $Global:wiki
    $Global:wiki = $wiki

    if($wiki -eq 'en.wikibooks.org')
    {
        $prefix = 'Wikibooks:'
    }
    elseif($wiki = 'en.wikipedia.org')
    {
        $prefix = 'Wikipedia:'
    }
    else
    {
        $prefix = ''
    }

    $pages = Get-EmbeddedIn("Template:Wikiversity")
    foreach($page in $pages)
    {
        $text = Get-Page $page.title
        while($true)
        {
            $regex = [regex]::Match($text, '{{Wikiversity[^}]*}}', 'IgnoreCase')
            if($regex.Length -eq 0)
            {
                break
            }
            $text = $text.Substring($regex.Index + $regex.Length)
            $value = $regex.Value

            if($regex.Value -imatch '{{Wikiversity}}')
            {
                Write-Output (':[[' + $prefix + $page.title + ']] -> [[' + $page.title + ']]')
                continue
            }

            $regex = [regex]::Match($value, 'at-link=[^|}]*[|}]', 'IgnoreCase')
            if($regex.Length -ne 0)
            {
                Write-Output (':[[' + $prefix + $page.title + ']] -> [[' + 
                    $regex.Value.Substring(8, $regex.Value.Length - 9) + ']]')
                continue
            }

            $regex = [regex]::Match($value, 'at=[^|}]*[|}]', 'IgnoreCase')
            if($regex.Length -ne 0)
            {
                Write-Output (':[[' + $prefix + $page.title + ']] -> [[' + 
                    $regex.Value.Substring(3, $regex.Value.Length - 4) + ']]')
                continue
            }

            $regex = [regex]::Match($value, '\|[^|}]*[|}]', 'IgnoreCase')
            if($regex.Length -ne 0)
            {
                Write-Output (':[[' + $prefix + $page.title + ']] -> [[' + 
                    $regex.Value.Substring(1, $regex.Value.Length - 2) + ']]')
                continue
            }

            Write-Output (':[[' + $prefix + $page.title + ']] -> [[' + $value + ']]')
        }
    }
    $Global:wiki = $hold     
}