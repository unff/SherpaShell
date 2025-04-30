---
external help file: SherpaShell-help.xml
Module Name: SherpaShell
online version:
schema: 2.0.0
---

# Get-SDAsset

## SYNOPSIS
Gets all assets for the selected Organization

## SYNTAX

```
Get-SDAsset [-Key <String>] [-Organization <String>] [-Instance <String>] [-ApiKey <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
You sign in by SD-GetAPIKey -Email <email address>, then run Get_SDMetadata.  If you have more than one org assigned to your login, choose the org you are working with.
Get-SDAsset currently only can grab all assets.  

## EXAMPLES

### Example 1 - Get all Assets for your organization
```powershell
PS C:\> Get-SDAsset
```

## PARAMETERS

### -ApiKey
Optional.  This is stored in a script-level variable after you run Get-SDAPIKey

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Instance
Optional.  This is stored in a script-level variable after you run Get-SDMetadata

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Key
Deprecated.  New API uses a GET Body that hasn't been coded yet.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Organization
Optional.  This is stored in a script-level variable after you run Get-SDMetadata

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
No progress action until SherpaDesk actually implements their Content-Range header

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
