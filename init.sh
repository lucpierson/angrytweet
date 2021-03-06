#!/bin/sh 
DEMO="AngryClaim Demo"
AUTHORS="Bernard TISON, Luc Pierson"
PROJECT="git@github.com/lucpierson/AngryClaim" 
PRODUCT="JBoss FUSE Service works + BPM Suite BAM"
AG_DEMO_HOME=~/AngryClaim
AG_SRC_DIR=$AG_DEMO_HOME/installs
AG_FSW_HOME=$AG_DEMO_HOME/target_fsw/jboss-eap-6.1
AG_FSW_CONF=$AG_FSW_HOME/standalone/configuration/
AG_RTG_HOME=$AG_DEMO_HOME/target_RtGov/jboss-eap-6.1
AG_RTG_CONF=$AG_RTG_HOME/standalone/configuration/
AG_BAM_HOME=$AG_DEMO_HOME/target_bpms/jboss-eap-6.1
AG_BAM_CONF=$AG_BAM_HOME/standalone/configuration/
AG_CRM_HOST=localhost
AG_CRM_PORT=8080
EAP=jboss-eap-6.1.1.zip
BPMS=jboss-bpms-6.0.2.GA-redhat-5-deployable-eap6.x.zip
FSW=jboss-fsw-installer-6.0.0.GA-redhat-4.jar
RTG=jboss-fsw-installer-6.0.0.GA-redhat-4.jar
VERSION=AngryClaim.V2

# CSV Directory to Scan
AG_csvInputDir=$AG_DEMO_HOME/etc/csv/demo/



# wipe screen.
clear 

echo
echo "#################################################################"
echo "##                                                             ##"   
echo "##  Setting up the ${DEMO} "
echo "##                                                             ##"   
echo "##                                                             ##"   
echo "##  brought to you by,                                         ##"   
echo "##   ${AUTHORS} "
echo "##                                                             ##"   
echo "##  ${PROJECT} "  
echo "##                                                             ##"   
echo "#################################################################"
echo
echo " remember to add your own parameters in  the following files"
echo "     ./installs/twitter.env.sh"
echo "     ./installs/gmail.env.sh"
echo
read -n 1 -p 'Press any key to continue or [CTL]+C to stop' 



test -L "$AG_DEMO_HOME/installs/twitter.env.sh" || test -f "$AG_DEMO_HOME/installs/twitter.env.sh" || { echo  $AG_DEMO_HOME/installs/twitter.env.sh 'is not present in installs directory.... aborting.'; exit 1; }
source $AG_DEMO_HOME/installs/twitter.env.sh
test -L "$AG_DEMO_HOME/installs/gmail.env.sh" || test -f "$AG_DEMO_HOME/installs/gmail.env.sh" || { echo  $AG_DEMO_HOME/installs/gmail.env.sh 'is not present in installs directory.... aborting.'; exit 1; }
source $AG_DEMO_HOME/installs/gmail.env.sh

#env | grep AG_
#exit 1


#echo "creating system variables"
#echo
#echo "# AngryClaim demo variables" >>  ~/.bash_profile
#echo 'export AG_consumerKey="'$AG_consumerKey'"' >> ~/.bash_profile
#echo 'export AG_consumerSecret="'$AG_consumerSecret'"' >> ~/.bash_profile
#echo 'export AG_accessToken="'$AG_accessToken'"' >> ~/.bash_profile
#echo 'export AG_accessTokenSecret="'$AG_accessTokenSecret'"' >> ~/.bash_profile
#echo 'export AG_sinceId="'$AG_sinceId'"' >> ~/.bash_profile
#echo 'export AG_csvInputDir="'$AG_csvInputDir'"' >> ~/.bash_profile
#echo 'export AG_emailserverhost="'$AG_emailserverhost'"' >> ~/.bash_profile
#echo 'export AG_emailserverusername="'$AG_emailserverusername'"' >> ~/.bash_profile
#echo 'export AG_emailserverpassword="'$AG_emailserverpassword'"' >> ~/.bash_profile


echo "verifying  and updating MVN installation"
command -v mvn -q >/dev/null 2>&1 || { echo >&2 "Maven is required but not installed yet... aborting."; exit 1; }
mv ~/.m2/settings.xml ~/.m2/settings.xml.save
cp $AG_DEMO_HOME/etc/mvn_config/settings.xml ~/.m2/settings.xml
echo


echo "verifying that MySQL is installed and started"
AG_FICHIER=/usr/share/java/mysql-connector-java.jar
test -L "$AG_FICHIER" || test -f "$AG_FICHIER" || { echo "MySQL is required but not installed yet. Please launch yum install mysql* .... aborting."; exit 1; }
service mysqld status ||  { echo "mysql server is not up.... aborting."; exit 1; }
echo

echo "verifying that JDK is installed"
javac -version>/dev/null || { echo "java jdk is required but not installed yet. .... aborting."; exit 1; }
echo

echo "creating MySQL user and schemas"
mysql -u root -h localhost -e"CREATE USER 'jboss'@'localhost' IDENTIFIED BY 'jboss';"
mysql -u root -h localhost -e"GRANT ALL PRIVILEGES ON * . * TO 'jboss'@'localhost';"
mysql -u root -h localhost -e"FLUSH PRIVILEGES;"
mysql -u jboss -pjboss -h localhost -e"create schema angrytweet;"
mysql -u jboss -pjboss -h localhost -e"create schema bpmsdemo;" || { echo "Error in creating required databases. Please check and try again....."; exit 1; }
echo

# make some checks first before proceeding.	
if [[ -r $AG_SRC_DIR/$EAP || -L $AG_SRC_DIR/$EAP ]]; then
		echo EAP sources are present...
		echo
else
		echo Need to download $EAP package from the Customer Portal 
		echo and place it in the $AG_SRC_DIR directory to proceed...
		echo
		exit
fi

# Create the target directory if it does not already exist.
  echo "  - creating the target directory..."
  echo
  rm -rf target_fsw
  rm -rf target_RtGov
  rm -rf target_bpms
  mkdir target_fsw
  mkdir target_bpms
#  mkdir target_RtGov
  echo

# Unzip the JBoss EAP instance.
  echo Unpacking JBoss Enterprise EAP 6...
  echo
  unzip -q -d target_bpms $AG_SRC_DIR/$EAP

# Unzip the required files from JBoss product deployable.
  echo "Unpacking BPMS"
  echo
  unzip -q -o -d target_bpms $AG_SRC_DIR/$BPMS
  cd ~

# install FSW using installation script
  echo "Installing FSW"
#echo "     $AG_SRC_DIR/$FSW :" $AG_SRC_DIR/$FSW
#echo "     $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml : " $AG_SRC_DIR/$FSW $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml
#echo "     $AG_DEMO_HOME/etc/FSW_ServerInstallScript.variables : " $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml.variables

  if [[ -r $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml && -r $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml.variables ]]; then
		echo XML scripts are present...
                cp $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml.save --force
                sed -i "s|REPERTOIRE|$AG_DEMO_HOME|" $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml
                # SED : substiture string "REPERTOIRE" with $AG_DEMO_HOME variable
                cd $AG_DEMO_HOME
                java -jar $AG_SRC_DIR/$FSW $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml -variablefile $AG_DEMO_HOME/etc/FSW_ServerInstallScript.xml.variables
		echo
  else
		echo "Need to verify that FSW XML installation sript is named as FSW_ServerInstallScript.xml"
		echo "and placed in the " $AG_SRC_DIR/$FSW ll$AG_DEMO_HOME "/etc directory "
		echo "bye for now..."
		exit
  fi
  cd ~


# updating server configurations


echo "  - enabling demo accounts logins in application-users.properties file..."
echo 
  cp $AG_DEMO_HOME/etc/application-users.properties $AG_BAM_CONF  || { echo "application-users.properties not in /.etc.... aborting."; exit 1; }

echo "  - enabling demo accounts role setup in application-roles.properties file..."
echo
  cp $AG_DEMO_HOME/etc/application-roles.properties $AG_BAM_CONF || { echo "application-roles.properties not in /.etc.... aborting."; exit 1; }

echo "  - enabling management accounts login setup in mgmt-users.properties file..."
echo
  cp $AG_DEMO_HOME/etc/mgmt-users.properties $AG_BAM_CONF || { echo "mgmt-users.properties not in /.etc.... aborting."; exit 1; }

echo "  - setting up standalone.xml configuration adjustments..."
echo
   cp  $AG_DEMO_HOME/etc/standalone.FSW.xml $AG_FSW_CONF/standalone.xml
   cp  $AG_DEMO_HOME/etc/standalone.BAM.xml $AG_BAM_CONF/standalone.xml

echo "  - turn off security profile for performance in standalone.conf..."
echo
   sed -i 's|JAVA_OPTS=\"$JAVA_OPTS -Djava.security.manager|#JAVA_OPTS=\"$JAVA_OPTS -Djava.security.manager|g' $AG_FSW_HOME/bin/standalone.conf
   sed -i 's|JAVA_OPTS=\"$JAVA_OPTS -Djava.security.manager|#JAVA_OPTS=\"$JAVA_OPTS -Djava.security.manager|g' $AG_BAM_HOME/bin/standalone.conf

#turn on /home/lpierson/AngryClaim/target_fsw/jboss-eap-6.1/standalone/configuration/overlord-rtgov.properties (collectionEnabled)
echo "  - turn on /home/lpierson/AngryClaim/target_fsw/jboss-eap-6.1/standalone/configuration/overlord-rtgov.properties (collectionEnabled)"

   sed -i 's|collectionEnabled=false|collectionEnabled=true|g' $AG_FSW_HOME/standalone/configuration/overlord-rtgov.properties


echo "  - additional options  in FSW standalone.conf..."
echo
   echo "# AngryClaim options for Twitter and gmail account" >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -DconsumerKey=$AG_consumerKey"' >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -DconsumerSecret=$AG_consumerSecret"' >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -DaccessToken=$AG_accessToken"' >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -DaccessTokenSecret=$AG_accessTokenSecret"' >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -DsinceId=$AG_sinceId"' >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -DcsvInputDir=$AG_csvInputDir"' >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -Demail.server.host=$AG_emailserverhost"' >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -Demail.server.username=$AG_emailserverusername"' >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -Demail.server.password=$AG_emailserverpassword"' >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -Dcrm.host=$AG_CRM_HOST"' >> $AG_FSW_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -Dcrm.port=$AG_CRM_PORT"' >> $AG_FSW_HOME/bin/standalone.conf



echo "  - additional options  in BAM standalone.conf..."
echo
   echo "# AngryClaim options add offset 100 - for demo BAM on business-central" >> $AG_BAM_HOME/bin/standalone.conf
   echo 'JAVA_OPTS="$JAVA_OPTS -Djboss.socket.binding.port-offset=10000"' >>  $AG_BAM_HOME/bin/standalone.conf
   sed -i 's|</dependencies>|<module name="com.mysql" />\n</dependencies>|g ' $AG_BAM_HOME/standalone/deployments/dashbuilder.war/WEB-INF/jboss-deployment-structure.xml


### Create demo directory for input CSV files
   mkdir -p  $AG_csvInputDir



### Camel-twitter configuration
   mkdir -p                                                                           $AG_FSW_HOME/modules/system/layers/soa/org/apache/camel/twitter/main
   cp $AG_DEMO_HOME/etc/modules/camel-twitter/module.xml                              $AG_FSW_HOME/modules/system/layers/soa/org/apache/camel/twitter/main
   cp $AG_DEMO_HOME/etc/modules/camel-twitter/camel-twitter-2.10.0.redhat-60024-1.jar $AG_FSW_HOME/modules/system/layers/soa/org/apache/camel/twitter/main

####Installation of the twitter4j module
   mkdir -p                                             $AG_FSW_HOME/modules/system/layers/soa/org/twitter4j/main
   cp $AG_DEMO_HOME/etc/modules/twitter4j/module.xml    $AG_FSW_HOME/modules/system/layers/soa/org/twitter4j/main
   cp $AG_DEMO_HOME/installs/twitter4j-core-3.0.5.jar   $AG_FSW_HOME/modules/system/layers/soa/org/twitter4j/main
   cp $AG_DEMO_HOME/installs/twitter4j-stream-3.0.5.jar $AG_FSW_HOME/modules/system/layers/soa/org/twitter4j/main

# copy CRM MOK file
   cp $AG_DEMO_HOME/etc/crm/crm.properties $AG_FSW_CONF

# create and copy mysql jar dependences files on FSW
   mkdir -p                                       $AG_FSW_HOME/modules/system/layers/base/com/mysql/main
   ln -s /usr/share/java/mysql-connector-java.jar $AG_FSW_HOME/modules/system/layers/base/com/mysql/main/mysql-connector-java.jar
   cp $AG_DEMO_HOME/etc/mysql/module.xml          $AG_FSW_HOME/modules/system/layers/base/com/mysql/main

# create and copy mysql jar dependences files on BAM
   mkdir -p                                       $AG_BAM_HOME/modules/system/layers/base/com/mysql/main
   ln -s /usr/share/java/mysql-connector-java.jar $AG_BAM_HOME/modules/system/layers/base/com/mysql/main/mysql-connector-java.jar
   cp $AG_DEMO_HOME/etc/mysql/module.xml          $AG_BAM_HOME/modules/system/layers/base/com/mysql/main
  
# create maven dependency to twitter modules
   mkdir -p                                            ~/.m2/repository/org/apache/camel/camel-twitter/2.10.0.redhat-60024-1
   cp    $AG_DEMO_HOME/etc/modules/camel-twitter/cam*  ~/.m2/repository/org/apache/camel/camel-twitter/2.10.0.redhat-60024-1
   cd    $AG_DEMO_HOME

# update BAM persistency Dialect
sed -i 's|<property name="hibernate.dialect" value="org.hibernate.dialect.H2Dialect" />|<property name="hibernate.dialect" value="org.hibernate.dialect.MySQL5Dialect"/>|g' $AG_BAM_HOME/standalone/deployments/business-central.war/WEB-INF/classes/META-INF/persistence.xml

echo
echo "creating BAM Users"
$AG_BAM_HOME/bin/add-user.sh -a admin redhat123@
echo 'admin=analyst,admin' >> $AG_BAM_CONF/application-roles.properties

echo
echo "Creating Launchers  : FSW_Launch.sh and BAM_Launch.sh"

echo "#!/bin/sh" >> $AG_DEMO_HOME/FSW_Launch.sh
echo "echo Launch Fuse Service works for Demo AngryClaim" >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'service mysqld status ||  { echo \"mysql server is not up.... aborting.\"; exit 1; }'>> $AG_DEMO_HOME/FSW_Launch.sh
cat ./etc/setSinceId.txt >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_consumerKey=\"'$AG_consumerKey'\"' >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_consumerSecret=\"'$AG_consumerSecret'\"' >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_accessToken=\"'$AG_accessToken'\"' >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_accessTokenSecret=\"'$AG_accessTokenSecret'\"' >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_csvInputDir='$AG_csvInputDir >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_emailserverhost=\"'$AG_emailserverhost'\"' >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_emailserverusername=\"'$AG_emailserverusername'\"' >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_emailserverpassword=\"'$AG_emailserverpassword'\"' >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_CRM_HOST=\"'$AG_CRM_HOST'\"' >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'export AG_CRM_PORT=\"'$AG_CRM_PORT'\"' >> $AG_DEMO_HOME/FSW_Launch.sh
echo ' ' >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'echo environment variables attached to the demo : '>> $AG_DEMO_HOME/FSW_Launch.sh
echo 'env | grep AG_' >> $AG_DEMO_HOME/FSW_Launch.sh
echo ' ' >> $AG_DEMO_HOME/FSW_Launch.sh
echo 'read -n 1 -p '"'Press any key to continue or [CTL]+C to stop'"' ' >> $AG_DEMO_HOME/FSW_Launch.sh
echo ' ' >> $AG_DEMO_HOME/FSW_Launch.sh
echo $AG_FSW_HOME/bin/standalone.sh >> $AG_DEMO_HOME/FSW_Launch.sh

echo "#!/bin/sh" >> $AG_DEMO_HOME/BAM_Launch.sh
echo "#Launch BPM-Suite BAM for Demo AngryClaim"  >> $AG_DEMO_HOME/BAM_Launch.sh
echo 'service mysqld status ||  { echo \"mysql server is not up.... aborting.\"; exit 1; }'>> $AG_DEMO_HOME/BAM_Launch.sh
echo $AG_BAM_HOME/bin/standalone.sh >> $AG_DEMO_HOME/BAM_Launch.sh

chmod +x BAM_Launch.sh FSW_Launch.sh

echo " " >>demoInstructions.txt
echo "******************************************************************">>demoInstructions.txt
echo "**                                                          ******">>demoInstructions.txt
echo "**        A N G R Y              C L A I M                  ******">>demoInstructions.txt
echo "**                                                          ******">>demoInstructions.txt
echo "**        F I N A L    I N S T R U C T I O N S              ******">>demoInstructions.txt
echo "**                                                          ******">>demoInstructions.txt
echo "******************************************************************">>demoInstructions.txt
echo " ">>demoInstructions.txt
echo "Other actions may be very long, please launch them Manually : ">>demoInstructions.txt
echo "  1) creation of the deployable applications with maven clean package">>demoInstructions.txt
echo "        mvn clean package  ">>demoInstructions.txt
echo "  2) Deploy the application into Fuse Service works">>demoInstructions.txt
echo "        cp " $AG_DEMO_HOME/crm-service/target/crm-service.war " " $AG_FSW_HOME/standalone/deployments/>>demoInstructions.txt
echo "        cp " $AG_DEMO_HOME/switchyard-ear/target/switchyard-angrytweet.ear " " $AG_FSW_HOME/standalone/deployments/>>demoInstructions.txt
echo "        cp " $AG_DEMO_HOME/rtgov-ip/target/angrytweet-ip.war " " $AG_FSW_HOME/standalone/deployments/>>demoInstructions.txt
echo "        cp " $AG_DEMO_HOME/rtgov-epn-situation/target/angrytweet-epn-situation.war " " $AG_FSW_HOME/standalone/deployments/>>demoInstructions.txt
echo " "     >>demoInstructions.txt
echo " "     >>demoInstructions.txt
echo "Before FSW re-start, update of the CRM users  in" >>demoInstructions.txt
echo "            "  $AG_FSW_HOME/standalone/configuration/crm.properties>>demoInstructions.txt
echo " " >>demoInstructions.txt
echo "After BAM Start, in the dashboard configuration" >>demoInstructions.txt
echo "    a)create externalConnection JNDI : name=      AngryClamDB " >>demoInstructions.txt
echo "                                     jndiPath=  java:jboss/datasources/AngryTweetDS" >>demoInstructions.txt
echo "                                     testQuery= select 1"  >>demoInstructions.txt
echo " " >>demoInstructions.txt
echo "    b)create dataProvider : AngryClaimTickets" >>demoInstructions.txt
echo "                          select * from ticket order by channel_in">>demoInstructions.txt
echo " " >>demoInstructions.txt
echo "    c)create dataProvider : name=AngryClaimVeryAngryUsers " >>demoInstructions.txt
echo "                          select customer, area_code,compteur from(  select customer, area_code, count(*) as compteur  from (select customer,area_code, urgent  from ( select customer, channel_in, area_code, urgent from  angrytweet.ticket group by customer,channel_in order by customer, channel_in) AS T) as T2  group by customer) as T3 where compteur>1;" >>demoInstructions.txt
echo " " >>demoInstructions.txt
echo "    d)import the following file into the BAM workspace">>demoInstructions.txt
echo "            "  $AG_DEMO_HOME/etc/BAM/kpiExport_76041004.xml>>demoInstructions.txt
echo "            "  $AG_DEMO_HOME/etc/BAM/export_workspace.cex>>demoInstructions.txt
echo " ">>demoInstructions.txt
echo " " >>demoInstructions.txt
echo " " >>demoInstructions.txt
echo "You can now start FSW  with FSW_Launch.sh ">>demoInstructions.txt
echo " ">>demoInstructions.txt
echo "               and BAM with BAM_Launch.sh ">>demoInstructions.txt
echo " ">>demoInstructions.txt
echo " ">>demoInstructions.txt
echo "URL to launch BAM is ">>demoInstructions.txt
echo "            http://localhost:18080/dashbuilder/workspace/en/AngryClaimShowcase" >>demoInstructions.txt
echo "     with BAM user  :  admin / redhat123@">>demoInstructions.txt
echo ' '>>demoInstructions.txt
echo " ">>demoInstructions.txt
echo "URL to launch EAP Management console : http://localhost:9990/console/App.html#server-overview">>demoInstructions.txt
echo "    with user          admin / AngryCla1!m">>demoInstructions.txt
echo ' '>>demoInstructions.txt
echo " ">>demoInstructions.txt
echo "URL to launch FSW RT-GOV console :http://localhost:8080/s-ramp-ui/">>demoInstructions.txt
echo "    with user           fswAdmin / AngryCla1!m">>demoInstructions.txt
echo ' '>>demoInstructions.txt
echo ' '>>demoInstructions.txt
cat demoInstructions.txt
echo
echo "******************************************************************"
echo
echo "Setup Complete. Have Fun  with Fuse Service Works. "
echo "      the Authors :  ${AUTHORS}"
echo




