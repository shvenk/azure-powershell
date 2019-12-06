# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------

<#
.SYNOPSIS
    Run AzureStack StorageAccounts admin tests

.DESCRIPTION
    Run AzureStack StorageAccounts admin tests using either mock client or our client.
	The mock client allows for recording and playback.  This allows for offline tests.

.PARAMETER RunRaw
    Run using our client creation path.

.EXAMPLE
    PS C:\> .\src\StorageAccount.Tests.ps1
    Describing StorageAccounts
 	  [+] TestListAllStorageAccounts 2.12s
 	  [+] TestGetStorageAccount 579ms
 	  [+] TestGetAllStorageAccounts 16.67s
.NOTES
    Author: Wenjia Lu
	Copyright: Microsoft
    Date:   August 14, 2019
#>
param(
    [bool]$RunRaw = $false,
    [bool]$UseInstalled = $false
)

$Global:UseInstalled = $UseInstalled
$global:RunRaw = $RunRaw
$global:TestName = ""

. $PSScriptRoot\CommonModules.ps1

InModuleScope Azs.Storage.Admin {

    Describe "StorageAccounts" -Tags @('StorageAccounts', 'Azs.Storage.Admin') {

        . $PSScriptRoot\Common.ps1

        BeforeEach {

            function ValidateStorageAccount {
                param(
                    [Parameter(Mandatory = $true)]
                    $storageAccount
                )
                # Resource
                $storageAccount								| Should Not Be $null

                # Validate Storage account properties
                $storageAccount.AccountStatus				| Should Not Be $null
                $storageAccount.AccountType					| Should Not Be $null
                $storageAccount.CreationTime				| Should Not Be $null
                $storageAccount.Id							| Should Not Be $null
                $storageAccount.Location					| Should Not Be $null
                $storageAccount.Name						| Should Not Be $null
                $storageAccount.PrimaryEndpoints			| Should Not Be $null
                $storageAccount.PrimaryLocation				| Should Not Be $null
                $storageAccount.ProvisioningState			| Should Not Be $null
                $storageAccount.StatusOfPrimary				| Should Not Be $null
                $storageAccount.TenantResourceGroupName		| Should Not Be $null
                $storageAccount.TenantStorageAccountName	| Should Not Be $null
                $storageAccount.TenantSubscriptionId		| Should Not Be $null
                $storageAccount.TenantViewId				| Should Not Be $null
                $storageAccount.Type						| Should Not Be $null
                $storageAccount.Kind						| Should Not Be $null
                $storageAccount.HealthState					| Should Not Be $null
            }

            function AssertAreEqual {
                param(
                    [Parameter(Mandatory = $true)]
                    $expected,
                    [Parameter(Mandatory = $true)]
                    $found
                )
                # Resource
                if ($null -eq $expected) {
                    $found												    | Should Be $null
                }
                else {
                    $found												    | Should Not Be $null
                    # Validate Storage account properties
                    $expected.AccountId | Should Be $found.AccountId
                    $expected.AccountStatus | Should Be $found.AccountStatus
                    $expected.AccountType | Should Be $found.AccountType
                }
            }
        }

        AfterEach {
            $global:Client = $null
        }

        it "TestListAllStorageAccounts" -Skip:$('TestListAllStorageAccounts' -in $global:SkippedTests) {
            $global:TestName = 'TestListAllStorageAccounts'

            $storageAccounts = Get-AzsStorageAccount -Location $global:Location -Summary:$false
            foreach ($storageAccount in $storageAccounts) {
                ValidateStorageAccount -storageAccount $storageAccount
            }
        }

        it "TestGetStorageAccount" -Skip:$('TestGetStorageAccount' -in $global:SkippedTests) {
            $global:TestName = 'TestGetStorageAccount'

            $storageAccounts = Get-AzsStorageAccount -Location $global:Location -Summary:$false
            foreach ($storageAccount in $storageAccounts) {
                $result = Get-AzsStorageAccount -Location $global:Location -Name $storageAccount.Name
                ValidateStorageAccount -storageAccount $result
                AssertAreEqual -expected $storageAccount -found $result
                return
            }
        }

        it "TestGetAllStorageAccounts" -Skip:$('TestGetAllStorageAccounts' -in $global:SkippedTests) {
            $global:TestName = 'TestGetAllStorageAccounts'

            $storageAccounts = Get-AzsStorageAccount -Location $global:Location -Summary:$false
            foreach ($storageAccount in $storageAccounts) {
                $result = Get-AzsStorageAccount -Location $global:Location -Name $storageAccount.Name
                ValidateStorageAccount -storageAccount $result
                AssertAreEqual -expected $storageAccount -found $result
            }
        }

        # Record new tests
        It "TestStartGarbageCollection" -Skip:$('TestStartGarbageCollection' -in $global:SkippedTests) {
            $global:TestName = 'TestStartGarbageCollection'

            Start-AzsReclaimStorageCapacity -Location $global:Location -Force
        }
    }
}
