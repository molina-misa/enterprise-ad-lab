Import-Module ActiveDirectory

$Users = Import-Csv -Path "../data/users.csv"

$DefaultPassword = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force

foreach ($User in $Users) {
    
    $SamAccountName = (
        $User.FirstName.Substring(0,1) + $User.LastName
        ).ToLower()

    $UPN = "$SamAccountName@agmimo.local"

    $DisplayName = "$($User.FirstName) $($User.LastName)"

    $OU = "OU=Users,OU=Enterprise Lab,DC=agmimo,DC=local"
        
    if(-not (Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'" -ErrorAction SilentlyContinue)){

        New-ADUser `
            -Name $DisplayName `
            -GivenName $User.FirstName `
            -Surname $User.LastName `
            -SamAccountName $SamAccountName `
            -UserPrincipalName $UPN `
            -DisplayName $DisplayName `
            -Title $User.Title `
            -Department $User.Department `
            -Path $OU `
            -AccountPassword $DefaultPassword `
            -Enabled $true `
            -ChangePasswordAtLogon $true 

        Write-Host "[SUCCESS] Created user: $DisplayName"

        switch ($User.Department) {
            "IT" {
                Add-ADGroupMember -Identity "IT Department" -Members $SamAccountName
                Write-Host "[INFO] Added $DisplayName to IT Department group"
            }
            "HR" {
                Add-ADGroupMember -Identity "HR Department" -Members $SamAccountName
                Write-Host "[INFO] Added $DisplayName to HR Department group"
            }
            "Sales" {
                Add-ADGroupMember -Identity "Sales Department" -Members $SamAccountName
                Write-Host "[INFO] Added $DisplayName to Sales Department group"
            }
            default {
                Write-Host "[INFO] No specific group assignment for department: $($User.Department)"
            }
        }
        Write-Host "[SUCCESS] Assigned RBAC permissions"
    }
    else {
        Write-Host "[WARNING] User $DisplayName already exists. Skipping creation."
    }
}