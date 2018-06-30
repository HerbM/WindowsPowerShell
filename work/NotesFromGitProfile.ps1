
new-alias np S:\Programs\Portable\Notepad++Portable\Notepad++Portable.exe -force -scope global

<#
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force                                                          
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass                                                        
.\Import-SNPTimeSheet.ps1                                                                                         
.\Import-SNPTimeSheetV3-5.ps1                                                                                     

  while ($true) {
    
  }
  
get-item .\Import-SNPTimeSheetV3-5.ps1 -stream *                                                                  
Set-ExecutionPolicy -Scope LocalMachine  -ExecutionPolicy RemoteSigned                                            
Set-ExecutionPolicy -Scope LocalMachine  -ExecutionPolicy RemoteSigned                                            
Set-ExecutionPolicy -Scope LocalMachine  -ExecutionPolicy RemoteSigned -force                                     
get-ExecutionPolicy   -scope CurrentUser                                                                          
get-ExecutionPolicy   -scope Process                                                                              
$env:psmodulepath -split ';'                                                                                      
md WindowsPowerShell                                                                                              
cd .\WindowsPowerShell\                                                                                           
where.exe git                                                                                                     
git --version                                                                                                     
dir -force     

####
cd (Split-Path $Profile)
git init                                                                                                                                                                                        
git remote add HerbProfile https://github.com/HerbM/WindowsPowerShell                                             
git remote -v                                                                                                     
git fetch --all                                                                                                   
git reset --hard HerbProfile/master                                                                               
git pull HerbProfile master                                                                                       
####
cd S:\Programs\Portable\                                                                                          

#>
