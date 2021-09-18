<#
Case:
    Hjelp meg å definere miljø for 'Bridgelaget underwood Tattle Tales' (b.u.t.t)
#>

# 1 type, variable reference
#Default, boring
$butts = @(
    (Get-Butt -type "master")
    (Get-Butt -type "Dick")
)
setup-butt -define $butts

# 2 type, powershell pipe
#The powershell way
Get-Butt -type "master","dick"| setup-butt

# 3 type, as configuration
#eksempler: Terraform/HCL, Arm, DSC
Setup-butt {
    Get-Butt -type "dick"
    Get-Butt -type "yoda"
}
