---
external help file: SherpaShell-help.xml
Module Name: SherpaShell
online version:
schema: 2.0.0
---

# Get-SDAuthConfig

## SYNOPSIS
Securely stores your authentication information in your user profile.

## SYNTAX

```
Get-SDAuthConfig [-Silent] [<CommonParameters>]
```

## DESCRIPTION
Encrypts and stores your API key, instance, and organization in your user profile\.sherpadesk\credentials.json.

## EXAMPLES

### Example 1
```powershell
PS C:\> Save-SDAuthConfig
```

This will store your API key in the default location.

## PARAMETERS

### -Silent
{{ Fill Silent Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

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
