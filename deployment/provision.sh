#!/bin/bash
echo "Pulling Contrail Docker Images"
#As contrail-docker images are private using S3 to store specific images
wget https://s3-us-west-2.amazonaws.com/contrail-networking-docker-images/contrail-networking-docker_4.0.0.0-20_trusty.tgz;

echo "Creating a Directory Contrail to store the downloaded packages"
mkdir contrail;
echo "Untar the contrail-networking-docker package"
tar -xvzf contrail-networking-docker_4.0.0.0-20_trusty.tgz -C /root/contrail/.;
mkdir contrail/contrail-docker-images;
echo "Untar the contrail-docker-image package"
#The package contains other dependency packages and the images are located in contrail-docker_images.X.tgz
tar -xvzf contrail/contrail-docker-images_4.0.0.0-20.tgz -C /root/contrail/contrail-docker-images/.;

echo "Installing Latest Docker Version"
#apt-get installs older version of docker when used yum install
wget -qO- https://get.docker.com/ | sh
echo "Start Docker Engine"
sudo service docker start;
echo "Check Docker Status and Enable the Service"
sudo service docker status;

echo "****Loading Contrail Docker Images****"
echo "!!!!This may take 5-7 minutes!!!!"
echo "Loading Contail-Controller image.........."
docker load -i /root/contrail/contrail-docker-images/contrail-controller-ubuntu14.04-4.0.0.0-20.tar.gz;
echo "Loading Contail-Analytics image.........."
docker load -i /root/contrail/contrail-docker-images/contrail-analytics-ubuntu14.04-4.0.0.0-20.tar.gz;
echo "Loading Contail-AnalyticsDB image.........."
docker load -i /root/contrail/contrail-docker-images/contrail-analyticsdb-ubuntu14.04-4.0.0.0-20.tar.gz;
#echo "Loading Contail-LB image.........."
#docker load -i /root/contrail/contrail-docker-images/contrail-lb-ubuntu14.04-4.0.0.0-20.tar.gz;

echo "****Creating contrailctl directory to create contrail controller and analytics configuration files****"
mkdir /etc/contrailctl;

echo "****Creating controller configuration file***"
cat > /etc/contrailctl/controller.conf << EOF
[GLOBAL]
compute_nodes =
#compute_nodes = "192.168.1.1, 192.168.1.2, 192.168.1.3"
enable_webui_service = True
cloud_orchestrator = openstack
config_ip = 
#config_ip = "192.168.1.6, 192.168.1.7, 192.168.1.8"  (HA Mode)
analyticsdb_nodes = 
#analyticsdb_nodes = "192.168.1.6, 192.168.1.7, 192.168.1.8" (HA Mode)
analytics_nodes = 
#analyticsdb_nodes = "192.168.1.6, 192.168.1.7, 192.168.1.8"  (HA Mode)
sandesh_ssl_enable = False
introspect_ssl_enable = False
controller_nodes = 
enable_control_service = True
ceph_controller_nodes =
enable_config_service = True
analytics_ip = 
controller_ip = 
config_nodes = 
[CONTROLLER]
external_routers_list = {}
[WEBUI]
webui_storage_enable = False
[KEYSTONE]
ip = ##PF9_Openstack##
#Provide PF9 Openstack Controller details
admin_password = ##PF9_Openstack##
#Provide PF9 Openstack Controller admin_tenant password
EOF

echo "****Creating analytics configuration file***"
cat > /etc/contrailctl/analytics.conf << EOF
[GLOBAL]
compute_nodes = 
enable_webui_service = True
cloud_orchestrator = openstack
config_ip = 
analyticsdb_nodes = 
analytics_nodes = 
sandesh_ssl_enable = False
introspect_ssl_enable = False
controller_nodes = 
enable_control_service = True
ceph_controller_nodes =
enable_config_service = True
analytics_ip = 
controller_ip = 
config_nodes = 
[KEYSTONE]
ip = ##PF9_Openstack##
admin_password = ##PF9_Openstack##
EOF

echo "****Creating analyticsdb configuration file***"
cat > /etc/contrailctl/analyticsdb.conf << EOF
[GLOBAL]
compute_nodes = 
enable_webui_service = True
cloud_orchestrator = openstack
config_ip = 
analyticsdb_nodes = 
analytics_nodes = 
sandesh_ssl_enable = False
introspect_ssl_enable = False
controller_nodes = 
enable_control_service = True
ceph_controller_nodes =
enable_config_service = True
analytics_ip = 
controller_ip = 
config_nodes = 
[KEYSTONE]
ip = ##PF9_Openstack##
admin_password = ##PF9_Openstack##
EOF