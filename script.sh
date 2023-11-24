#!/bin/bash

# Variables
vpc_name="mi-vpc"
region="us-east-1"
cidr_block="192.168.1.0/22"

# Crear VPC
vpc_id=$(aws ec2 create-vpc --cidr-block $cidr_block --query 'Vpc.VpcId' --output text --region $region)
aws ec2 create-tags --resources $vpc_id --tags Key=Name,Value=$vpc_name --region $region
aws ec2 modify-vpc-attribute --vpc-id $vpc_id --enable-dns-support "{\"Value\":true}" --region $region
aws ec2 modify-vpc-attribute --vpc-id $vpc_id --enable-dns-hostnames "{\"Value\":true}" --region $region
echo "VPC creada con ID: $vpc_id"

# Crear subredes y EC2 para cada departamento
departments=("ingenieria:100" "desarrollo:500" "mantenimiento:20" "soporte:250")

subnet_index=1
for department in "${departments[@]}"; do
    # Extraer nombre y cantidad de trabajadores
    IFS=':' read -r name count <<< "$department"
    
    # Crear subred
    subnet_cidr="192.168.$subnet_index.0/24"
    subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $subnet_cidr --availability-zone $region --query 'Subnet.SubnetId' --output text --region $region)
    
    # Crear EC2
    instance_name="ec2-$name"
    for ((i=1; i<=$count; i++)); do
        aws ec2 run-instances --image-id ami-xxxxxxxxxxxxx --instance-type t2.micro --subnet-id $subnet_id --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name-$i}]" --region $region
    done

    echo "Subred y EC2 para $name creadas"
    ((subnet_index++))
done

echo "Script completado"
