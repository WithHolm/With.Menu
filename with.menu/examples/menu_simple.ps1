New-Menu 'Simple menu' {
    New-MenuChoice "Invoke inline code or script" {
        1..2|%{
            Write-Host "Waiting $_"
            Start-Sleep -Seconds 1
        }
    }
    New-MenuChoice "Return string" "Somevalue"
    New-Menu 'Show submenu'{
        New-MenuChoice "sub menu choice" {return $true}
    }
}