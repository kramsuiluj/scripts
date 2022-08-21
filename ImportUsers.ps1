# Import Active Directory Module
Import-Module ActiveDirectory

# Save .csv file objects into a variable.
$users = Import-Csv "C:\Scripts\UsersCSV.csv"

# Loop through the objects from the $users variable.
foreach ($user in $users) {
    # Store each of the object parameters into a variable.
    $username = ''
    $firstname = $user.'First Name'
    $lastname = $user.'Last Name'
    $ou = $user.'Organizational Unit'
    $password = $user.Password

    if ($firstname.Contains(' ')) {
        $firstname.Split(' ') | foreach {
            $username += $_[0]
        }
        $username += $lastname
    } else {
        $username += "$($firstname[0])$($lastname)"
    }

    if (Get-AdUser -Filter {SamAccountName -eq $username}) {
        Write-Warning "The user you are trying to add already exist."
    } else {
        New-AdUser `
        -SamAccountName $username `
        -UserPrincipalName "$username@wsc2019.ru" `
        -Name "$firstname $lastname" `
        -DisplayName "$lastname, $firstname" `
        -GivenName $firstname `
        -Surname $lastname `
        -Path $ou `
        -Enabled $true `
        -AccountPassword (ConvertTo-SecureString -AsPlainText -Force) `
        -ChangePasswordAtLogon $false

        if ($user.'AddToGroups(csv)' -ne '') {
            $user.'AddToGroups(csv)'.Split(',') | foreach {
                New-AdGroupMember -Identity $_ -Members $username
            }
        }

        Write-Host "$firstname $lastname has been successfully added into the Active Directory Users."
    }
}