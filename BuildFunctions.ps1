function Send-Telegram-Notification {
	param ($Text)

	echo "Send notification: '$Text'"

	$notificationMessage = @{ "chat_id" = $env:TELEGRAM_NOTIFICATIONS_CHAT_ID; "text" = $Text }
	Invoke-RestMethod -Uri "https://api.telegram.org/bot$env:TELEGRAM_BOT_TOKEN/sendMessage" -Method Post -ContentType "application/json;charset=utf-8" -Body (ConvertTo-Json -Compress -InputObject $notificationMessage)
}

function Try-Create-FTP-Directory {
	param ($Destination)

	try {
		Create-FTP-Directory($Destination)
	}
	catch {
		echo "Directory exists or error received"
	}
}

function Create-FTP-Directory {
	param ($Destination)

	echo "Make directory $Destination"

	$client = [System.Net.WebRequest]::Create($Destination)
	$client.Credentials = New-Object System.Net.NetworkCredential($env:FTP_USER, $env:FTP_PASSWORD)
	$client.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory;
	$client.GetResponse();

	echo "Directory created"
}

function Upload-File-To-FTP {
	param ($Source, $Destination)

	$Source = Resolve-Path $Source
	echo "Upload file $Source to $Destination"

	$client = New-Object System.Net.WebClient
	$client.Credentials = New-Object System.Net.NetworkCredential($env:FTP_USER, $env:FTP_PASSWORD)
	$client.UploadFile($Destination, $Source)

	echo "Upload complete"
}

function Set-Build-Consts {
	$newContent = Get-Content -Path "$env:BUILD_CONSTS_PATH"
	$newContent = $newContent.replace("%CI_JOB_ID%", "$env:CI_JOB_ID")
	$newContent = $newContent.replace("%CI_JOB_NAME%", "$env:CI_JOB_NAME")
	$newContent = $newContent.replace("%CI_JOB_STAGE%", "$env:CI_JOB_STAGE")
	$newContent = $newContent.replace("%CI_PIPELINE_ID%", "$env:CI_PIPELINE_ID")
	$newContent = $newContent.replace("%CI_PIPELINE_IID%", "$env:CI_PIPELINE_IID")
	$newContent = $newContent.replace("%CI_RUNNER_ID%", "$env:CI_RUNNER_ID")
	$newContent = $newContent.replace("%CI_COMMIT_SHA%", "$env:CI_COMMIT_SHA")
	$newContent = $newContent.replace("%CI_COMMIT_SHORT_SHA%", "$env:CI_COMMIT_SHORT_SHA")
	$newContent = $newContent.replace("%CI_COMMIT_REF_NAME%", "$env:CI_COMMIT_REF_NAME")
	$newContent = $newContent.replace("%WF_SERVICE_VERSION%", "$env:WF_SERVICE_VERSION")
	$newContent = $newContent.replace("%CACHE_SERVICE_VERSION%", "$env:CACHE_SERVICE_VERSION")
	Set-Content -Path "$env:BUILD_CONSTS_PATH" -Value $newContent
}

function Set-Interface-Build-Consts
{
    $newContent = Get-Content -Path "$env:INTERFACE_PROJECT_FILE"
    $newContent = $newContent.replace("0</Version>", "$env:CI_PIPELINE_ID</Version>")
    Set-Content -Path "$env:INTERFACE_PROJECT_FILE" -Value $newContent
}