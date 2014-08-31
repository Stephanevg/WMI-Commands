
#REgion V1.0
Function Get-WMICommands {
    <#
	.SYNOPSIS
		Returns all the commdlets available in the WMI module.

	.DESCRIPTION
		Returns all the cmdlets loaded through the WMI module..

	.EXAMPLE
		Get-WMICommands

	.Parameter Filter
		This parameter allows to filter on the commands to be returned.
	.NOTES
		Version: 1.1
        Author: Stephane van Gulick
        Creation date: 24.07.2014
        Last modification date: 24.07.2014
        history: Added filter possiblities.

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>
    [CmdletBinding()]
	Param(
	 [Parameter(Mandatory=$false,position=0)][string]$filter = "*"
	)

      
    Get-command -Module "WMI-Commands" -Name $filter
}

Function New-WMIClass {
<#
	.SYNOPSIS
		This function help to create a new WMI class.

	.DESCRIPTION
		The function allows to create a WMI class in the CimV2 namespace.
        Accepts a single string, or an array of strings.

	.PARAMETER  ClassName
		Specify the name of the class that you would like to create. (Can be a single string, or a array of strings).

    .PARAMETER  NameSpace
		Specify the namespace where class the class should be created.
        If not specified, the class will automatically be created in "Root\cimv2"

	.EXAMPLE
		New-WMIClass -ClassName "PowerShellDistrict"
        Creates a new class called "PowerShellDistrict"
    .EXAMPLE
        New-WMIClass -ClassName "aaaa","bbbb"
        Creates two classes called "aaaa" and "bbbb" in the Root\cimv2

	.NOTES
		Version: 1.0
        Author: Stephane van Gulick
        Creation date:16.07.2014
        Last modification date: 16.07.2014

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>
[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true,valueFromPipeLine=$true)][string[]]$ClassName,
        [Parameter(Mandatory=$false)][string]$NameSpace = "root\cimv2"
	
	)


        
        

        foreach ($NewClass in $ClassName){
            if (!(Get-WMIClass -ClassName $NewClass -NameSpace $NameSpace)){
                write-verbose "Attempting to create class $($NewClass)"
                    $WMI_Class = ""
                    $WMI_Class = New-Object System.Management.ManagementClass($NameSpace, $null, $null)
                    $WMI_Class.name = $NewClass
	                $WMI_Class.Put() | out-null
                
                write-output "Class $($NewClass) created."

            }else{
                write-output "Class $($NewClass) is already present. Skiping.."
            }
        }

}
					
Function New-WMIProperty {
<#
	.SYNOPSIS
		This function help to create new WMI properties.

	.DESCRIPTION
		The function allows to create new properties and set their values into a newly created WMI Class.
        Event though it is possible, it is not recommended to create WMI properties in existing WMI classes !

	.PARAMETER  ClassName
		Specify the name of the class where you would like to create the new properties.

	.PARAMETER  PropertyName
		The name of the property.

    .PARAMETER  PropertyValue
		The value of the property.

	.EXAMPLE
		New-WMIProperty -ClassName "PowerShellDistrict" -PropertyName "WebSite" -PropertyValue "www.PowerShellDistrict.com"

	.NOTES
		Version: 1.0
        Author: Stephane van Gulick
        Creation date:16.07.2014
        Last modification date: 16.07.2014

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>


[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$ClassName,

        [Parameter(Mandatory=$false)]
        [string]$NameSpace="Root\cimv2",

        [Parameter(Mandatory=$true)][string[]]$PropertyName,
        [Parameter(Mandatory=$false)][string]$PropertyValue=""

	
	)
    begin{
        [wmiclass]$WMI_Class = Get-WmiObject -Class $ClassName -Namespace $NameSpace -list
    }
    Process{
            write-verbose "Attempting to create property $($PropertyName) with value: $($PropertyValue) in class: $($ClassName)"
            $WMI_Class.Properties.add($PropertyName,$PropertyValue)
            Write-Output "Added $($PropertyName)."
    }
    end{
           		$WMI_Class.Put() | Out-Null
                [wmiclass]$WMI_Class = Get-WmiObject -Class $ClassName -list
                return $WMI_Class
    }

            
            
  
                    


}

Function Set-WMIPropertyValue {

<#
	.SYNOPSIS
		This function set a WMI property value.

	.DESCRIPTION
		The function allows to set a new value in an existing WMI property.

	.PARAMETER  ClassName
		Specify the name of the class where the property resides.

	.PARAMETER  PropertyName
		The name of the property.

    .PARAMETER  PropertyValue
		The value of the property.

	.EXAMPLE
		New-WMIProperty -ClassName "PowerShellDistrict" -PropertyName "WebSite" -PropertyValue "www.PowerShellDistrict.com"
        Sets the property "WebSite" to "www.PowerShellDistrict.com"
    .EXAMPLE
		New-WMIProperty -ClassName "PowerShellDistrict" -PropertyName "MainTopic" -PropertyValue "PowerShellDistrict"
        Sets the property "MainTopic" to "PowerShell"


	.NOTES
		Version: 1.0
        Author: Stephane van Gulick
        Creation date:16.07.2014
        Last modification date: 16.07.2014

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>


[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$ClassName,

        [Parameter(Mandatory=$false)]
        [string]$NameSpace="Root\cimv2",

        [Parameter(Mandatory=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$PropertyName,

        [Parameter(Mandatory=$true)]
        [string]$PropertyValue

	
	)
    begin{
         write-verbose "Setting new  value : $($PropertyValue) on property: $($PropertyName):"
         [wmiclass]$WMI_Class = Get-WmiObject -Class $ClassName -list
         

    }
    Process{
            $WMI_Class.SetPropertyValue($PropertyName,$PropertyValue)
            
    }
    End{
        $WMI_Class.Put() | Out-Null
        return Get-WmiObject -Class $ClassName -list
    }


}

Function Remove-WMIProperty{
<#
	.SYNOPSIS
		This function removes a WMI property.

	.DESCRIPTION
		The function allows to remove a specefic WMI property from a specefic WMI class.
        /!\Be aware that any wrongly deleted WMI properties could make your system unstable./!\

	.PARAMETER  ClassName
		Specify the name of the class name.

	.PARAMETER  PropertyName
		The name of the property.

	.EXAMPLE
		Remove-WMIProperty -ClassName "PowerShellDistrict" -PropertyName "MainTopic"
        Removes the WMI property "MainTopic".

	.NOTES
		Version: 1.0.1
        Author: Stephane van Gulick
        Creation date:21.07.2014
        Last modification date: 24.07.2014
        History: 21.07.2014 : Svangulick --> Creation
                 24.07.2014 : Svangulick --> Added new functionality
                 29.07.2014 : Svangulick --> Corrected minor bugs

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>


[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)][string]$ClassName,
        [Parameter(Mandatory=$true)][string]$PropertyName,
        [Parameter(Mandatory=$false)][string]$NameSpace = "Root\Cimv2",
        [Parameter(Mandatory=$false)][string]$Force 

	
	)
        if ($PSBoundParameters['NameSpace']){

            [wmiclass]$WMI_Class = Get-WmiObject -Class $ClassName -Namespace $NameSpace -list
        }
        else{
            write-verbose "Gaterhing data of $($ClassName)"
            [wmiclass]$WMI_Class = Get-WmiObject -Class $ClassName -list
        }
        if (!($force)){
             
            $Answer = Read-Host "Deleting $($PropertyName) can make your system unreliable. Press 'Y' to continue"
                if ($Answer -eq"Y"){
                    $WMI_Class.Properties.remove($PropertyName)
                    $WMI_Class.Put() | out-null
                    write-output "Property $($propertyName) removed."
                
                }else{
                    write-output "Uknowned answer. Class '$($PropertyName)' has not been deleted."
                }
            }#End force
        elseif ($force){
                $WMI_Class.Properties.remove($PropertyName)
                $WMI_Class.Put()
                write-output "Property $($propertyName) removed."
        }

           
        

}

Function Remove-WMIClass {

<#
	.SYNOPSIS
		This function removes a WMI class from the WMI repository.
        /!\ Removing a wrong WMI class could make your system unreliable. Use wisely and at your own risk /!\

	.DESCRIPTION
		The function deletes a WMI class from the WMI repository. Use this function wiseley as this could make your system unstable if wrongly used.

	.PARAMETER  ClassName
		Specify the name of the class that you would like to delete.

    .PARAMETER  NameSpace
		Specify the name of the namespace where the WMI class resides (default is Root\cimv2).
    .PARAMETER  Force
		Will delete the class without asking for confirmation.

	.EXAMPLE
		Remove-WMIClass -ClassName "PowerShellDistrict"
        This will launch an attempt to remove the WMI class PowerShellDistrict from the repository. The user will be asked for confirmation before deleting the class.

    .EXAMPLE
		Remove-WMIClass -ClassName "PowerShellDistrict" -force
        This will remove the WMI PowerShellDistrict class from the repository. The user will NOT be asked for confirmation before deleting the class.

	.NOTES
		Version: 1.0
        Author: Stephane van Gulick
        Creation date:18.07.2014
        Last modification date: 24.07.2014

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>


[CmdletBinding()]
	Param(
		[parameter(mandatory=$true,valuefrompipeline=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string[]]$ClassName,

        [Parameter(Mandatory=$false)]
        [string]$NameSpace = "Root\CimV2",

        [Parameter(Mandatory=$false)]
        [Switch]$Force
)

    
    write-verbose "Attempting to delete classes"
    foreach ($Class in $ClassName){
        if(!($Class)){
            write-verbose "Class name is empty. Skipping..."
        }else{
            [wmiclass]$WMI_Class = Get-WmiObject -Namespace $NameSpace -Class $Class -list
            if ($WMI_Class){
        
        
                if (!($force)){
                    
                    $Answer = Read-Host "Deleting $($Class) can make your system unreliable. Press 'Y' to continue"
                        if ($Answer -eq"Y"){
                            $WMI_Class.Delete()
                            write-output "$($Class) deleted."
                
                        }else{
                            write-output "Uknowned answer. Class '$($class)' has not been deleted."
                        }
                    }
                elseif ($force){
                    $WMI_Class.Delete()
                    write-output "$($Class) deleted."
                }
             }Else{
                write-output "Class $($Class) not present"
             }#End if WMI_CLASS
        }#EndIfclass emtpy
    }#End foreach
        
    
}

Function Import-MofFile{
 
 <#
	.SYNOPSIS
		This function will compile a mof file.

	.DESCRIPTION
		The function allows to create new WMI Namespaces, classes and properties by compiling a MOF file.
        Important: Using the Import-MofFile cmdlet, assures that the newly created WMI classes and Namespaces will also be recreated in case of WMI rebuild.

	.PARAMETER  MofFile
		Specify the complete path to the MOF file.

	.EXAMPLE
		Import-MofFile -MofFile C:\tatoo.mof

	.NOTES
		Version: 1.0
        Author: Stéphane van Gulick
        Creation date:18.07.2014
        Last modification date: 18.07.2014
        History : Creation : 18.07.2014 --> SVG

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>

[CmdletBinding()]
	Param(
        [Parameter(Mandatory=$true)]
		[ValidateScript({
        
        test-path $_
    
        })][string]$MofFile

	
	)
   
   begin{
   
    if (test-path "C:\Windows\System32\wbem\mofcomp.exe"){
        $MofComp = get-item "C:\Windows\System32\wbem\mofcomp.exe"
    }else{
        write-warning "MofComp.exe could not be found. The process cannot continue."
        exit
    }

   }
   Process{
       Invoke-expression "& $MofComp $MofFile"
       Write-Output "Mof file compilation actions finished."
   }
   End{
    
   }

}

Function Export-MofFile {
    
     <#
	.SYNOPSIS
		This function export a specefic class to a MOF file.

	.DESCRIPTION
		The function allows export specefic WMI Namespaces, classes and properties by exporting the data to a MOF file format.
        Use the Generated MOF file in whit the cmdlet "Import-MofFile" in order to import, or re-import the existing class.

	.PARAMETER  MofFile
		Specify the complete path to the MOF file.(Must contain ".mof" as extension.

	.EXAMPLE
		Export-MofFile -ClassName "PowerShellDistrict" -Path "C:\temp\PowerShellDistrict_Class.mof"

	.NOTES
		Version: 1.0
        Author: Stéphane van Gulick
        Creation date:18.07.2014
        Last modification date: 18.07.2014
        History : Creation : 18.07.2014 --> SVG

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>

    [CmdletBinding()]
    Param(
        [parameter(mandatory=$true)]
        [ValidateScript({
            $_.endsWith(".mof")
        })]
        [string]$Path,


        [parameter(mandatory=$true)]
        [string]$ClassName,

        [Parameter(Mandatory=$false)]
        [string]$NameSpace = "Root\CimV2"
	
	)

    begin{}
    Process{

    if ($PSBoundParameters['ClassName']){
        write-verbose "Checking for Namespace: $($Namespace) and Class $($Classname)"

        [wmiclass]$WMI_Info = Get-WmiObject -Namespace $NameSpace -Class $ClassName -list 

        }
    else{
        [wmi]$WMI_Info = Get-WmiObject -Namespace $NameSpace -list

    }

        [system.management.textformat]$mof = "mof"
        $MofText = $WMI_Info.GetText($mof)
        Write-Output "Exporting infos to $($path)"
        "#PRAGMA AUTORECOVER" | out-file -FilePath $Path
        $MofText | out-file -FilePath $Path -Append
        
        

    }
    End{

        return Get-Item $Path
    }

}

Function Get-WMIClass{
  <#
	.SYNOPSIS
		get information about a specefic WMI class.

	.DESCRIPTION
		returns the listing of a WMI class.

	.PARAMETER  ClassName
		Specify the name of the class that needs to be queried.

    .PARAMETER  NameSpace
		Specify the name of the namespace where the class resides in (default is "Root\cimv2").

	.EXAMPLE
		get-wmiclass
        List all the Classes located in the root\cimv2 namespace (default location).

	.EXAMPLE
		get-wmiclass -classname win32_bios
        Returns the Win32_Bios class.

	.EXAMPLE
		get-wmiclass -classname MyCustomClass
        Returns information from MyCustomClass class located in the default namespace (Root\cimv2).

    .EXAMPLE
		Get-WMIClass -NameSpace root\ccm -ClassName *
        List all the Classes located in the root\ccm namespace

	.EXAMPLE
		Get-WMIClass -NameSpace root\ccm -ClassName ccm_client
        Returns information from the cm_client class located in the root\ccm namespace.

	.NOTES
		Version: 1.0
        Author: Stephane van Gulick
        Creation date:23.07.2014
        Last modification date: 23.07.2014

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>
[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$false,valueFromPipeLine=$true)][string]$ClassName,
        [Parameter(Mandatory=$false)][string]$NameSpace = "root\cimv2"
	
	)  
    begin{
    write-verbose "Getting WMI class $($Classname)"
    }
    Process{
        if (!($ClassName)){
            $return = Get-WmiObject -Namespace $NameSpace -Class * -list
        }else{
            $return = Get-WmiObject -Namespace $NameSpace -Class $ClassName -list
        }
    }
    end{

        return $return
    }

}

#EndREgion

#Region V2.0





####-----TO DO -------------------###



#TODO: Add a foreach in the New-WMIProperty --> 2.5 ?
#Export mof file (include the namepsaces).
#Remove-WmiInstance AccepteValueFromPipeLine = $true for instanceName and class name (in order to alllow Get-WMiInstance -District | Remove-wmiInstance

#Nice to have
    #Create function to rebuild repository.
    #Ping back http://blogs.catapultsystems.com/jsandys/archive/2014/02/02/wmi-manipulations-and-manifestations.aspx

#---Done :
#Done: Add foreach in Remove-WMIClassInstance --> 2.5 ?
#TODO: Add a foreach and [] in remove-WMIProperty --> v2.5 ?

#---- Beta tests -----

Function Get-WMIProperty {
<#
	.SYNOPSIS
		This function gets a WMI property.

	.DESCRIPTION
		The function allows return a WMI property from a specefic WMI Class and located in a specefic NameSpace.

    .PARAMETER  NameSpace
		Specify the name of the namespace where the class resides in (default is "Root\cimv2").

	.PARAMETER  ClassName
		Specify the name of the class.

	.PARAMETER  PropertyName
		The name of the property.

	.EXAMPLE
		Get-WMIProperty -ClassName "PowerShellDistrict" -PropertyName "WebSite"
        Returns the property information from the WMI propertyName "WebSite"

    .EXAMPLE
		Get-WMIProperty -ClassName "PowerShellDistrict"
        Returns all the properties located in the "PowerShellDistrict" WMI class.

	.NOTES
		Version: 1.0
        Author: Stephane van Gulick
        Creation date:29.07.2014
        Last modification date: 12.08.2014

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>


[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$ClassName,

        [Parameter(Mandatory=$false)]
        [string]$NameSpace="Root\cimv2",

        [Parameter(Mandatory=$false)]
        [string]$PropertyName

    

	
	)
    begin{
         

    }
    process{
        If ($PropertyName){
            write-verbose "Returning WMI property $($PropertyName) from class $($ClassName) and NameSpace $($NameSpace)."
            $return = (Get-WMIClass -ClassName $ClassName -NameSpace $NameSpace ).properties["$($PropertyName)"]


         }else{
            write-verbose "Returning list of WMI properties from class $($ClassName) and NameSpace $($NameSpace)."
            $return = (Get-WMIClass -ClassName $ClassName -NameSpace $NameSpace ).properties

            
         } 
    }
    end{
        Return $return
    }  
}

Function Get-WMIPropertyQualifier {

<#
	.SYNOPSIS
		This function gets a WMI property qualifier.

	.DESCRIPTION
		The function allows return a WMI property qualifiers from a specefic WMI property, from a specific Class and located in a specefic NameSpace.

	.PARAMETER  ClassName
		Specify the name of the class.

	.PARAMETER  PropertyName
		The name of the property to retrive the qualifiers from.

	.EXAMPLE
		Get-WMIPropertyQualifier -ClassName "PowerShellDistrict" -PropertyName "WebSite"
        Returns the property qualifier information from the WMI propertyName "WebSite"


	.NOTES
		Version: 1.0
        Author: Stephane van Gulick
        Creation date:29.07.2014
        Last modification date: 29.07.2014

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>


[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$ClassName,

        [Parameter(Mandatory=$false)]
        [string]$NameSpace="Root\cimv2",

        [Parameter(Mandatory=$false)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$PropertyName

	
	)
    begin{
         write-verbose "getting property qualifiers from: $($PropertyName):"

    }
    process{
        
            write-verbose "Returning WMI property qualifiers $($PropertyName) from class $($ClassName) and NameSpace $($NameSpace)."
            $return = (Get-WMIProperty -NameSpace $NameSpace -ClassName $ClassName -PropertyName $PropertyName).qualifiers
         
    }
    end{
        Return $return
    }  


}

Function New-WMINameSpace {
<#
	.SYNOPSIS
		This function help to create a new WMI NameSpace.

	.DESCRIPTION
		The function allows to create a WMI nameSpace. Default path is "Root".
        Accepts a single string, or an array of strings.

	.PARAMETER  NameSpace
		Specify the name of the NameSpace that needs to be created. (Can be a single string, or a array of strings).

    .PARAMETER  Root
		Specify the root path where the NameSpace must be created. 
        If not specified, the NameSpace will automatically be created in "Root"

	.EXAMPLE
		New-WMINameSpace -NameSpace "PowerShellDistrict"
        Creates a new NameSpace called "PowerShellDistrict"

    .EXAMPLE
        New-WMINameSpace -NameSpace "PowerShellDistrict","MyNewNameSpace"
        Creates two NameSpaces called "PowerShellDistrict" and "MyNewNameSpace" in the 'Root' namespace (Default root).

    .EXAMPLE
        New-WMINameSpace -NameSpace "PowerShellDistrict"  -root 'Root\cimV2'
        Creates two NameSpaces called "PowerShellDistrict" in the 'Root\cimV2' namespace.

	.NOTES
		Version: 1.0
        Author: Stephane van Gulick
        Creation date:28.07.2014
        Last modification date: 28.07.2014

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>
[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true,valueFromPipeLine=$true)][string[]]$NameSpace,
        [Parameter(Mandatory=$false)][string]$Root = "root"
	
	)
begin{}
process{

        Foreach ($Nspace in $NameSpace){
            $Nspace = $([WMICLASS]"\\.\$($Root):__Namespace").CreateInstance()
            $Nspace.name = $NameSpace
            $Nspace.put()
        }
}
End{}

#TODO
<# 
$namespace = $([WMICLASS]"\\.\$($Root):__Namespace").CreateInstance()


$Namespace = New-Object -TypeName System.Management.ManagementObject
$Textpath = "Root\cimv2\New"
$MPath=[System.Management.ManagementPath]$Textpath

$DotNet= New-Object System.Management.ManagementObject($Mpath, $null, $null)

$ManagementScope = New-object System.Management.ManagementScope($MPath,$null)
#>
}

Function Set-WMIPropertyQualifier {
<#
	.SYNOPSIS
		This function sets a WMI property qualifier value.

	.DESCRIPTION
		The function allows to set a new property qualifier on an existing WMI property.

	.PARAMETER  ClassName
		Specify the name of the class where the property resides.

	.PARAMETER  PropertyName
		The name of the property.

    .PARAMETER  QualifierName
		The name of the qualifier.

    .PARAMETER  QualifierValue
		The value of the qualifier.

	.EXAMPLE
		Set-WMIPropertyQualifier -ClassName "PowerShellDistrict" -PropertyName "WebSite" -QualifierName Key -QualifierValue $true
        Sets the propertyQualifier "Key" on the property "WebSite"
    .EXAMPLE
		


	.NOTES
		Version: 1.0
        Author: Stephane van Gulick
        Creation date:16.07.2014
        Last modification date: 16.07.2014

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>


[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$ClassName,

        [Parameter(Mandatory=$false)]
        [string]$NameSpace="Root\cimv2",

        [Parameter(Mandatory=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$PropertyName,

        [Parameter(Mandatory=$false)]
        $QualifierName,

        [Parameter(Mandatory=$false)]
        $QualifierValue,

        [switch]$key,
        [switch]$IsAmended=$false,
        [switch]$IsLocal=$true,
        [switch]$PropagatesToInstance=$true,
        [switch]$PropagesToSubClass=$false,
        [switch]$IsOverridable=$true

	
	)

    #$Property = Get-WMIProperty -ClassName $className -NameSpace $NameSpace -PropertyName $PropertyName
    write-verbose "Setting  qualifier $($QualifierName) with value $($QualifierValue) on property $($propertyName) located in $($ClassName) in Namespace $($NameSpace)"
    $Class = Get-WMIClass -ClassName $ClassName -NameSpace $NameSpace

    if ($Key){
        $Class.Properties[$PropertyName].Qualifiers.Add("Key",$true)
        $Class.put()
        
        
    }else{
        $Class.Properties[$PropertyName].Qualifiers.add($QualifierName,$QualifierValue, $IsAmended,$IsLocal,$PropagatesToInstance,$PropagesToSubClass)
        $Class.put()
    }
    


}

Function Remove-WMIPropertyQualifier {
<#
	.SYNOPSIS
		This function removes a WMI qualifier from a specefic property.

	.DESCRIPTION
		The function allows remove a property qualifier from an existing WMI property (Or several ones).

	.PARAMETER  ClassName
		Specify the name of the class where the property resides.

	.PARAMETER  PropertyName
		The name of the property.

    .PARAMETER  QualifierName
		The name of the qualifier.

    .PARAMETER NameSpace
        Specify the name of the namespace where the class is located (default is Root\cimv2).

	.EXAMPLE
		Remove-WMIPropertyQualifier -ClassName "PowerShellDistrict" -PropertyName "WebSite" -QualifierName Key
        
	.NOTES
		Version: 1.0
        Author: Stephane van Gulick
        Creation date:16.07.2014
        Last modification date: 16.07.2014

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>


[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$ClassName,

        [Parameter(Mandatory=$false)]
        [string]$NameSpace="Root\cimv2",

        [Parameter(Mandatory=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$PropertyName,

        [Parameter(Mandatory=$false)]
        [string[]]$QualifierName

	
	)

    Begin{}
    Process{
        foreach ($Qualifier in $QualifierName){

            $Class = Get-WMIClass -ClassName $ClassName -NameSpace $NameSpace
            $Class.Properties[$PropertyName].Qualifiers.remove($QualifierName)
            $Class.put() | out-null
            Write-Output "The $($QualifierName) has been removed from $($PropertyName)"
        }

    }
    End{
    
    }  
        
    


}

Function Get-WMIClassInstance {
<#
	.SYNOPSIS
		Get a specefic WMI class instance.

	.DESCRIPTION
		The function allows to retrieve a specefic WMI class instance. If none is specified, all will be retrieved.

	.PARAMETER  ClassName
		Specify the name of the class where the instance resides.

	.PARAMETER NameSpace
        Specify the name of the namespace where the class is located (default is Root\cimv2).

    .PARAMETER  InstanceName
		Name of the Instance to retrieve. (value of the key property).

	.EXAMPLE
        Get-WMIClassInstance -ClassName PowerShellDistrict
        
        Returns all the instances located under the class "PowerShellDistrict".		

    .EXAMPLE
        Get-WMIClassInstance -ClassName PowerShellDistrict -InstanceName 001

        Returns the instance where the key property has a value of '001' located under the class "PowerShellDistrict".
		
	.NOTES
		Version: 1.0
        Author: Stephane van Gulick
        Creation date:16.07.2014
        Last modification date: 12.08.2014

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>


[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$ClassName,

        [Parameter(Mandatory=$false)]
        [string]$NameSpace="Root\cimv2",

        [Parameter(Mandatory=$false)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string[]]$InstanceName


	
	)
    Begin{
            $WmiClass = Get-WMIClass -NameSpace $NameSpace -ClassName $ClassName
    }
    Process{
            

            if (!($InstanceName)){
                $return = $WmiClass.getInstances()
            }else{
               $Instances = $WmiClass.getInstances()
               $KeyProperty = Get-WMIKeyPropertyQualifier -NameSpace $NameSpace -ClassName $ClassName

               $return = $Instances | where $KeyProperty.name -eq $InstanceName
            }
    }
    End{
        return $return

    }


}

Function Remove-WMIClassInstance {
<#
	.SYNOPSIS
		removes a specefic WMI class instance.

	.DESCRIPTION
		The function allows to remove a specefic WMI class instance.

	.PARAMETER  ClassName
		Specify the name of the class where the instance is.

	.PARAMETER NameSpace
        Specify the name of the namespace where the class is located (default is Root\cimv2).

    .PARAMETER  InstanceName
		Name of the Instance to retrieve.

	.EXAMPLE
        Remove-WMIClassInstance -ClassName PowerShellDistrict -InstanceName 001
        
        Deletes the instance called "001" located in the custom class "PowerShellDistrict".	(Will be prompted for confirmation).	

    .EXAMPLE
        Remove-WMIClassInstance -ClassName PowerShellDistrict -InstanceName 001 -force
        
        Deletes the instance called "001" located in the custom class "PowerShellDistrict".	(Will NOT be prompted for confirmation).
		
	.NOTES
		Version: 1.0
        Author: Stephane van Gulick
        Creation date:16.07.2014
        Last modification date: 12.08.2014

        History:
            12.08.2014 --> Changed the ConfirmImpact section.

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>


[CmdletBinding(SupportsShouldProcess = $true)]
	Param(
		[Parameter(Mandatory=$true,ValuefromPipeLine=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$ClassName,

        [Parameter(Mandatory=$false)]
        [string]$NameSpace="Root\cimv2",

        [Parameter(Mandatory=$false,ValuefromPipeLine=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$InstanceName,

        [switch]$Force,

        [switch]$RemoveAll


	
	)
    Begin{
            if (!($RemoveAll)){
                $WmiInstance = Get-WMIClassInstance -NameSpace $NameSpace -ClassName $ClassName -InstanceName $InstanceName
            }else{
                $WmiInstance = Get-WMIClassInstance -NameSpace $NameSpace -ClassName $ClassName
            }
    }
    Process{
            
            If ($RemoveAll){
                if (!($force)){
             
                    #$Answer = Read-Host "Deleting all the instances from $($ClassName) Are you sure? Press 'Y' to continue"
                            if ($PSCmdlet.ShouldContinue($_, "Are you sure ?") ){
                                
                                    foreach ($instance in $WmiInstance){
                                        if ($instance){
                                            $instance.Delete()
                                    
                                            Write-Output "Deleted $($instance) from class $($ClassName)"
                                            
                                        }
                                    }
                                    break
                
                            }else{
                                write-output "Uknowned answer. '$($WmiInstance)' has not been deleted."
                                break
                            }
                        }#End force
                    elseif ($force){
                            
                                    foreach ($instance in $WmiInstance){
                                        if ($instance){
                                            $instance.Delete()
                                    
                                            Write-Output "Deleted $($instance) from class $($ClassName)"
                                            
                                        }
                                    }
                                
                        }#EndElseif Force
            }
            
            if ($InstanceName){
                    if (!($force)){
             
                    #$Answer = Read-Host "Deleting $($InstanceName) from $($ClassName) Are you sure? Press 'Y' to continue"
                            if ($PSCmdlet.ShouldContinue($_,"Are you sure ??") ){
                                
                                    $WmiInstance.Delete()
                                    
                                    Write-Output "Deleted $($WmiInstance) from class $($ClassName)"
                                
                    
                
                            }else{
                                write-output "Uknowned answer. '$($WmiInstance)' has not been deleted."
                                break
                            }
                        }#End force
                    elseif ($force){
                            
                                    $WmiInstance.Delete()
                                    
                                    Write-Output "Delete $($WmiInstance) from class $($ClassName)"
                                
                        }#EndElseif Force
            else{
                write-warning "Could locate the instance $($InstanceName) in class $($ClassName)"
            }
        }
      }#endProcess
    
    End{
        return $return

    }


}

Function New-WMIClassInstance {
    <#
	.SYNOPSIS
		creates a new WMI class instance.

	.DESCRIPTION
		The function allows to retrieve a specefic WMI class instance. If none is specified, all will be retrieved.

	.PARAMETER  ClassName
		Specify the name of the class where the instance resides.

	.PARAMETER NameSpace
        Specify the name of the namespace where the class is located (default is Root\cimv2).

    .PARAMETER  InstanceName
		Name of the Instance to retrieve.

    .PARAMETER  PutInstance
		This parameter needs to be called once the instance has all of its properties set up.

	.EXAMPLE
        $MyNewInstance = New-WMIClassInstance -ClassName PowerShellDistrict -InstanceName "Instance01"
        
        Creates a new Instance name "Instance01" of the WMI custom class "PowerShellDistrict" and sets it in a variable for future use.

        The at least the key property set to a value. To get the key property of a class, use the Get-WMIKeyPropertyQualifier cmdlet.		

    .EXAMPLE
        New-WMIClassInstance -ClassName PowerShellDistrict -PutInstance $MyNewInstance

        Validates the changes and writes the new Instance persistantly into memory.
		
	.NOTES
		Version: 1.0
        Author: Stéphane van Gulick
        Creation date:16.07.2014
        Last modification date: 21.08.2014

	.LINK
		www.powershellDistrict.com
        
        My blog.

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

        My other projects and contributions.

#>


[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$ClassName,

        [Parameter(Mandatory=$false)]
        [string]$NameSpace="Root\cimv2",

        [Parameter(Mandatory=$false)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string[]]$InstanceName,

        [Parameter(valueFromPipeLine=$true)]$PutInstance


	
	)
    Begin{
            $WmiClass = Get-WMIClass -NameSpace $NameSpace -ClassName $ClassName
    }
    Process{
            
            if ($PutInstance){
                
                $PutInstance.Put()
            }else{
                $Return = $WmiClass.CreateInstance()
            }
          
    }
    End{

        If ($Return){
            return $Return
        }

    }
}

Function Get-WMIKeyPropertyQualifier {

<#
	.SYNOPSIS
		This function gets the WMI Key property qualifier from a specefic class.

	.DESCRIPTION
		This functions willl return an object of the key property of a specefic WMI class.
        This key property is the property that has to be specified when creating a new isntance of that class.

	.PARAMETER  ClassName
		Specify the name of the class.

	.PARAMETER NameSpace
        Specify the name of the namespace where the class is located (default is Root\cimv2).

	.EXAMPLE
		Get-WMIKeyPropertyQualifier -ClassName "PowerShellDistrict"
        Returns the property that has the key qualifier.


	.NOTES
		Version: 1.0
        Author: Stephane van Gulick
        Creation date:12.08.2014
        Last modification date: 12.08.2014

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>


[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)]
        [ValidateScript({
            $_ -ne ""
        })]
        [string]$ClassName,

        [Parameter(Mandatory=$false)]
        [string]$NameSpace="Root\cimv2"

	
	)
    begin{
         write-verbose "getting property qualifiers from: $($PropertyName):"
         $WmiClass = Get-WMIClass -NameSpace $NameSpace -ClassName $ClassName 
    }
    process{
                
            $Properties = Get-WMIProperty -NameSpace $NameSpace -ClassName $ClassName

            foreach ($Property in $Properties){
                
                $Qualifiers = Get-WMIPropertyQualifier -NameSpace $NameSpace -ClassName $ClassName -PropertyName $Property.name
                foreach ($Qualifier in $Qualifiers){
                    if ($Qualifier.name -eq "key"){
                        write-verbose "Key property for class $($ClassName) in NameSpace $($NameSpace) is $($Property.Name)."
                        return $Property
                    }
                }
                
            }

            
           
         
    }
    end{
        
    }  


}

Function Get-WMINameSpace {
  <#
	.SYNOPSIS
		get information about a specefic WMI NameSpace.

	.DESCRIPTION
		returns the listing of a WMI NameSpace.

	.PARAMETER  Name
		Specify the name of the namespace that needs to be queried.

    .PARAMETER  root
		Specify the name of the root where the namespace resides in (default is "Root").

	.EXAMPLE
		Get-WMINameSpace
        List all the NameSpaces located in the 'root' level. (default location).

	.EXAMPLE
		Get-WMINameSpace -Name "District"
        Returns information about the District class.

	.EXAMPLE
		Get-WMINameSpace -Root Root\cimv2
        Returns the namespaces located in Root\Cimv2

    .EXAMPLE
		Get-WMINameSpace -Name "District2" -root Root
        
	.NOTES
		Version: 1.0
        Author: Stephane van Gulick
        Creation date:15.08.2014
        Last modification date: 15.08.2014

	.LINK
		www.powershellDistrict.com

	.LINK
		http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/

#>
[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$false,valueFromPipeLine=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$false)][string]$Root = "root"
	
	) 
    Begin{}
    Process{
            
            if ($Name){
                $Return = Get-WMIObject -class __Namespace -namespace $Root -Filter "Name='$Name'"
            }else{
                $Return = Get-WMIObject -class __Namespace -namespace $Root
            }
    }
    End{
            return $Return
    }
}
#EndRegion
