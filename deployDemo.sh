if [ $# -lt 1 ]
  then
    echo "Usage: ./deploy.sh <scratch Org alias>"
    exit
fi   

sfdx force:org:create -f config/project-scratch-def.json -a $1 -d 30 -s &&
sfdx force:source:push 

sfdx force:data:record:update -s User -w "Name='User User'" -v "FirstName='Admin' LastName='Harsh' Alias=hbhag TimeZoneSidKey='Asia/Kolkata' LocaleSidKey=en_US LanguageLocaleKey=en_US EmailEncodingKey='UTF-8'" -u $1 &&
sfdx force:user:create username=sajesh@$1 email=sajesh.radhakrishnan@salesforce.com FirstName=Sajesh LastName=Radhakrishnan Alias=sajesh -s generatepassword=false profileName="Interviewer" -u $1 &&
sfdx force:user:create username=kpahlajani@$1 email=kpahlajani@salesforce.com FirstName=Kumar LastName=Pahlajani Alias=kpahl -s generatepassword=false profileName="Platform Interviewer" -u $1 &&
sfdx force:user:create username=katyam@$1 email=me@my.org FirstName=Kumar LastName=Atyam Alias=katyam -s generatepassword=false profileName="Platform Interviewer" -u $1 &&
sfdx force:user:create username=vipul@$1 email=me@my.orgm FirstName=Vipul LastName=Jain Alias=vipul -s generatepassword=false profileName="Platform Interviewer" -u $1 &&

sfdx sfdmu:run --sourceusername csvfile --targetusername $1 --path force-app/main/default/staticresources/DemoData --verbose