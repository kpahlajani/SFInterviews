if [ $# -lt 1 ]
  then
    echo "Usage: ./deploy.sh <scratch Org alias>"
    exit
fi   

sfdx force:org:create -f config/project-scratch-def.json -a $1 -d 30 -s &&
sfdx force:source:push 

scratchUser=`sfdx force:org:display| tail -1 | awk -F" " '{print($2)}'`
USERNAME=`sfdx force:data:record:get -s User -w "Username=${scratchUser}"|grep "Email:" | grep "@salesforce.com" | awk -F " " '{print($2)}' | awk -F"@" '{print($1)}'`

sfdx force:user:create username=${USERNAME}@$1 email=${USERNAME}@salesforce.com FirstName=Main LastName=Interviewer Alias=main -s generatepassword=false profileName="Interviewer" -u $1 &&
sfdx force:user:create username=jsmith@$1 email=me@my.org FirstName=Joel LastName=Smith Alias=jsmith -s generatepassword=false profileName="Platform Interviewer" -u $1 &&
sfdx force:user:create username=jdoe@$1 email=me@my.org FirstName=John LastName=Doe Alias=jdoe -s generatepassword=false profileName="Platform Interviewer" -u $1 &&
sfdx force:user:create username=xli@$1 email=me@my.orgm FirstName=Xi LastName=Li Alias=xli -s generatepassword=false profileName="Platform Interviewer" -u $1 &&

sfdx sfdmu:run --sourceusername csvfile --targetusername $1 --path force-app/main/default/staticresources/DemoData --verbose



