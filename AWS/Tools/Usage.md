# AmazonFSxADValidation
* Install-WindowsFeature RSAT-AD-PowerShell
* Invoke-WebRequest "https://docs.aws.amazon.com/fsx/latest/WindowsGuide/samples/AmazonFSxADValidation.zip" -OutFile "AmazonFSxADValidation.zip"
* Expand-Archive -Path "AmazonFSxADValidation.zip"
* Import-Module .\AmazonFSxADValidation
* $ADControllerIp = '192.0.75.243'
* $Result = Test-FSxADControllerConnection -ADControllerIp $ADControllerIp
* $Result
* $Result.TcpDetails

