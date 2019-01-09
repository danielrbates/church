﻿$usersandgroups = @{}

$users = net user
$users = $users[4..($users.length-3)]
$users = $users -split '\s+' | where {$_ -ne ""}

foreach ($username in $users) {
    $group = net user $username | select-string "Local Group Memberships"
    $group = ($group -split '\*')[1]
    $usersandgroups.Add($username,$group)
    if (($group -eq $null) -or ($group -eq "")) {
        echo "The user $username is not a member of any group."
        } Else {
        echo "The user $username is a member of the following group(s): $group"
        }
    }