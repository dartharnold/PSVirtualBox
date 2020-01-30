Function Open-VBoxMachineConsole {

  <#
  .SYNOPSIS
  Open a virtual machine console that is running headless
  .DESCRIPTION
  Open a console window for a headless virtual box machines.
  .PARAMETER Name
  The name of a virtual machine. IMPORTANT: Names are case sensitive.
  .EXAMPLE
  PS C:\> Open-VBoxMachineConsole "Win7"
  Open the console for virtual machine called Win7.
  .NOTES
  NAME        :  Open-VBoxMachineConsole
  VERSION     :  0.1
  LAST UPDATED:  1/31/2020
  AUTHOR      :  Jeffrey Arnold
  .LINK
  Get-VBoxMachine
  Start-VBoxMachine
  Stop-VBoxMachine
  Suspend-VboxMachine
  Suspend-VboxMachineByID
  .INPUTS
  Strings
  .OUTPUTS
  None
  #>
  
  [cmdletbinding()]
  Param(
  [Parameter(Position=0,Mandatory=$True,HelpMessage="Enter a virtual machine name",
  ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
  [ValidateNotNullorEmpty()]
  [string[]]$Name,
  )
  
  Begin {
      Write-Verbose "Starting $($myinvocation.mycommand)"
     #get global vbox variable or create it if it doesn't exist create it
      if (-Not $global:vbox) {
          $global:vbox = Get-VirtualBox
      }
  }#Begin
  
  Process {
      foreach ($item in $name) {
        #get the virtual machine
        runVMachine $item
      } #foreach
  } #process
  
  End {
      Write-Verbose "Ending $($myinvocation.mycommand)"
  } #End
  
  } #end function

  Function runVMachine {
  Param (
    [Parameter(Position=0, Mandatory=$True)]
    [Object] $member,
    [Parameter(Position=1, Mandatory=$False)]
    [Bool] $Headless
    #add switch for console and use it to change behaver of this function.
  )
  Begin{}
  Process {
    $vmachine=$vbox.FindMachine($member)
    $environmentChanges = New-Object string[] 0
    if ($vmachine) {
      #create Vbox session object
      Write-Verbose "Creating a session object"
      $vsession = New-Object -ComObject "VirtualBox.Session"
      if ($vmachine.State -lt 5) {
        if ($Headless) {
          Write-Verbose "Starting in headless mode"
          $vmachine.LaunchVMProcess($vsession,"headless",$environmentChanges).OperationDescription
        } else {
          $vmachine.LaunchVMProcess($vsession,"separate",$environmentChanges).OperationDescription
        } #Headless
      } else {
        Write-Host $vmachine.name -NoNewline -ForegroundColor White
        Write-Host " is already started." -NoNewline -ForegroundColor Yellow
        Write-Host "Skipping".PadLeft(40 - $vmachine.name.Length) -ForegroundColor red
      } #State
    } else {
      Write-Host "I can only start machines that have been stopped." -ForegroundColor Magenta
    } #if vmachine

  } #process
  End{}
}